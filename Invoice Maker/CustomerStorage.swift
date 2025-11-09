import Foundation
import SwiftUI

import Foundation

// MARK: - Customer Sort Options
enum CustomerSortOption: String, CaseIterable {
    case name = "Name"
    case dateAdded = "Date Added"
    case lastService = "Last Service"
    
    var systemImage: String {
        switch self {
        case .name: return "textformat.abc"
        case .dateAdded: return "calendar"
        case .lastService: return "wrench.and.screwdriver"
        }
    }
}

/// Manages persistent storage of customer data using UserDefaults
final class CustomerStorage: ObservableObject {
    
    // MARK: - Properties
    private let userDefaults = UserDefaults.standard
    private let customersKey = "savedCustomers"
    
    @Published var customers: [Customer] = []
    
    // MARK: - Initialization
    init() {
        loadCustomers()
    }
    
    // MARK: - Public Methods
    
    /// Saves or updates a customer
    /// - Parameter customer: The customer to save or update
    func saveCustomer(_ customer: Customer) {
        if let existingIndex = customers.firstIndex(where: { $0.id == customer.id }) {
            // Update existing customer
            customers[existingIndex] = customer
        } else {
            // Add new customer
            customers.append(customer)
        }
        saveToUserDefaults()
    }
    
    /// Deletes a customer from storage
    /// - Parameter customer: The customer to delete
    func deleteCustomer(_ customer: Customer) {
        customers.removeAll { $0.id == customer.id }
        saveToUserDefaults()
    }
    
    /// Searches customers by name or phone
    /// - Parameter query: The search query
    /// - Returns: Array of matching customers
    func searchCustomers(_ query: String) -> [Customer] {
        guard !query.isEmpty else { return customers }
        
        let lowercaseQuery = query.lowercased()
        return customers.filter { customer in
            customer.name.lowercased().contains(lowercaseQuery) ||
            customer.phone.contains(query) ||
            customer.email.lowercased().contains(lowercaseQuery) ||
            customer.city.lowercased().contains(lowercaseQuery)
        }
    }
    
    /// Gets customers sorted by various criteria
    func getCustomers(sortedBy sortOption: CustomerSortOption) -> [Customer] {
        switch sortOption {
        case .name:
            return customers.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .dateAdded:
            return customers.sorted { $0.dateAdded > $1.dateAdded }
        case .lastService:
            return customers.sorted { (customer1, customer2) in
                let date1 = customer1.lastServiceDate ?? Date.distantPast
                let date2 = customer2.lastServiceDate ?? Date.distantPast
                return date1 > date2
            }
        }
    }
    
    /// Gets recent customers (added in last 30 days)
    var recentCustomers: [Customer] {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return customers.filter { $0.dateAdded > thirtyDaysAgo }
            .sorted { $0.dateAdded > $1.dateAdded }
    }
    
    /// Gets customers who haven't been serviced in a while
    var customersNeedingFollowUp: [Customer] {
        let sixMonthsAgo = Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date()
        return customers.filter { customer in
            if let lastService = customer.lastServiceDate {
                return lastService < sixMonthsAgo
            }
            return customer.dateAdded < sixMonthsAgo
        }
    }
    
    /// Updates last service date for a customer
    /// - Parameters:
    ///   - customerId: The customer ID
    ///   - date: The service date
    func updateLastServiceDate(for customerId: UUID, date: Date) {
        if let index = customers.firstIndex(where: { $0.id == customerId }) {
            customers[index].lastServiceDate = date
            saveToUserDefaults()
        }
    }
    
    /// Gets service history for a customer from invoices
    /// - Parameters:
    ///   - customer: The customer
    ///   - invoices: All invoices to search through
    /// - Returns: Service record with history
    func getServiceHistory(for customer: Customer, from invoices: [Invoice]) -> CustomerServiceRecord {
        let customerInvoices = invoices.filter { 
            $0.clientName.lowercased() == customer.name.lowercased() 
        }
        return CustomerServiceRecord(customerId: customer.id, invoices: customerInvoices)
    }
    
    /// Adds sample customers for testing
    func addSampleCustomers() {
        Customer.sampleCustomers.forEach { customer in
            if !customers.contains(where: { $0.name == customer.name }) {
                saveCustomer(customer)
            }
        }
    }
    
    // MARK: - Private Methods - Persistence
    
    /// Saves the current customers array to UserDefaults
    private func saveToUserDefaults() {
        do {
            let encoded = try JSONEncoder().encode(customers)
            userDefaults.set(encoded, forKey: customersKey)
        } catch {
            print("❌ Error encoding customers: \(error.localizedDescription)")
        }
    }
    
    /// Loads customers from UserDefaults
    private func loadCustomers() {
        guard let data = userDefaults.data(forKey: customersKey) else {
            print("ℹ️ No saved customers found")
            return
        }
        
        do {
            let decoded = try JSONDecoder().decode([Customer].self, from: data)
            customers = decoded
            print("✅ Loaded \(decoded.count) customers from storage")
        } catch {
            print("❌ Error decoding customers: \(error.localizedDescription)")
            // Clear corrupted data
            userDefaults.removeObject(forKey: customersKey)
            customers = []
        }
    }
}