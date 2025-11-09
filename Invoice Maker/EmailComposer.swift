import SwiftUI
import MessageUI

struct EmailComposer: UIViewControllerRepresentable {
    // MARK: - Properties
    let pdfData: Data
    let invoiceNumber: String
    let clientName: String
    let onComplete: (Result<MFMailComposeResult, Error>) -> Void
    
    // MARK: - UIViewControllerRepresentable
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        
        // Set email content
        setupEmailContent(composer)
        
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Email Setup
    private func setupEmailContent(_ composer: MFMailComposeViewController) {
        // Subject
        composer.setSubject("Invoice #\(invoiceNumber) - Rose Legacy Home Solutions")
        
        // Body message
        let messageBody = createEmailBody()
        composer.setMessageBody(messageBody, isHTML: false)
        
        // Attach PDF
        let fileName = "Invoice_\(invoiceNumber).pdf"
        composer.addAttachmentData(pdfData, mimeType: "application/pdf", fileName: fileName)
    }
    
    private func createEmailBody() -> String {
        let clientGreeting = clientName.isEmpty ? "Dear Valued Customer" : "Dear \(clientName)"
        
        return """
        \(clientGreeting),

        Please find attached your invoice #\(invoiceNumber) from Rose Legacy Home Solutions.

        Invoice Details:
        • Invoice Number: #\(invoiceNumber)
        • Date: \(Date().formatted(date: .abbreviated, time: .omitted))
        \(clientName.isEmpty ? "" : "• Customer: \(clientName)")

        If you have any questions about this invoice, please don't hesitate to contact us.

        Thank you for choosing Rose Legacy Home Solutions!

        Best regards,
        Rose Legacy Home Solutions LLC
        📞 816-298-4828
        ✉️ appointments@roselegacyhvac.com
        🌐 HVAC • Plumbing • Appliances • Remodeling
        """
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: EmailComposer
        
        init(_ parent: EmailComposer) {
            self.parent = parent
        }
        
        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            if let error = error {
                parent.onComplete(.failure(error))
            } else {
                parent.onComplete(.success(result))
            }
            
            controller.dismiss(animated: true)
        }
    }
}

// MARK: - Email Helper
struct EmailHelper {
    
    /// Check if device can send email
    static var canSendEmail: Bool {
        return MFMailComposeViewController.canSendMail()
    }
    
    /// Get user-friendly message for email status
    static func emailResultMessage(for result: MFMailComposeResult) -> String {
        switch result {
        case .cancelled:
            return "Email cancelled"
        case .saved:
            return "Email saved to drafts"
        case .sent:
            return "Email sent successfully!"
        case .failed:
            return "Failed to send email"
        @unknown default:
            return "Unknown result"
        }
    }
    
    /// Get system image for email status
    static func emailResultIcon(for result: MFMailComposeResult) -> String {
        switch result {
        case .cancelled:
            return "xmark.circle"
        case .saved:
            return "tray.and.arrow.down"
        case .sent:
            return "checkmark.circle.fill"
        case .failed:
            return "exclamationmark.triangle"
        @unknown default:
            return "envelope"
        }
    }
}

// MARK: - Preview
#Preview {
    // This is just a placeholder for preview
    Text("Email Composer")
}