//
//  BiometricAuthManager.swift
//  Invoice Maker
//
//  Created by Rose Legacy Home Solutions
//

import SwiftUI
import LocalAuthentication

/// Manager for handling biometric authentication (Face ID / Touch ID)
class BiometricAuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var biometricType: BiometricType = .none
    
    private let context = LAContext()
    private let reason = "Authenticate to access your invoices securely"
    
    enum BiometricType {
        case none
        case faceID
        case touchID
        
        var displayName: String {
            switch self {
            case .none: return "None"
            case .faceID: return "Face ID"
            case .touchID: return "Touch ID"
            }
        }
        
        var icon: String {
            switch self {
            case .none: return "lock.fill"
            case .faceID: return "faceid"
            case .touchID: return "touchid"
            }
        }
    }
    
    enum BiometricError: LocalizedError {
        case notAvailable
        case notEnrolled
        case failed
        case cancelled
        case lockout
        case systemError(Error)
        
        var errorDescription: String? {
            switch self {
            case .notAvailable:
                return "Biometric authentication is not available on this device"
            case .notEnrolled:
                return "No biometric authentication is set up. Please set up Face ID or Touch ID in Settings"
            case .failed:
                return "Authentication failed. Please try again"
            case .cancelled:
                return "Authentication was cancelled"
            case .lockout:
                return "Too many failed attempts. Please try again later"
            case .systemError(let error):
                return error.localizedDescription
            }
        }
    }
    
    // MARK: - Initialization
    
    init() {
        checkBiometricAvailability()
    }
    
    // MARK: - Public Methods
    
    /// Checks if biometric authentication is available
    func checkBiometricAvailability() {
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            biometricType = .none
            return
        }
        
        // Determine biometric type
        switch context.biometryType {
        case .faceID:
            biometricType = .faceID
        case .touchID:
            biometricType = .touchID
        case .none:
            biometricType = .none
        @unknown default:
            biometricType = .none
        }
    }
    
    /// Checks if biometric authentication is available
    var isBiometricAvailable: Bool {
        biometricType != .none
    }
    
    /// Authenticates user with biometrics
    func authenticate(completion: @escaping (Result<Bool, BiometricError>) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        // Check if biometric authentication is available
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            if let error = error {
                handleLAError(error, completion: completion)
            } else {
                completion(.failure(.notAvailable))
            }
            return
        }
        
        // Perform authentication
        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: reason
        ) { success, authenticationError in
            DispatchQueue.main.async {
                if success {
                    self.isAuthenticated = true
                    completion(.success(true))
                } else if let error = authenticationError as? LAError {
                    self.handleLAError(error, completion: completion)
                } else {
                    completion(.failure(.failed))
                }
            }
        }
    }
    
    /// Authenticates with biometrics or falls back to passcode
    func authenticateWithFallback(completion: @escaping (Result<Bool, BiometricError>) -> Void) {
        let context = LAContext()
        context.localizedFallbackTitle = "Use Passcode"
        
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            if let error = error {
                handleLAError(error, completion: completion)
            } else {
                completion(.failure(.notAvailable))
            }
            return
        }
        
        context.evaluatePolicy(
            .deviceOwnerAuthentication,
            localizedReason: reason
        ) { success, authenticationError in
            DispatchQueue.main.async {
                if success {
                    self.isAuthenticated = true
                    completion(.success(true))
                } else if let error = authenticationError as? LAError {
                    self.handleLAError(error, completion: completion)
                } else {
                    completion(.failure(.failed))
                }
            }
        }
    }
    
    /// Resets authentication state
    func logout() {
        isAuthenticated = false
    }
    
    // MARK: - Private Methods
    
    private func handleLAError(_ error: Error, completion: @escaping (Result<Bool, BiometricError>) -> Void) {
        guard let laError = error as? LAError else {
            completion(.failure(.systemError(error)))
            return
        }
        
        switch laError.code {
        case .authenticationFailed:
            completion(.failure(.failed))
        case .userCancel, .userFallback, .systemCancel:
            completion(.failure(.cancelled))
        case .biometryNotAvailable:
            completion(.failure(.notAvailable))
        case .biometryNotEnrolled:
            completion(.failure(.notEnrolled))
        case .biometryLockout:
            completion(.failure(.lockout))
        default:
            completion(.failure(.systemError(error)))
        }
    }
}

// MARK: - Preview Helper
extension BiometricAuthManager {
    static var preview: BiometricAuthManager {
        let manager = BiometricAuthManager()
        manager.biometricType = .faceID
        return manager
    }
}
