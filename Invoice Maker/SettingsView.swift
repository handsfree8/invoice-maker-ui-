//
//  SettingsView.swift
//  Invoice Maker
//
//  Created by Rose Legacy Home Solutions
//

import SwiftUI

struct SettingsView: View {
    // MARK: - Properties
    @EnvironmentObject private var authManager: AuthenticationManager
    @ObservedObject var invoiceStorage: InvoiceStorage
    @ObservedObject var customerStorage: CustomerStorage
    @StateObject private var backupManager = DataBackupManager()
    
    @State private var showingChangePassword = false
    @State private var showingBackupOptions = false
    @State private var showingRestoreAlert = false
    @State private var showingExportSuccess = false
    @State private var exportMessage = ""
    @State private var shareURL: URL?
    @State private var showingShareSheet = false
    @State private var showingDocumentPicker = false
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            List {
                accountSection
                dataManagementSection
                backupSection
                appInfoSection
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingChangePassword) {
                ChangePasswordView()
                    .environmentObject(authManager)
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = shareURL {
                    ShareSheet(activityItems: [url])
                }
            }
            .alert("Export Successful", isPresented: $showingExportSuccess) {
                Button("OK") {
                    exportMessage = ""
                }
            } message: {
                Text(exportMessage)
            }
            .alert("Restore Data", isPresented: $showingRestoreAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Restore", role: .destructive) {
                    restoreFromBackup()
                }
            } message: {
                Text("This will replace all current data with the backup. This action cannot be undone.")
            }
        }
    }
}

// MARK: - View Sections
extension SettingsView {
    
    /// Account management section
    private var accountSection: some View {
        Section("Account") {
            HStack {
                Label("User", systemImage: "person.circle.fill")
                    .foregroundColor(.blue)
                Spacer()
                Text(authManager.getUserDisplayName())
                    .foregroundColor(.secondary)
            }
            
            Button {
                showingChangePassword = true
            } label: {
                Label("Change Password", systemImage: "key.fill")
                    .foregroundColor(.blue)
            }
            
            Button(role: .destructive) {
                authManager.logout()
            } label: {
                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
            }
        }
    }
    
    /// Data management section
    private var dataManagementSection: some View {
        Section {
            HStack {
                Label("Total Invoices", systemImage: "doc.text")
                    .foregroundColor(.green)
                Spacer()
                Text("\(invoiceStorage.savedInvoices.count)")
                    .foregroundColor(.secondary)
                    .bold()
            }
            
            HStack {
                Label("Total Customers", systemImage: "person.2")
                    .foregroundColor(.purple)
                Spacer()
                Text("\(customerStorage.customers.count)")
                    .foregroundColor(.secondary)
                    .bold()
            }
            
            if let totalRevenue = calculateTotalRevenue() {
                HStack {
                    Label("Total Revenue", systemImage: "dollarsign.circle")
                        .foregroundColor(.orange)
                    Spacer()
                    Text(totalRevenue, format: .currency(code: "USD"))
                        .foregroundColor(.secondary)
                        .bold()
                }
            }
        } header: {
            Text("Statistics")
        }
    }
    
    /// Backup and export section
    private var backupSection: some View {
        Section {
            Button {
                exportFullBackup()
            } label: {
                Label("Export Complete Backup (JSON)", systemImage: "square.and.arrow.up")
            }
            
            Button {
                exportInvoicesCSV()
            } label: {
                Label("Export Invoices (CSV)", systemImage: "tablecells")
            }
            
            Button {
                exportCustomersCSV()
            } label: {
                Label("Export Customers (CSV)", systemImage: "person.2.badge.gearshape")
            }
            
            Divider()
            
            Button {
                showingDocumentPicker = true
            } label: {
                Label("Import Backup", systemImage: "square.and.arrow.down")
                    .foregroundColor(.blue)
            }
            
            Button {
                createAutomaticBackup()
            } label: {
                Label("Create Manual Backup", systemImage: "externaldrive.badge.checkmark")
                    .foregroundColor(.green)
            }
            
        } header: {
            Text("Backup & Export")
        } footer: {
            Text("Backups include all invoices and customers. Export to CSV for spreadsheet compatibility.")
                .font(.caption)
        }
    }
    
    /// App information section
    private var appInfoSection: some View {
        Section {
            HStack {
                Label("Version", systemImage: "info.circle")
                Spacer()
                Text("1.0.0")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Label("Build", systemImage: "hammer")
                Spacer()
                Text("2025.11.19")
                    .foregroundColor(.secondary)
            }
            
            Link(destination: URL(string: "tel://8162984828")!) {
                Label("Support: (816) 298-4828", systemImage: "phone.fill")
            }
            
            Link(destination: URL(string: "mailto:appointments@roselegacyhvac.com")!) {
                Label("Email Support", systemImage: "envelope.fill")
            }
            
        } header: {
            Text("About")
        } footer: {
            VStack(alignment: .center, spacing: 8) {
                Text("Rose Legacy Home Solutions LLC")
                    .font(.caption)
                    .bold()
                Text("HVAC • Plumbing • Appliances • Remodeling")
                    .font(.caption2)
                Text("© 2025 All Rights Reserved")
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
        }
    }
}

// MARK: - Actions
extension SettingsView {
    
    /// Exports complete backup in JSON format
    private func exportFullBackup() {
        let result = backupManager.exportToJSON(
            invoices: invoiceStorage.savedInvoices,
            customers: customerStorage.customers
        )
        
        switch result {
        case .success(let url):
            shareURL = url
            showingShareSheet = true
            exportMessage = "Backup exported successfully!\n\nFile: \(url.lastPathComponent)"
            
        case .failure(let error):
            exportMessage = "Export failed: \(error.localizedDescription)"
            showingExportSuccess = true
        }
    }
    
    /// Exports invoices to CSV
    private func exportInvoicesCSV() {
        let result = backupManager.exportInvoicesToCSV(invoices: invoiceStorage.savedInvoices)
        
        switch result {
        case .success(let url):
            shareURL = url
            showingShareSheet = true
            exportMessage = "Invoices exported to CSV!\n\nFile: \(url.lastPathComponent)"
            
        case .failure(let error):
            exportMessage = "Export failed: \(error.localizedDescription)"
            showingExportSuccess = true
        }
    }
    
    /// Exports customers to CSV
    private func exportCustomersCSV() {
        let result = backupManager.exportCustomersToCSV(customers: customerStorage.customers)
        
        switch result {
        case .success(let url):
            shareURL = url
            showingShareSheet = true
            exportMessage = "Customers exported to CSV!\n\nFile: \(url.lastPathComponent)"
            
        case .failure(let error):
            exportMessage = "Export failed: \(error.localizedDescription)"
            showingExportSuccess = true
        }
    }
    
    /// Creates automatic backup
    private func createAutomaticBackup() {
        let result = backupManager.createAutomaticBackup(
            invoices: invoiceStorage.savedInvoices,
            customers: customerStorage.customers
        )
        
        switch result {
        case .success(let url):
            exportMessage = "Manual backup created successfully!\n\nLocation: Documents folder\nFile: \(url.lastPathComponent)"
            showingExportSuccess = true
            
        case .failure(let error):
            exportMessage = "Backup failed: \(error.localizedDescription)"
            showingExportSuccess = true
        }
    }
    
    /// Restores data from latest automatic backup
    private func restoreFromBackup() {
        let result = backupManager.getLatestAutomaticBackup()
        
        switch result {
        case .success(let backup):
            // Restore invoices
            backup.invoices.forEach { invoice in
                invoiceStorage.saveInvoice(invoice)
            }
            
            // Restore customers
            backup.customers.forEach { customer in
                customerStorage.saveCustomer(customer)
            }
            
            exportMessage = "Data restored successfully!\n\nInvoices: \(backup.invoices.count)\nCustomers: \(backup.customers.count)"
            showingExportSuccess = true
            
        case .failure(let error):
            exportMessage = "Restore failed: \(error.localizedDescription)"
            showingExportSuccess = true
        }
    }
    
    /// Calculates total revenue from all invoices
    private func calculateTotalRevenue() -> Double? {
        guard !invoiceStorage.savedInvoices.isEmpty else { return nil }
        return invoiceStorage.savedInvoices.reduce(0) { $0 + $1.total }
    }
}

// MARK: - Change Password View
struct ChangePasswordView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingSuccess = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    SecureField("Current Password", text: $currentPassword)
                        .textContentType(.password)
                } header: {
                    Text("Verify Identity")
                }
                
                Section {
                    SecureField("New Password", text: $newPassword)
                        .textContentType(.newPassword)
                    
                    SecureField("Confirm New Password", text: $confirmPassword)
                        .textContentType(.newPassword)
                } header: {
                    Text("New Password")
                } footer: {
                    Text("Password must be at least 8 characters and contain at least one number and one letter.")
                        .font(.caption)
                }
                
                Section {
                    Button("Change Password") {
                        changePassword()
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(!canSubmit)
                }
            }
            .navigationTitle("Change Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .alert("Success", isPresented: $showingSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Password changed successfully!")
            }
        }
    }
    
    private var canSubmit: Bool {
        !currentPassword.isEmpty && !newPassword.isEmpty && !confirmPassword.isEmpty
    }
    
    private func changePassword() {
        // Validate current password
        guard authManager.login(username: authManager.currentUser, password: currentPassword) else {
            errorMessage = "Current password is incorrect"
            showingError = true
            return
        }
        
        // Validate new password
        let passwordValidation = ValidationHelper.validateNewPassword(newPassword)
        guard passwordValidation.isValid else {
            errorMessage = passwordValidation.errorMessage ?? "Invalid password"
            showingError = true
            return
        }
        
        // Validate confirmation
        let confirmValidation = ValidationHelper.validatePasswordConfirmation(newPassword, confirmation: confirmPassword)
        guard confirmValidation.isValid else {
            errorMessage = confirmValidation.errorMessage ?? "Passwords do not match"
            showingError = true
            return
        }
        
        // Update password (in production, this would call a secure API)
        // For now, we'll just show success
        showingSuccess = true
        
        // TODO: Implement actual password change in AuthenticationManager
        print("🔐 Password would be changed here in production")
    }
}

// MARK: - Preview
#Preview {
    SettingsView(
        invoiceStorage: InvoiceStorage(),
        customerStorage: CustomerStorage()
    )
    .environmentObject(AuthenticationManager.previewAuthenticated)
}
