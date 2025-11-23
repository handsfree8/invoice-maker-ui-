//
//  ValidationHelper.swift
//  Invoice Maker
//
//  Created by Rose Legacy Home Solutions
//

import Foundation

/// Provides validation utilities for form inputs across the application
struct ValidationHelper {
    
    // MARK: - Validation Results
    enum ValidationResult {
        case valid
        case invalid(String)
        
        var isValid: Bool {
            if case .valid = self { return true }
            return false
        }
        
        var errorMessage: String? {
            if case .invalid(let message) = self { return message }
            return nil
        }
    }
    
    // MARK: - Customer Validation
    
    /// Validates customer name
    static func validateName(_ name: String) -> ValidationResult {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            return .invalid("Name is required")
        }
        
        guard trimmed.count >= 2 else {
            return .invalid("Name must be at least 2 characters")
        }
        
        guard trimmed.count <= 100 else {
            return .invalid("Name is too long (max 100 characters)")
        }
        
        return .valid
    }
    
    /// Validates phone number
    static func validatePhone(_ phone: String) -> ValidationResult {
        let trimmed = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Phone is optional, but if provided must be valid
        guard !trimmed.isEmpty else {
            return .valid // Empty is acceptable
        }
        
        let digitsOnly = trimmed.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        guard digitsOnly.count == 10 else {
            return .invalid("Phone must be 10 digits")
        }
        
        return .valid
    }
    
    /// Validates email address
    static func validateEmail(_ email: String) -> ValidationResult {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Email is optional, but if provided must be valid
        guard !trimmed.isEmpty else {
            return .valid // Empty is acceptable
        }
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        guard emailPredicate.evaluate(with: trimmed) else {
            return .invalid("Invalid email format")
        }
        
        return .valid
    }
    
    /// Validates ZIP code
    static func validateZipCode(_ zipCode: String) -> ValidationResult {
        let trimmed = zipCode.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // ZIP is optional, but if provided must be valid
        guard !trimmed.isEmpty else {
            return .valid // Empty is acceptable
        }
        
        let digitsOnly = trimmed.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        guard digitsOnly.count == 5 else {
            return .invalid("ZIP code must be 5 digits")
        }
        
        return .valid
    }
    
    // MARK: - Invoice Validation
    
    /// Validates invoice number
    static func validateInvoiceNumber(_ number: String) -> ValidationResult {
        let trimmed = number.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            return .invalid("Invoice number is required")
        }
        
        guard trimmed.count >= 3 else {
            return .invalid("Invoice number too short")
        }
        
        guard trimmed.count <= 50 else {
            return .invalid("Invoice number too long (max 50 characters)")
        }
        
        return .valid
    }
    
    /// Validates client name for invoice
    static func validateClientName(_ name: String) -> ValidationResult {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            return .invalid("Client name is required")
        }
        
        guard trimmed.count >= 2 else {
            return .invalid("Client name must be at least 2 characters")
        }
        
        return .valid
    }
    
    /// Validates line item description
    static func validateItemDescription(_ description: String) -> ValidationResult {
        let trimmed = description.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            return .invalid("Item description is required")
        }
        
        guard trimmed.count >= 3 else {
            return .invalid("Description too short (min 3 characters)")
        }
        
        return .valid
    }
    
    /// Validates quantity
    static func validateQuantity(_ quantity: Double) -> ValidationResult {
        guard quantity > 0 else {
            return .invalid("Quantity must be greater than 0")
        }
        
        guard quantity <= 10000 else {
            return .invalid("Quantity too large (max 10,000)")
        }
        
        return .valid
    }
    
    /// Validates unit price
    static func validatePrice(_ price: Double) -> ValidationResult {
        guard price >= 0 else {
            return .invalid("Price cannot be negative")
        }
        
        guard price <= 1000000 else {
            return .invalid("Price too large (max $1,000,000)")
        }
        
        return .valid
    }
    
    /// Validates discount percentage
    static func validateDiscountPercentage(_ percentage: Double) -> ValidationResult {
        guard percentage >= 0 else {
            return .invalid("Discount cannot be negative")
        }
        
        guard percentage <= 100 else {
            return .invalid("Discount cannot exceed 100%")
        }
        
        return .valid
    }
    
    // MARK: - Authentication Validation
    
    /// Validates username
    static func validateUsername(_ username: String) -> ValidationResult {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            return .invalid("Username is required")
        }
        
        guard trimmed.count >= 3 else {
            return .invalid("Username must be at least 3 characters")
        }
        
        guard trimmed.count <= 50 else {
            return .invalid("Username too long (max 50 characters)")
        }
        
        return .valid
    }
    
    /// Validates password
    static func validatePassword(_ password: String) -> ValidationResult {
        guard !password.isEmpty else {
            return .invalid("Password is required")
        }
        
        guard password.count >= 6 else {
            return .invalid("Password must be at least 6 characters")
        }
        
        guard password.count <= 100 else {
            return .invalid("Password too long (max 100 characters)")
        }
        
        return .valid
    }
    
    /// Validates new password (stricter requirements)
    static func validateNewPassword(_ password: String) -> ValidationResult {
        guard !password.isEmpty else {
            return .invalid("Password is required")
        }
        
        guard password.count >= 8 else {
            return .invalid("Password must be at least 8 characters")
        }
        
        guard password.count <= 100 else {
            return .invalid("Password too long")
        }
        
        // Check for at least one number
        let hasNumber = password.rangeOfCharacter(from: .decimalDigits) != nil
        guard hasNumber else {
            return .invalid("Password must contain at least one number")
        }
        
        // Check for at least one letter
        let hasLetter = password.rangeOfCharacter(from: .letters) != nil
        guard hasLetter else {
            return .invalid("Password must contain at least one letter")
        }
        
        return .valid
    }
    
    /// Validates password confirmation matches
    static func validatePasswordConfirmation(_ password: String, confirmation: String) -> ValidationResult {
        guard password == confirmation else {
            return .invalid("Passwords do not match")
        }
        
        return .valid
    }
    
    // MARK: - Helper Functions
    
    /// Formats phone number for display
    static func formatPhoneNumber(_ phone: String) -> String {
        let digitsOnly = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        guard digitsOnly.count == 10 else {
            return phone
        }
        
        let areaCode = String(digitsOnly.prefix(3))
        let firstThree = String(digitsOnly.dropFirst(3).prefix(3))
        let lastFour = String(digitsOnly.suffix(4))
        
        return "(\(areaCode)) \(firstThree)-\(lastFour)"
    }
    
    /// Cleans phone number to digits only
    static func cleanPhoneNumber(_ phone: String) -> String {
        return phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
}
