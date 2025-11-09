import SwiftUI

/// Integration helper for connecting customer and invoice systems
struct CustomerInvoiceIntegration {
    
    /// Creates a new invoice pre-filled with customer information
    static func createInvoiceForCustomer(_ customer: Customer) -> Invoice {
        let invoice = Invoice(
            number: generateInvoiceNumber(),
            date: Date(),
            clientName: customer.displayName,
            items: [],
            discount: 0,
            taxRate: 0.085, // Default tax rate
            notes: "Service for \(customer.displayName)",
            paymentMethod: .cash,
            terms: nil
        )
        
        return invoice
    }
    
    /// Generates a new invoice number
    private static func generateInvoiceNumber() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let dateString = formatter.string(from: Date())
        let random = Int.random(in: 1000...9999)
        return "RL-\(dateString)-\(random)"
    }
    
    /// Finds invoices for a specific customer
    static func invoicesForCustomer(_ customer: Customer, from storage: InvoiceStorage) -> [Invoice] {
        return storage.savedInvoices.filter { invoice in
            // Match by name (since Invoice model only has clientName)
            invoice.clientName.lowercased() == customer.displayName.lowercased()
        }
    }
    
    /// Calculates total spent by customer
    static func totalSpentByCustomer(_ customer: Customer, from storage: InvoiceStorage) -> Double {
        let customerInvoices = invoicesForCustomer(customer, from: storage)
        return customerInvoices.reduce(0) { $0 + $1.total }
    }
    
    /// Calculates average invoice amount for customer
    static func averageInvoiceForCustomer(_ customer: Customer, from storage: InvoiceStorage) -> Double {
        let customerInvoices = invoicesForCustomer(customer, from: storage)
        guard !customerInvoices.isEmpty else { return 0 }
        return totalSpentByCustomer(customer, from: storage) / Double(customerInvoices.count)
    }
    
    /// Gets last invoice date for customer
    static func lastInvoiceDateForCustomer(_ customer: Customer, from storage: InvoiceStorage) -> Date? {
        let customerInvoices = invoicesForCustomer(customer, from: storage)
        return customerInvoices.max(by: { $0.date < $1.date })?.date
    }
}

// MARK: - Customer Extensions for Invoice Integration
extension Customer {
    
    /// Returns invoices for this customer
    func invoices(from storage: InvoiceStorage) -> [Invoice] {
        return CustomerInvoiceIntegration.invoicesForCustomer(self, from: storage)
    }
    
    /// Returns total amount spent by this customer
    func totalSpent(from storage: InvoiceStorage) -> Double {
        return CustomerInvoiceIntegration.totalSpentByCustomer(self, from: storage)
    }
    
    /// Returns average invoice amount for this customer
    func averageInvoice(from storage: InvoiceStorage) -> Double {
        return CustomerInvoiceIntegration.averageInvoiceForCustomer(self, from: storage)
    }
    
    /// Returns last invoice date for this customer
    func lastInvoiceDate(from storage: InvoiceStorage) -> Date? {
        return CustomerInvoiceIntegration.lastInvoiceDateForCustomer(self, from: storage)
    }
    
    /// Returns number of invoices for this customer
    func invoiceCount(from storage: InvoiceStorage) -> Int {
        return invoices(from: storage).count
    }
    
    /// Creates a new invoice pre-filled with this customer's information
    func createInvoice() -> Invoice {
        return CustomerInvoiceIntegration.createInvoiceForCustomer(self)
    }
}

// MARK: - Invoice Extensions for Customer Integration
extension Invoice {
    
    /// Finds the customer associated with this invoice
    func findCustomer(from storage: CustomerStorage) -> Customer? {
        return storage.customers.first { customer in
            customer.displayName.lowercased() == self.clientName.lowercased()
        }
    }
    
    /// Updates customer information if customer exists
    mutating func syncWithCustomer(from storage: CustomerStorage) {
        if let customer = findCustomer(from: storage) {
            self.clientName = customer.displayName
            // Note: Invoice model doesn't store address, phone, email separately
            // This could be enhanced in the future by extending the Invoice model
        }
    }
}