import SwiftUI

struct CustomerDetailView: View {
    // MARK: - Properties
    let customer: Customer
    @ObservedObject var customerStorage: CustomerStorage
    var invoiceStorage: InvoiceStorage? = nil
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingEditView = false
    @State private var showingDeleteAlert = false
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Customer Info Card
                    customerInfoCard
                    
                    // Contact Info Card
                    contactInfoCard
                    
                    // Service History Card
                    serviceHistoryCard
                    
                    // Notes Card
                    if !customer.notes.isEmpty {
                        notesCard
                    }
                    
                    // Quick Actions
                    quickActionsCard
                }
                .padding()
            }
            .navigationTitle(customer.displayName)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu("Actions") {
                        Button("Edit Customer") {
                            showingEditView = true
                        }
                        
                        Button("Call Customer") {
                            callCustomer()
                        }
                        .disabled(customer.phone.isEmpty)
                        
                        Button("Email Customer") {
                            emailCustomer()
                        }
                        .disabled(customer.email.isEmpty)
                        
                        Divider()
                        
                        Button("Delete Customer", role: .destructive) {
                            showingDeleteAlert = true
                        }
                    }
                }
            }
            .sheet(isPresented: $showingEditView) {
                CustomerEditView(customer: customer, customerStorage: customerStorage)
            }
            .alert("Delete Customer", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    customerStorage.deleteCustomer(customer)
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete \(customer.displayName)? This action cannot be undone.")
            }
        }
    }
}

// MARK: - View Components
extension CustomerDetailView {
    
    /// Customer basic information card
    private var customerInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Customer Information")
                    .font(.headline)
                
                Spacer()
                
                if customer.isNewCustomer {
                    Text("New Customer")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(
                    icon: "person.fill",
                    title: "Name",
                    value: customer.displayName
                )
                
                InfoRow(
                    icon: "calendar",
                    title: "Customer Since",
                    value: customer.dateAdded.formatted(date: .abbreviated, time: .omitted)
                )
                
                if let lastService = customer.lastServiceDate {
                    InfoRow(
                        icon: "wrench.and.screwdriver",
                        title: "Last Service",
                        value: lastService.formatted(date: .abbreviated, time: .omitted)
                    )
                } else {
                    InfoRow(
                        icon: "exclamationmark.triangle",
                        title: "Last Service",
                        value: "No service history",
                        valueColor: .orange
                    )
                }
            }
        }
        .cardStyle()
    }
    
    /// Contact information card
    private var contactInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Contact Information")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                if !customer.phone.isEmpty {
                    InfoRow(
                        icon: "phone.fill",
                        title: "Phone",
                        value: customer.formattedPhone,
                        isActionable: true
                    ) {
                        callCustomer()
                    }
                }
                
                if !customer.email.isEmpty {
                    InfoRow(
                        icon: "envelope.fill",
                        title: "Email",
                        value: customer.email,
                        isActionable: true
                    ) {
                        emailCustomer()
                    }
                }
                
                if !customer.fullAddress.isEmpty {
                    InfoRow(
                        icon: "location.fill",
                        title: "Address",
                        value: customer.fullAddress,
                        isActionable: true
                    ) {
                        openInMaps()
                    }
                } else {
                    InfoRow(
                        icon: "location",
                        title: "Address",
                        value: "No address on file",
                        valueColor: .secondary
                    )
                }
            }
        }
        .cardStyle()
    }
    
    /// Service history summary card
    private var serviceHistoryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Service Summary")
                .font(.headline)
            
            HStack(spacing: 20) {
                ServiceStatView(
                    title: "Total Services",
                    value: "\(serviceCount)",
                    icon: "wrench.and.screwdriver.fill",
                    color: .blue
                )
                
                ServiceStatView(
                    title: "Total Spent",
                    value: totalSpent.formatted(.currency(code: "USD")),
                    icon: "dollarsign.circle.fill",
                    color: .green
                )
                
                ServiceStatView(
                    title: "Avg Invoice",
                    value: averageInvoice.formatted(.currency(code: "USD")),
                    icon: "chart.bar.fill",
                    color: .orange
                )
            }
        }
        .cardStyle()
    }
    
    // MARK: - Computed Properties for Service History
    
    private var serviceCount: Int {
        guard let storage = invoiceStorage else { return 0 }
        return customer.invoiceCount(from: storage)
    }
    
    private var totalSpent: Double {
        guard let storage = invoiceStorage else { return 0 }
        return customer.totalSpent(from: storage)
    }
    
    private var averageInvoice: Double {
        guard let storage = invoiceStorage else { return 0 }
        return customer.averageInvoice(from: storage)
    }
    
    /// Customer notes card
    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes")
                .font(.headline)
            
            Text(customer.notes)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .cardStyle()
    }
    
    /// Quick actions card
    private var quickActionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ActionButton(
                    title: "Create Invoice",
                    icon: "doc.text.fill",
                    color: .blue
                ) {
                    createInvoice()
                }
                
                ActionButton(
                    title: "Schedule Service",
                    icon: "calendar.badge.plus",
                    color: .green
                ) {
                    scheduleService()
                }
                
                ActionButton(
                    title: "Call Customer",
                    icon: "phone.fill",
                    color: .orange,
                    isDisabled: customer.phone.isEmpty
                ) {
                    callCustomer()
                }
                
                ActionButton(
                    title: "Send Email",
                    icon: "envelope.fill",
                    color: .purple,
                    isDisabled: customer.email.isEmpty
                ) {
                    emailCustomer()
                }
            }
        }
        .cardStyle()
    }
}

// MARK: - Actions
extension CustomerDetailView {
    
    private func callCustomer() {
        let cleanPhone = customer.phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if let url = URL(string: "tel://\(cleanPhone)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func emailCustomer() {
        if let url = URL(string: "mailto:\(customer.email)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openInMaps() {
        let address = customer.fullAddress.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "http://maps.apple.com/?q=\(address)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func createInvoice() {
        // TODO: Navigate to invoice creation with customer pre-filled
        print("Creating invoice for \(customer.displayName)")
    }
    
    private func scheduleService() {
        // TODO: Implement scheduling functionality
        print("Scheduling service for \(customer.displayName)")
    }
}

// MARK: - Helper Views
struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    var valueColor: Color = .primary
    var isActionable: Bool = false
    var action: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.blue)
                .frame(width: 20, alignment: .center)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if isActionable, let action = action {
                    Button(value) {
                        action()
                    }
                    .foregroundColor(.blue)
                    .font(.subheadline)
                } else {
                    Text(value)
                        .font(.subheadline)
                        .foregroundColor(valueColor)
                }
            }
            
            Spacer()
        }
    }
}

struct ServiceStatView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    var isDisabled: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isDisabled ? .gray : color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(isDisabled ? .gray : .primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, minHeight: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isDisabled ? Color.gray.opacity(0.1) : color.opacity(0.1))
            )
        }
        .disabled(isDisabled)
    }
}

// MARK: - Card Style
struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

extension View {
    func cardStyle() -> some View {
        self.modifier(CardModifier())
    }
}

// MARK: - Preview
#Preview {
    CustomerDetailView(
        customer: Customer.sampleCustomers[0],
        customerStorage: CustomerStorage()
    )
}