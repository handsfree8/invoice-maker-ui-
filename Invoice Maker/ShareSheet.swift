//
//  ShareSheet.swift
//  Invoice Maker
//
//  Created by Rose legacy Home Solutions on 9/12/25.
//

import SwiftUI
import UIKit

/// A SwiftUI wrapper for UIActivityViewController to share files and content
struct ShareSheet: UIViewControllerRepresentable {
    
    // MARK: - Properties
    let activityItems: [Any]
    
    // MARK: - Constants
    private enum ShareConstants {
        static let defaultSubject = "Invoice PDF - Rose Legacy"
        static let companyName = "Rose Legacy Home Solutions LLC"
    }
    
    // MARK: - UIViewControllerRepresentable Implementation
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        print("🔧 Creating UIActivityViewController with \(activityItems.count) items")
        
        let activityViewController = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
        configureActivityViewController(activityViewController)
        configureiPadPopover(activityViewController)
        setupCompletionHandler(activityViewController)
        
        print("✅ UIActivityViewController created successfully")
        return activityViewController
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed for this implementation
    }
    
    // MARK: - Private Configuration Methods
    
    /// Configures the activity view controller with appropriate title and subject
    private func configureActivityViewController(_ activityViewController: UIActivityViewController) {
        // Set subject for email sharing
        if let url = activityItems.first as? URL {
            let fileName = url.lastPathComponent
            activityViewController.setValue("\(fileName) - \(ShareConstants.companyName)", forKey: "subject")
        } else {
            activityViewController.setValue(ShareConstants.defaultSubject, forKey: "subject")
        }
    }
    
    /// Configures popover presentation for iPad to prevent crashes
    private func configureiPadPopover(_ activityViewController: UIActivityViewController) {
        if let popoverController = activityViewController.popoverPresentationController {
            print("🔧 Configuring iPad popover")
            
            // Try to get the current window scene and root view
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootView = window.rootViewController?.view {
                popoverController.sourceView = rootView
                popoverController.sourceRect = CGRect(
                    x: rootView.bounds.midX,
                    y: rootView.bounds.midY,
                    width: 0,
                    height: 0
                )
            } else {
                // Fallback
                popoverController.sourceView = UIView()
                popoverController.sourceRect = CGRect(
                    x: UIScreen.main.bounds.midX,
                    y: UIScreen.main.bounds.midY,
                    width: 0,
                    height: 0
                )
            }
            
            popoverController.permittedArrowDirections = []
        } else {
            print("📱 Running on iPhone, no popover needed")
        }
    }
    
    /// Sets up completion handler to track sharing results
    private func setupCompletionHandler(_ activityViewController: UIActivityViewController) {
        activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            handleSharingCompletion(
                activityType: activityType,
                completed: completed,
                error: error
            )
        }
    }
    
    /// Handles the completion of sharing activity
    private func handleSharingCompletion(
        activityType: UIActivity.ActivityType?,
        completed: Bool,
        error: Error?
    ) {
        print("📋 Share completion - Type: \(activityType?.rawValue ?? "none"), Completed: \(completed)")
        
        if completed {
            let activityName = activityType?.rawValue ?? "unknown service"
            print("✅ Content shared successfully via: \(activityName)")
        } else {
            print("❌ Share was cancelled or failed")
        }
        
        if let error = error {
            print("❌ Error sharing content: \(error.localizedDescription)")
        }
    }
}

