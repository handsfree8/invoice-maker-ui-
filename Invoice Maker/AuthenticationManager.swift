//
//  AuthenticationManager.swift
//  Invoice Maker
//
//  Created by Rose Legacy Home Solutions
//

import SwiftUI
import Security

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: String = ""
    
    // Credenciales predefinidas (en producción deberían estar más seguras)
    private let validCredentials = [
        "admin": "RoseLegacy2025",
        "usuario": "Invoice2025",
        "roselegacy": "HomesSolutions"
    ]
    
    private let keychainService = "com.roselegacy.invoicemaker"
    private let keychainAccount = "user_session"
    
    init() {
        // Para desarrollo: descomenta la siguiente línea si quieres forzar logout al iniciar
        deleteSessionFromKeychain() // <- Temporalmente activado para testing
        checkExistingSession()
    }
    
    // MARK: - Public Methods
    
    func login(username: String, password: String) -> Bool {
        // Validar credenciales
        guard let validPassword = validCredentials[username.lowercased()],
              validPassword == password else {
            return false
        }
        
        // Login exitoso
        currentUser = username.lowercased()
        isAuthenticated = true
        
        // Guardar sesión en Keychain
        saveSessionToKeychain()
        
        return true
    }
    
    func logout() {
        isAuthenticated = false
        currentUser = ""
        
        // Eliminar sesión del Keychain
        deleteSessionFromKeychain()
    }
    
    func getUserDisplayName() -> String {
        switch currentUser {
        case "admin":
            return "Administrador"
        case "usuario":
            return "Usuario"
        case "roselegacy":
            return "Rose Legacy"
        default:
            return currentUser.capitalized
        }
    }
    
    /// Clears all sessions (useful for development/testing)
    func clearAllSessions() {
        logout()
        deleteSessionFromKeychain()
    }
    
    // MARK: - Private Methods
    
    private func checkExistingSession() {
        if let sessionData = loadSessionFromKeychain(),
           let username = String(data: sessionData, encoding: .utf8),
           validCredentials.keys.contains(username) {
            currentUser = username
            isAuthenticated = true
        }
    }
    
    // MARK: - Keychain Operations
    
    private func saveSessionToKeychain() {
        guard let data = currentUser.data(using: .utf8) else { return }
        
        // Eliminar entrada existente
        deleteSessionFromKeychain()
        
        // Agregar nueva entrada
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecValueData as String: data
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            print("Error saving to Keychain: \(status)")
        }
    }
    
    private func loadSessionFromKeychain() -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess {
            return result as? Data
        }
        
        return nil
    }
    
    private func deleteSessionFromKeychain() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - Preview Helper
extension AuthenticationManager {
    static var preview: AuthenticationManager {
        let manager = AuthenticationManager()
        manager.isAuthenticated = false
        return manager
    }
    
    static var previewAuthenticated: AuthenticationManager {
        let manager = AuthenticationManager()
        manager.isAuthenticated = true
        manager.currentUser = "admin"
        return manager
    }
}