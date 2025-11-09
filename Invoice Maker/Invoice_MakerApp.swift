//
//  Invoice_MakerApp.swift
//  Invoice Maker
//
//  Created by Rose legacy Home Solutions on 9/11/25.
//

import SwiftUI

@main
struct Invoice_MakerApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
    }
}

struct AppRootView: View {
    @State private var showingSplash = true
    
    var body: some View {
        ZStack {
            if showingSplash {
                SplashView {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showingSplash = false
                    }
                }
                .transition(.opacity)
            } else {
                ContentView()
                    .transition(.opacity)
            }
        }
    }
}
