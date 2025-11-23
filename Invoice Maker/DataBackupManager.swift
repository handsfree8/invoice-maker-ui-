//
//  DataBackupManager.swift
//  Invoice Maker
//
//  Created by Rose Legacy Home Solutions
//

import Foundation
import SwiftUI

/// Manages data backup, export, and import functionality for the application
final class DataBackupManager: ObservableObject {
    
    // MARK: - Backup Types
    enum BackupFormat {
        case json
        case csv
    }
    
    enum BackupError: LocalizedError {
        case exportFailed(String)
        case importFailed(String)
        case invalidData
        case fileNotFound
        
        var errorDescription: String? {
            switch self {
            case .exportFailed(let reason):
                return "Export failed: \(reason)"
            case .importFailed(let reason):
                return "Import failed: \(reason)"
            case .invalidData:
                return "Invalid or corrupted backup data"
            case .fileNotFound:
                return "Backup file not found"
            }
        }
    }
    
    // MARK: - Backup Data Structure
    struct AppBackup: Codable {
        let version: String
        let exportDate: Date
        let invoices: [Invoice]
        let customers: [Customer]
        
        var metadata: BackupMetadata {
            BackupMetadata(
                version: version,
                exportDate: exportDate,
                invoiceCount: invoices.count,
                customerCount: customers.count
            )
        }
    }
    
    struct BackupMetadata: Codable {
        let version: String
        let exportDate: Date
        let invoiceCount: Int
        let customerCount: Int
    }
    
    // MARK: - Properties
    private let currentVersion = "1.0.0"
    
    // MARK: - Export Functions
    
    /// Exports all data to JSON format
    func exportToJSON(
        invoices: [Invoice],
        customers: [Customer]
    ) -> Result<URL, BackupError> {
        let backup = AppBackup(
            version: currentVersion,
            exportDate: Date(),
            invoices: invoices,
            customers: customers
        )
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            
            let data = try encoder.encode(backup)
            let url = try saveBackupFile(data: data, format: "json")
            
            print("✅ Backup exported successfully to: \(url.lastPathComponent)")
            return .success(url)
            
        } catch {
            print("❌ Export failed: \(error.localizedDescription)")
            return .failure(.exportFailed(error.localizedDescription))
        }
    }
    
    /// Exports invoices to CSV format
    func exportInvoicesToCSV(invoices: [Invoice]) -> Result<URL, BackupError> {
        do {
            var csvString = "Invoice Number,Date,Client Name,Subtotal,Discount,Tax,Total,Payment Method,Terms,Notes\n"
            
            for invoice in invoices {
                let row = [
                    invoice.number,
                    formatDate(invoice.date),
                    escapeCSV(invoice.clientName),
                    String(format: "%.2f", invoice.subTotal),
                    String(format: "%.2f", invoice.discount),
                    String(format: "%.2f", invoice.tax),
                    String(format: "%.2f", invoice.total),
                    invoice.paymentMethod?.rawValue ?? "",
                    escapeCSV(invoice.terms ?? ""),
                    escapeCSV(invoice.notes)
                ]
                csvString += row.joined(separator: ",") + "\n"
            }
            
            guard let data = csvString.data(using: .utf8) else {
                return .failure(.exportFailed("Failed to convert CSV to data"))
            }
            
            let url = try saveBackupFile(data: data, format: "csv", prefix: "invoices")
            print("✅ Invoices exported to CSV: \(url.lastPathComponent)")
            return .success(url)
            
        } catch {
            return .failure(.exportFailed(error.localizedDescription))
        }
    }
    
    /// Exports customers to CSV format
    func exportCustomersToCSV(customers: [Customer]) -> Result<URL, BackupError> {
        do {
            var csvString = "Name,Phone,Email,Address,City,Zip Code,Date Added,Last Service Date,Notes\n"
            
            for customer in customers {
                let row = [
                    escapeCSV(customer.name),
                    customer.phone,
                    customer.email,
                    escapeCSV(customer.address),
                    escapeCSV(customer.city),
                    customer.zipCode,
                    formatDate(customer.dateAdded),
                    customer.lastServiceDate != nil ? formatDate(customer.lastServiceDate!) : "",
                    escapeCSV(customer.notes)
                ]
                csvString += row.joined(separator: ",") + "\n"
            }
            
            guard let data = csvString.data(using: .utf8) else {
                return .failure(.exportFailed("Failed to convert CSV to data"))
            }
            
            let url = try saveBackupFile(data: data, format: "csv", prefix: "customers")
            print("✅ Customers exported to CSV: \(url.lastPathComponent)")
            return .success(url)
            
        } catch {
            return .failure(.exportFailed(error.localizedDescription))
        }
    }
    
    // MARK: - Import Functions
    
    /// Imports backup data from JSON file
    func importFromJSON(url: URL) -> Result<AppBackup, BackupError> {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let backup = try decoder.decode(AppBackup.self, from: data)
            
            print("✅ Backup imported successfully")
            print("   Version: \(backup.version)")
            print("   Invoices: \(backup.invoices.count)")
            print("   Customers: \(backup.customers.count)")
            
            return .success(backup)
            
        } catch {
            print("❌ Import failed: \(error.localizedDescription)")
            return .failure(.importFailed(error.localizedDescription))
        }
    }
    
    /// Validates backup data before importing
    func validateBackup(url: URL) -> Result<BackupMetadata, BackupError> {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let backup = try decoder.decode(AppBackup.self, from: data)
            return .success(backup.metadata)
            
        } catch {
            return .failure(.invalidData)
        }
    }
    
    // MARK: - Automatic Backup
    
    /// Creates an automatic backup in the app's documents directory
    func createAutomaticBackup(
        invoices: [Invoice],
        customers: [Customer]
    ) -> Result<URL, BackupError> {
        let backup = AppBackup(
            version: currentVersion,
            exportDate: Date(),
            invoices: invoices,
            customers: customers
        )
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            
            let data = try encoder.encode(backup)
            let url = try saveAutomaticBackup(data: data)
            
            print("✅ Automatic backup created: \(url.lastPathComponent)")
            return .success(url)
            
        } catch {
            print("❌ Automatic backup failed: \(error.localizedDescription)")
            return .failure(.exportFailed(error.localizedDescription))
        }
    }
    
    /// Gets the most recent automatic backup
    func getLatestAutomaticBackup() -> Result<AppBackup, BackupError> {
        do {
            let documentsURL = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )
            
            let backupURL = documentsURL.appendingPathComponent("automatic_backup.json")
            
            guard FileManager.default.fileExists(atPath: backupURL.path) else {
                return .failure(.fileNotFound)
            }
            
            let data = try Data(contentsOf: backupURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let backup = try decoder.decode(AppBackup.self, from: data)
            return .success(backup)
            
        } catch {
            return .failure(.importFailed(error.localizedDescription))
        }
    }
    
    // MARK: - Helper Functions
    
    /// Saves backup file to documents directory
    private func saveBackupFile(data: Data, format: String, prefix: String = "backup") throws -> URL {
        let documentsURL = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HHmmss"
        let timestamp = dateFormatter.string(from: Date())
        
        let fileName = "\(prefix)_RoseLegacy_\(timestamp).\(format)"
        let fileURL = documentsURL.appendingPathComponent(fileName)
        
        try data.write(to: fileURL, options: [.atomic])
        
        return fileURL
    }
    
    /// Saves automatic backup (overwrites existing)
    private func saveAutomaticBackup(data: Data) throws -> URL {
        let documentsURL = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        
        let fileURL = documentsURL.appendingPathComponent("automatic_backup.json")
        try data.write(to: fileURL, options: [.atomic])
        
        return fileURL
    }
    
    /// Escapes CSV special characters
    private func escapeCSV(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            return "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return value
    }
    
    /// Formats date for CSV export
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
