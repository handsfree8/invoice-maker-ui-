import SwiftUI

struct InvoiceEditView: View {
    // MARK: - Properties
    @ObservedObject var store: InvoiceStorage
    @Environment(\.dismiss) private var dismiss
    
    let existingInvoice: Invoice?
    
    // MARK: - Form State
    @State private var invoiceNumber: String = ""
    @State private var invoiceDate: Date = Date()
    @State private var clientName: String = ""
    @State private var paymentMethod: PaymentMethod = .cash
    @State private var terms: String = "Paid in full"
    @State private var notes: String = ""
    @State private var items: [LineItem] = []
    @State private var discountRate: Double = 0 // Percentage
    
    // MARK: - UI State
    @State private var showingDeleteAlert = false
    @State private var itemToDelete: LineItem?
    
    // MARK: - Constants
    private enum FormConstants {
        static let defaultInvoicePrefix = "RL-"
        static let defaultTerms = "Paid in full"
        static let minItemCount = 1
    }
    
    // MARK: - Computed Properties
    private var subTotal: Double {
        items.reduce(0) { $0 + $1.lineTotal }
    }
    
    private var discountAmount: Double {
        subTotal * (discountRate / 100)
    }
    
    private var total: Double {
        max(0, subTotal - discountAmount)
    }
    
    private var canSave: Bool {
        !invoiceNumber.isEmpty && !items.isEmpty && items.allSatisfy { !$0.descriptionText.isEmpty }
    }
    
    // MARK: - Initialization
    init(invoice: Invoice? = nil, store: InvoiceStorage) {
        self.existingInvoice = invoice
        self.store = store
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            Form {
                invoiceInfoSection
                itemsSection
                totalsSection
                paymentSection
                notesSection
            }
            .navigationTitle(existingInvoice == nil ? "New Invoice" : "Edit Invoice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        saveInvoice()
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear(perform: loadInvoiceData)
            .alert("Delete Item", isPresented: $showingDeleteAlert, presenting: itemToDelete) { item in
                Button("Delete", role: .destructive) {
                    deleteItem(item)
                }
                Button("Cancel", role: .cancel) { }
            } message: { item in
                Text("Are you sure you want to delete '\(item.descriptionText)'?")
            }
        }
    }
}

// MARK: - View Sections
extension InvoiceEditView {
    
    /// Invoice basic information section
    private var invoiceInfoSection: some View {
        Section("Invoice Information") {
            HStack {
                Text("Invoice #")
                Spacer()
                TextField("000123", text: $invoiceNumber)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.trailing)
            }
            
            DatePicker("Date", selection: $invoiceDate, displayedComponents: .date)
            
            HStack {
                Text("Client")
                Spacer()
                TextField("Client name", text: $clientName)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.trailing)
            }
        }
    }
    
    /// Items section with dynamic list
    private var itemsSection: some View {
        Section("Items") {
            ForEach(items.indices, id: \.self) { index in
                VStack(spacing: 8) {
                    // Description
                    HStack {
                        Text("Description")
                            .frame(width: 80, alignment: .leading)
                        TextField("Item description", text: $items[index].descriptionText)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    // Quantity and Unit Price
                    HStack {
                        VStack {
                            Text("Qty")
                                .font(.caption)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            TextField("1", value: $items[index].quantity, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                        }
                        
                        VStack {
                            Text("Unit Price")
                                .font(.caption)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            TextField("0.00", value: $items[index].unitPrice, format: .currency(code: "USD"))
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                        }
                        
                        VStack {
                            Text("Total")
                                .font(.caption)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(items[index].lineTotal, format: .currency(code: "USD"))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                    // Delete button
                    if items.count > FormConstants.minItemCount {
                        Button("Delete Item", role: .destructive) {
                            itemToDelete = items[index]
                            showingDeleteAlert = true
                        }
                        .font(.caption)
                    }
                }
                .padding(.vertical, 4)
            }
            
            Button("+ Add Item") {
                addNewItem()
            }
            .foregroundColor(.blue)
        }
    }
    
    /// Totals section showing calculations
    private var totalsSection: some View {
        Section("Totals") {
            HStack {
                Text("Subtotal")
                Spacer()
                Text(subTotal, format: .currency(code: "USD"))
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Discount %")
                Spacer()
                TextField("0", value: $discountRate, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                    .frame(width: 80)
            }
            
            if discountAmount > 0 {
                HStack {
                    Text("Discount Amount")
                    Spacer()
                    Text(-discountAmount, format: .currency(code: "USD"))
                        .foregroundColor(.red)
                }
            }
            
            HStack {
                Text("Total Amount Due")
                    .fontWeight(.bold)
                Spacer()
                Text(total, format: .currency(code: "USD"))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
        }
    }
    
    /// Payment and terms section
    private var paymentSection: some View {
        Section("Payment & Terms") {
            Picker("Payment Method", selection: $paymentMethod) {
                ForEach(PaymentMethod.allCases, id: \.self) { method in
                    Text(method.rawValue).tag(method)
                }
            }
            
            HStack {
                Text("Terms")
                Spacer()
                TextField("Paid in full", text: $terms)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.trailing)
            }
        }
    }
    
    /// Notes section
    private var notesSection: some View {
        Section("Notes") {
            if #available(iOS 16.0, *) {
                TextField("Internal notes (optional)", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
            } else {
                // iOS 15 compatibility - using TextEditor instead
                VStack(alignment: .leading, spacing: 4) {
                    if notes.isEmpty {
                        Text("Internal notes (optional)")
                            .foregroundColor(.secondary)
                            .allowsHitTesting(false)
                    }
                    TextEditor(text: $notes)
                        .frame(minHeight: 80, maxHeight: 120)
                }
            }
        }
    }
}

// MARK: - Actions
extension InvoiceEditView {
    
    /// Loads existing invoice data if editing
    private func loadInvoiceData() {
        guard let invoice = existingInvoice else {
            // Initialize with default values for new invoice
            generateInvoiceNumber()
            addNewItem()
            return
        }
        
        // Load existing invoice data
        invoiceNumber = invoice.number
        invoiceDate = invoice.date
        clientName = invoice.clientName
        paymentMethod = invoice.paymentMethod ?? .cash
        terms = invoice.terms ?? FormConstants.defaultTerms
        notes = invoice.notes
        items = invoice.items.isEmpty ? [LineItem()] : invoice.items
        
        // Convert from fixed discount to percentage (approximation)
        if invoice.discount > 0 && subTotal > 0 {
            discountRate = (invoice.discount / subTotal) * 100
        }
    }
    
    /// Generates a new invoice number
    private func generateInvoiceNumber() {
        let randomNumber = Int.random(in: 1...99999)
        invoiceNumber = "\(FormConstants.defaultInvoicePrefix)\(String(format: "%05d", randomNumber))"
    }
    
    /// Adds a new empty item
    private func addNewItem() {
        let newItem = LineItem(descriptionText: "", quantity: 1, unitPrice: 0)
        items.append(newItem)
    }
    
    /// Deletes the specified item
    private func deleteItem(_ item: LineItem) {
        items.removeAll { $0.id == item.id }
        itemToDelete = nil
    }
    
    /// Saves the invoice
    private func saveInvoice() {
        let invoice = Invoice(
            id: existingInvoice?.id ?? UUID(),
            number: invoiceNumber.trimmingCharacters(in: .whitespacesAndNewlines),
            date: invoiceDate,
            clientName: clientName.trimmingCharacters(in: .whitespacesAndNewlines),
            items: items.filter { !$0.descriptionText.isEmpty },
            discount: discountAmount, // Convert percentage back to fixed amount
            taxRate: 0, // Removed as requested
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            paymentMethod: paymentMethod,
            terms: terms.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        store.saveInvoice(invoice)
        dismiss()
    }
}

// MARK: - Preview
#Preview {
    InvoiceEditView(store: InvoiceStorage())
}

#Preview("Edit Existing") {
    let sampleInvoice = Invoice(
        number: "RL-00123",
        date: Date(),
        clientName: "Sample Client",
        items: [
            LineItem(descriptionText: "HVAC Diagnosis", quantity: 1, unitPrice: 79),
            LineItem(descriptionText: "Condenser Repair", quantity: 1, unitPrice: 180)
        ],
        discount: 0,
        taxRate: 0,
        notes: "Sample notes"
    )
    
    return InvoiceEditView(invoice: sampleInvoice, store: InvoiceStorage())
}