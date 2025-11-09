import SwiftUI

struct ContentView: View {
    // MARK: - Properties
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var invoiceStorage = InvoiceStorage()
    @State private var showingEditView = false
    @State private var invoiceToEdit: Invoice?
    @State private var showingSplash = false
    
    // MARK: - Constants
    private enum DemoData {
        static let invoiceNumberPrefix = "RL-"
        static let defaultClient = "Demo Client"
        static let defaultTaxRate = 0.085
        
        static let sampleItems = [
            LineItem(descriptionText: "HVAC Diagnosis", quantity: 1, unitPrice: 79),
            LineItem(descriptionText: "Condenser Repair", quantity: 1, unitPrice: 180)
        ]
        
        static let warrantyNotes = "This service includes warranty coverage only for the work performed today. Any future issues unrelated to this service requested are not covered under this warranty and will be quoted separately as new service requests."
    }
    
    // MARK: - Body
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                if showingSplash {
                    SplashView {
                        withAnimation {
                            showingSplash = false
                        }
                    }
                } else {
                    mainInvoiceView
                }
            } else {
                LoginView()
                    .environmentObject(authManager)
            }
        }
        .onReceive(authManager.$isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                showingSplash = true
            }
        }
    }
    
    private var mainInvoiceView: some View {
        NavigationView {
            invoicesList
                .navigationTitle("Invoices")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack {
                            Image("rl-logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        Menu {
                            Label(authManager.getUserDisplayName(), systemImage: "person.circle")
                            
                            Divider()
                            
                            Button(action: authManager.logout) {
                                Label("Sign Out", systemImage: "power")
                            }
                        } label: {
                            Image(systemName: "person.circle")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        EditButton()
                        addInvoiceButton
                    }
                }
                .sheet(isPresented: $showingEditView) {
                    InvoiceEditView(invoice: invoiceToEdit, store: invoiceStorage)
                }
        }
    }
}

// MARK: - View Components
extension ContentView {
    
    /// List of saved invoices
    private var invoicesList: some View {
        List {
            ForEach(invoiceStorage.savedInvoices) { invoice in
                NavigationLink(destination: InvoiceDetailView(invoice: invoice)) {
                    InvoiceRowView(invoice: invoice)
                }
                .contextMenu {
                    Button("Edit") {
                        invoiceToEdit = invoice
                        showingEditView = true
                    }
                    
                    Button("Duplicate") {
                        duplicateInvoice(invoice)
                    }
                    
                    Button("Delete", role: .destructive) {
                        invoiceStorage.deleteInvoice(invoice)
                    }
                }
            }
            .onDelete(perform: deleteInvoices)
        }
    }
    
    /// Button to add a new invoice
    private var addInvoiceButton: some View {
        Button(action: addNewInvoice) {
            Label("Add", systemImage: "plus")
        }
    }
    
    // MARK: - Actions
    
    /// Deletes invoices at the specified index set
    private func deleteInvoices(at indexSet: IndexSet) {
        for index in indexSet {
            let invoice = invoiceStorage.savedInvoices[index]
            invoiceStorage.deleteInvoice(invoice)
        }
    }
    
    /// Creates and adds a demo invoice
    private func addDemoInvoice() {
        let demoInvoice = createDemoInvoice()
        invoiceStorage.saveInvoice(demoInvoice)
    }
    
    /// Opens the edit view for a new invoice
    private func addNewInvoice() {
        invoiceToEdit = nil
        showingEditView = true
    }
    
    /// Duplicates an existing invoice
    private func duplicateInvoice(_ invoice: Invoice) {
        let duplicatedInvoice = Invoice(
            number: generateInvoiceNumber(),
            date: Date(),
            clientName: invoice.clientName,
            items: invoice.items,
            discount: invoice.discount,
            taxRate: invoice.taxRate,
            notes: invoice.notes,
            paymentMethod: invoice.paymentMethod,
            terms: invoice.terms
        )
        invoiceStorage.saveInvoice(duplicatedInvoice)
    }
    
    /// Creates a demo invoice with sample data
    private func createDemoInvoice() -> Invoice {
        return Invoice(
            number: generateInvoiceNumber(),
            date: .now,
            clientName: DemoData.defaultClient,
            items: DemoData.sampleItems,
            discount: 0,
            taxRate: DemoData.defaultTaxRate,
            notes: DemoData.warrantyNotes
        )
    }
    
    /// Generates a random invoice number with the company prefix
    private func generateInvoiceNumber() -> String {
        let randomNumber = Int.random(in: 1...99999)
        return "\(DemoData.invoiceNumberPrefix)\(String(format: "%05d", randomNumber))"
    }
}

// MARK: - Invoice Row View
struct InvoiceRowView: View {
    let invoice: Invoice
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("#\(invoice.number)")
                    .font(.headline)
                
                Spacer()
                
                Text(invoice.total, format: .currency(code: "USD"))
                    .bold()
            }
            
            Text(clientDisplayName)
                .foregroundStyle(.secondary)
            
            Text(invoice.date, style: .date)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    /// Display name for the client, with fallback for empty names
    private var clientDisplayName: String {
        invoice.clientName.isEmpty ? "No Client" : invoice.clientName
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
