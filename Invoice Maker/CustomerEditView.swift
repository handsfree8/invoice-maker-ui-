import SwiftUI

struct CustomerEditView: View {
    // MARK: - Properties
    @ObservedObject var customerStorage: CustomerStorage
    @Environment(\.dismiss) private var dismiss
    
    let existingCustomer: Customer?
    
    // MARK: - Form State
    @State private var name: String = ""
    @State private var phone: String = ""
    @State private var email: String = ""
    @State private var address: String = ""
    @State private var city: String = ""
    @State private var zipCode: String = ""
    @State private var notes: String = ""
    
    // MARK: - Computed Properties
    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Initialization
    init(customer: Customer? = nil, customerStorage: CustomerStorage) {
        self.existingCustomer = customer
        self.customerStorage = customerStorage
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            Form {
                personalInfoSection
                contactInfoSection
                addressSection
                notesSection
            }
            .navigationTitle(existingCustomer == nil ? "New Customer" : "Edit Customer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveCustomer()
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear(perform: loadCustomerData)
        }
    }
}

// MARK: - View Sections
extension CustomerEditView {
    
    /// Personal information section
    private var personalInfoSection: some View {
        Section("Personal Information") {
            TextField("Full Name", text: $name)
                .textContentType(.name)
            
            TextField("Phone Number", text: $phone)
                .textContentType(.telephoneNumber)
                .keyboardType(.phonePad)
            
            TextField("Email Address", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
        }
    }
    
    /// Contact information section
    private var contactInfoSection: some View {
        Section("Contact Information") {
            TextField("Street Address", text: $address)
                .textContentType(.streetAddressLine1)
            
            HStack {
                TextField("City", text: $city)
                    .textContentType(.addressCity)
                
                TextField("ZIP", text: $zipCode)
                    .textContentType(.postalCode)
                    .keyboardType(.numberPad)
                    .frame(width: 80)
            }
        }
    }
    
    /// Address section
    private var addressSection: some View {
        Section("Service Area") {
            if !address.isEmpty || !city.isEmpty || !zipCode.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    if !address.isEmpty {
                        Text(address)
                    }
                    if !city.isEmpty || !zipCode.isEmpty {
                        Text("\(city) \(zipCode)".trimmingCharacters(in: .whitespaces))
                    }
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            } else {
                Text("No address entered")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
    }
    
    /// Notes section
    private var notesSection: some View {
        Section("Notes") {
            if #available(iOS 16.0, *) {
                TextField("Customer notes, preferences, equipment info...", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
            } else {
                // iOS 15 compatibility - using TextEditor instead
                VStack(alignment: .leading, spacing: 4) {
                    if notes.isEmpty {
                        Text("Customer notes, preferences, equipment info...")
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
extension CustomerEditView {
    
    /// Loads existing customer data if editing
    private func loadCustomerData() {
        guard let customer = existingCustomer else { return }
        
        name = customer.name
        phone = customer.phone
        email = customer.email
        address = customer.address
        city = customer.city
        zipCode = customer.zipCode
        notes = customer.notes
    }
    
    /// Saves the customer
    private func saveCustomer() {
        let customer = Customer(
            id: existingCustomer?.id ?? UUID(),
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            phone: phone.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            address: address.trimmingCharacters(in: .whitespacesAndNewlines),
            city: city.trimmingCharacters(in: .whitespacesAndNewlines),
            zipCode: zipCode.trimmingCharacters(in: .whitespacesAndNewlines),
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            dateAdded: existingCustomer?.dateAdded ?? Date(),
            lastServiceDate: existingCustomer?.lastServiceDate
        )
        
        customerStorage.saveCustomer(customer)
        dismiss()
    }
}

// MARK: - Preview
#Preview {
    CustomerEditView(customerStorage: CustomerStorage())
}

#Preview("Edit Existing") {
    let sampleCustomer = Customer.sampleCustomers[0]
    return CustomerEditView(customer: sampleCustomer, customerStorage: CustomerStorage())
}