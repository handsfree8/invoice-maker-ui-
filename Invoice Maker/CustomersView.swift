import SwiftUI

struct CustomersView: View {
    // MARK: - Properties
    @ObservedObject var customerStorage: CustomerStorage
    @State private var searchText = ""
    @State private var sortOption: CustomerSortOption = .name
    @State private var showingAddCustomer = false
    @State private var selectedCustomer: Customer? = nil
    @State private var showingCustomerDetail = false
    
    init(customerStorage: CustomerStorage = CustomerStorage()) {
        self.customerStorage = customerStorage
    }
    
    // MARK: - Computed Properties
    private var filteredCustomers: [Customer] {
        let customers = customerStorage.getCustomers(sortedBy: sortOption)
        
        if searchText.isEmpty {
            return customers
        } else {
            return customerStorage.searchCustomers(searchText)
        }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack {
                // Stats Section
                if !customerStorage.customers.isEmpty {
                    customerStatsView
                        .padding(.horizontal)
                }
                
                // Customers List
                List {
                    ForEach(filteredCustomers) { customer in
                        CustomerRowView(customer: customer) {
                            selectedCustomer = customer
                            showingCustomerDetail = true
                        }
                    }
                    .onDelete(perform: deleteCustomers)
                }
                .searchable(text: $searchText, prompt: "Search customers...")
            }
            .navigationTitle("Customers")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu("Sort") {
                        ForEach(CustomerSortOption.allCases, id: \.self) { option in
                            Button(option.rawValue) {
                                sortOption = option
                            }
                        }
                    }
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Menu("Options") {
                        Button("Add Sample Data") {
                            customerStorage.addSampleCustomers()
                        }
                        
                        Button("Export List") {
                            // TODO: Export functionality
                        }
                    }
                    
                    Button("Add Customer") {
                        showingAddCustomer = true
                    }
                }
            }
            .sheet(isPresented: $showingAddCustomer) {
                CustomerEditView(customerStorage: customerStorage)
            }
            .sheet(isPresented: $showingCustomerDetail) {
                if let customer = selectedCustomer {
                    CustomerDetailView(
                        customer: customer,
                        customerStorage: customerStorage,
                        invoiceStorage: InvoiceStorage()
                    )
                }
            }
        }
    }
}

// MARK: - View Components
extension CustomersView {
    
    /// Customer statistics overview
    private var customerStatsView: some View {
        HStack(spacing: 20) {
            StatCard(
                title: "Total",
                value: "\(customerStorage.customers.count)",
                color: .blue
            )
            
            StatCard(
                title: "Recent",
                value: "\(customerStorage.recentCustomers.count)",
                color: .green
            )
            
            StatCard(
                title: "Follow-up",
                value: "\(customerStorage.customersNeedingFollowUp.count)",
                color: .orange
            )
        }
        .padding(.vertical, 8)
    }
    
    /// Deletes customers at the specified index set
    private func deleteCustomers(at indexSet: IndexSet) {
        indexSet.forEach { index in
            let customer = filteredCustomers[index]
            customerStorage.deleteCustomer(customer)
        }
    }
}

// MARK: - Customer Row View
struct CustomerRowView: View {
    let customer: Customer
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(customer.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if customer.isNewCustomer {
                        Text("New")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                }
                
                if !customer.phone.isEmpty {
                    HStack {
                        Image(systemName: "phone")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(customer.formattedPhone)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                if !customer.city.isEmpty {
                    HStack {
                        Image(systemName: "location")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(customer.city)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let daysSince = customer.daysSinceLastService {
                    HStack {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Last service: \(daysSince) days ago")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    HStack {
                        Image(systemName: "exclamationmark.circle")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Text("No service history")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Preview
#Preview {
    CustomersView()
}