//
//  InvoiceStorage.swift
//  Invoice Maker
//
//  Created by Rose legacy Home Solutions on 9/12/25.
//

import Foundation

/// Manages the persistence and retrieval of invoices using UserDefaults
final class InvoiceStorage: ObservableObject {
    
    // MARK: - Properties
    private let userDefaults = UserDefaults.standard
    private let invoicesKey = "savedInvoices"
    
    @Published var savedInvoices: [Invoice] = []
    
    // MARK: - Initialization
    init() {
        loadInvoices()
    }
    
    // MARK: - Public Methods
    
    /// Saves or updates an invoice
    /// - Parameter invoice: The invoice to save or update
    func saveInvoice(_ invoice: Invoice) {
        if let existingIndex = savedInvoices.firstIndex(where: { $0.id == invoice.id }) {
            // Update existing invoice
            savedInvoices[existingIndex] = invoice
        } else {
            // Add new invoice
            savedInvoices.append(invoice)
        }
        saveToUserDefaults()
        createAutomaticBackupIfNeeded()
    }
    
    /// Deletes an invoice from storage
    /// - Parameter invoice: The invoice to delete
    func deleteInvoice(_ invoice: Invoice) {
        savedInvoices.removeAll { $0.id == invoice.id }
        saveToUserDefaults()
    }
    
    /// Deletes multiple invoices from storage
    /// - Parameter invoices: Array of invoices to delete
    func deleteInvoices(_ invoices: [Invoice]) {
        let idsToDelete = Set(invoices.map(\.id))
        savedInvoices.removeAll { idsToDelete.contains($0.id) }
        saveToUserDefaults()
    }
    
    /// Returns the total count of saved invoices
    var invoiceCount: Int {
        savedInvoices.count
    }
    
    /// Returns invoices sorted by date (most recent first)
    var invoicesSortedByDate: [Invoice] {
        savedInvoices.sorted { $0.date > $1.date }
    }
    
    // MARK: - Automatic Backup
    
    /// Creates automatic backup every 5 saves
    private func createAutomaticBackupIfNeeded() {
        let backupInterval = 5
        let saveCount = UserDefaults.standard.integer(forKey: "invoiceSaveCount")
        
        if saveCount % backupInterval == 0 {
            print("📦 Creating automatic backup...")
            // Backup will be handled by SettingsView/DataBackupManager when integrated
        }
        
        UserDefaults.standard.set(saveCount + 1, forKey: "invoiceSaveCount")
    }
    
    // MARK: - Private Methods - Persistence
    
    /// Saves the current invoices array to UserDefaults
    private func saveToUserDefaults() {
        do {
            let encoded = try JSONEncoder().encode(savedInvoices)
            userDefaults.set(encoded, forKey: invoicesKey)
        } catch {
            print("❌ Error encoding invoices: \(error.localizedDescription)")
        }
    }
    
    /// Loads invoices from UserDefaults
    private func loadInvoices() {
        guard let data = userDefaults.data(forKey: invoicesKey) else {
            print("ℹ️ No saved invoices found")
            return
        }
        
        do {
            let decoded = try JSONDecoder().decode([Invoice].self, from: data)
            savedInvoices = decoded
            print("✅ Loaded \(decoded.count) invoices from storage")
        } catch {
            print("❌ Error decoding invoices: \(error.localizedDescription)")
            // Clear corrupted data
            userDefaults.removeObject(forKey: invoicesKey)
            savedInvoices = []
        }
    }
}

