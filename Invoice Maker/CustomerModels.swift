import Foundation
import MapKit

// MARK: - Customer Model
/// Represents a customer with contact information and service history
struct Customer: Identifiable, Codable, Hashable {
    // MARK: - Properties
    let id: UUID
    var name: String
    var phone: String
    var email: String
    var address: String
    var city: String
    var zipCode: String
    var notes: String
    var dateAdded: Date
    var lastServiceDate: Date?
    
    // MARK: - Computed Properties
    
    /// Full formatted address
    var fullAddress: String {
        let components = [address, city, zipCode].filter { !$0.isEmpty }
        return components.joined(separator: ", ")
    }
    
    /// Formatted phone number for display
    var formattedPhone: String {
        guard !phone.isEmpty else { return "" }
        let cleaned = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        if cleaned.count == 10 {
            let areaCode = String(cleaned.prefix(3))
            let firstThree = String(cleaned.dropFirst(3).prefix(3))
            let lastFour = String(cleaned.suffix(4))
            return "(\(areaCode)) \(firstThree)-\(lastFour)"
        }
        
        return phone // Return original if can't format
    }
    
    /// Display name for customer (fallback if name is empty)
    var displayName: String {
        name.isEmpty ? "Unnamed Customer" : name
    }
    
    /// Indicates if this is a recent customer (added in last 30 days)
    var isNewCustomer: Bool {
        Calendar.current.dateInterval(of: .month, for: Date())?.contains(dateAdded) ?? false
    }
    
    /// Number of days since last service
    var daysSinceLastService: Int? {
        guard let lastServiceDate = lastServiceDate else { return nil }
        return Calendar.current.dateComponents([.day], from: lastServiceDate, to: Date()).day
    }
    
    // MARK: - Initializers
    init(
        id: UUID = UUID(),
        name: String = "",
        phone: String = "",
        email: String = "",
        address: String = "",
        city: String = "",
        zipCode: String = "",
        notes: String = "",
        dateAdded: Date = Date(),
        lastServiceDate: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.phone = phone
        self.email = email
        self.address = address
        self.city = city
        self.zipCode = zipCode
        self.notes = notes
        self.dateAdded = dateAdded
        self.lastServiceDate = lastServiceDate
    }
}

// MARK: - Customer Service History
/// Represents the service history for a customer
struct CustomerServiceRecord {
    let customerId: UUID
    let invoices: [Invoice]
    
    var totalSpent: Double {
        invoices.reduce(0) { $0 + $1.total }
    }
    
    var lastServiceDate: Date? {
        invoices.map(\.date).max()
    }
    
    var serviceCount: Int {
        invoices.count
    }
    
    var averageInvoiceAmount: Double {
        guard !invoices.isEmpty else { return 0 }
        return totalSpent / Double(invoices.count)
    }
}

// MARK: - Sample Data
extension Customer {
    /// Sample customers for testing
    static let sampleCustomers: [Customer] = [
        Customer(
            name: "John Smith",
            phone: "8165551234",
            email: "john.smith@email.com",
            address: "123 Oak Street",
            city: "Overland Park",
            zipCode: "66213",
            notes: "Prefers morning appointments. Has 2 HVAC units.",
            dateAdded: Calendar.current.date(byAdding: .day, value: -45, to: Date()) ?? Date(),
            lastServiceDate: Calendar.current.date(byAdding: .day, value: -15, to: Date())
        ),
        
        Customer(
            name: "Sarah Johnson",
            phone: "9135557890",
            email: "s.johnson@gmail.com",
            address: "456 Maple Avenue",
            city: "Leawood",
            zipCode: "66224",
            notes: "Annual maintenance customer. Large home with 3 units.",
            dateAdded: Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date(),
            lastServiceDate: Calendar.current.date(byAdding: .month, value: -2, to: Date())
        ),
        
        Customer(
            name: "Mike Davis",
            phone: "8165559876",
            email: "",
            address: "789 Pine Road",
            city: "Shawnee",
            zipCode: "66203",
            notes: "Rental property owner. Multiple locations.",
            dateAdded: Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date(),
            lastServiceDate: nil
        ),
        
        Customer(
            name: "Lisa Wilson",
            phone: "9135554321",
            email: "lisa.wilson@company.com",
            address: "321 Cedar Lane",
            city: "Olathe",
            zipCode: "66051",
            notes: "Business customer. Office building maintenance.",
            dateAdded: Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date(),
            lastServiceDate: Calendar.current.date(byAdding: .day, value: -21, to: Date())
        )
    ]
}