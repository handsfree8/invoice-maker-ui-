//
//  LoginView.swift
//  Invoice Maker
//
//  Created by Rose Legacy Home Solutions
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0.0
    @State private var formOffset: CGFloat = 50
    @State private var formOpacity: Double = 0.0
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case username
        case password
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                ZStack {
                    // Background gradient Rose Legacy colors
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.purple.opacity(0.12),
                            Color(.systemBackground),
                            Color.purple.opacity(0.08)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: max(geometry.size.height, 800))
                    
                    // Círculos de fondo con colores Rose Legacy
                    ZStack {
                        Circle()
                            .fill(Color.purple.opacity(0.06))
                            .frame(width: 300, height: 300)
                            .offset(x: -120, y: -250)
                            .scaleEffect(logoScale * 0.8)
                        
                        Circle()
                            .fill(Color.white.opacity(0.08))
                            .frame(width: 200, height: 200)
                            .offset(x: 150, y: 150)
                            .scaleEffect(logoScale * 1.2)
                        
                        Circle()
                            .fill(Color.purple.opacity(0.04))
                            .frame(width: 400, height: 400)
                            .offset(x: 50, y: 350)
                            .scaleEffect(logoScale * 0.6)
                    }
                    
                    VStack(spacing: 40) {
                        Spacer()
                            .frame(height: 60)
                        
                        // Enhanced Logo Section
                        logoSection
                        
                        // Enhanced Login Form
                        loginFormSection
                        
                        Spacer()
                            .frame(height: 60)
                        
                        // Enhanced Footer
                        footerSection
                    }
                    .frame(minHeight: geometry.size.height)
                }
            }
            .ignoresSafeArea(.keyboard)
        }
        .onAppear {
            startAnimations()
        }
        .alert("Access Denied", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focusedField = nil
                }
            }
        }
    }
    
    private func startAnimations() {
        // Logo animation with spring effect
        withAnimation(.spring(response: 1.2, dampingFraction: 0.6, blendDuration: 0)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Form animation with elegant ease (delayed)
        withAnimation(.easeOut(duration: 0.8).delay(0.6)) {
            formOffset = 0
            formOpacity = 1.0
        }
    }
}

// MARK: - View Components
extension LoginView {
    
    /// Enhanced logo section matching splash screen style
    private var logoSection: some View {
        VStack(spacing: 20) {
            // Logo container con colores Rose Legacy
            ZStack {
                // Glow effect con morado suave
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.purple.opacity(0.15),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .opacity(logoOpacity * 0.8)
                
                // Logo con bordes morados suaves
                Image("rl-logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.primary.opacity(0.2),
                                        Color.purple.opacity(0.3)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 8)
                    .shadow(color: Color.purple.opacity(0.2), radius: 25, x: 0, y: 0)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
            }
            
            // Company information con colores adaptados
            VStack(spacing: 12) {
                Text("Rose Legacy")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.primary,
                                Color.primary.opacity(0.8)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                
                Text("Home Solutions")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
                    .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 1)
                
                // Divider con colores Rose Legacy
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.clear,
                                Color.purple.opacity(0.4),
                                Color.clear
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 120, height: 1.5)
                
                Text("Invoice Manager")
                    .font(.system(size: 16, weight: .light, design: .rounded))
                    .foregroundColor(.secondary)
                    .italic()
            }
            .opacity(logoOpacity)
        }
    }
    
    /// Enhanced login form section
    private var loginFormSection: some View {
        VStack(spacing: 24) {
            // Username Field con colores adaptados
            VStack(alignment: .leading, spacing: 10) {
                Label("Username", systemImage: "person.circle.fill")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.primary.opacity(0.8))
                    .shadow(color: .black.opacity(0.08), radius: 1, x: 0, y: 1)
                
                TextField("Enter your username", text: $username)
                    .textFieldStyle(EnhancedTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textContentType(.username)
                    .submitLabel(.next)
                    .focused($focusedField, equals: .username)
                    .onSubmit {
                        focusedField = .password
                    }
            }
            
            // Password Field con colores adaptados
            VStack(alignment: .leading, spacing: 10) {
                Label("Password", systemImage: "lock.shield.fill")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.primary.opacity(0.8))
                    .shadow(color: .black.opacity(0.08), radius: 1, x: 0, y: 1)
                
                SecureField("Enter your password", text: $password)
                    .textFieldStyle(EnhancedTextFieldStyle())
                    .textContentType(.password)
                    .submitLabel(.go)
                    .focused($focusedField, equals: .password)
                    .onSubmit {
                        if !username.isEmpty && !password.isEmpty {
                            handleLogin()
                        }
                    }
            }
            
            // Enhanced Login Button con estilo Rose Legacy
            Button(action: handleLogin) {
                HStack(spacing: 12) {
                    if isLoading {
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.4), lineWidth: 2)
                                .frame(width: 20, height: 20)
                            
                            Circle()
                                .trim(from: 0, to: 0.7)
                                .stroke(Color.white, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                                .frame(width: 20, height: 20)
                                .rotationEffect(.degrees(logoScale * 360))
                                .animation(
                                    Animation.linear(duration: 1.0).repeatForever(autoreverses: false),
                                    value: logoScale
                                )
                        }
                    } else {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 16, weight: .medium))
                    }
                    
                    Text(isLoading ? "Verifying..." : "Sign In")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(
                    ZStack {
                        // Background gradient con colores Rose Legacy
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.purple.opacity(0.9),
                                Color.purple,
                                Color.purple.opacity(0.8)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        
                        // Inner glow suave
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.15),
                                Color.clear
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                )
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
                .shadow(color: Color.purple.opacity(0.3), radius: 15, x: 0, y: 0)
                .scaleEffect(isLoading ? 0.98 : 1.0)
            }
            .disabled(isLoading || username.isEmpty || password.isEmpty)
            .opacity(username.isEmpty || password.isEmpty ? 0.6 : 1.0)
        }
        .padding(.horizontal, 40)
        .offset(y: formOffset)
        .opacity(formOpacity)
    }
    
    /// Enhanced footer section
    private var footerSection: some View {
        VStack(spacing: 12) {
            Text("Business Application")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .shadow(color: .black.opacity(0.08), radius: 1, x: 0, y: 1)
            
            Text("© 2025 Rose Legacy Home Solutions")
                .font(.system(size: 12, weight: .light, design: .rounded))
                .foregroundColor(.secondary.opacity(0.8))
        }
        .opacity(logoOpacity)
        .padding(.bottom, 20)
    }
    
    /// Handle login action
    private func handleLogin() {
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoading = false
            
            if authManager.login(username: username, password: password) {
                // Login successful - handled by AuthenticationManager
            } else {
                alertMessage = "Invalid credentials. Please verify your username and password."
                showingAlert = true
                
                // Clear password field
                password = ""
                
                // Shake animation for error
                withAnimation(.default) {
                    formOffset = -10
                }
                withAnimation(.default.delay(0.1)) {
                    formOffset = 10
                }
                withAnimation(.default.delay(0.2)) {
                    formOffset = 0
                }
            }
        }
    }
}

// Enhanced Text Field Style con colores Rose Legacy
struct EnhancedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(16)
            .background(
                ZStack {
                    // Background con transparencia suave
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(.systemBackground).opacity(0.85),
                                    Color(.systemBackground).opacity(0.95)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    // Border elegante Rose Legacy
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.primary.opacity(0.2),
                                    Color.purple.opacity(0.3)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                    
                    // Subtle inner glow blanco
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                        .blur(radius: 0.5)
                        .offset(x: 0, y: 1)
                }
            )
            .foregroundColor(.primary)
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
    }
}

// Legacy Text Field Style (keeping for compatibility)
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            )
            .foregroundColor(.white)
            .font(.body)
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationManager.preview)
}