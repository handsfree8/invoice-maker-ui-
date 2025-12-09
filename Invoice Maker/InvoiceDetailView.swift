import SwiftUI
import UIKit
import PDFKit
import MessageUI

struct InvoiceDetailView: View {
    // MARK: - Properties
    let invoice: Invoice
    @State private var pdfURL: URL?
    @State private var showShare = false
    @State private var showPDFPreview = false
    @State private var shareItems: [Any] = []
    @State private var showEmail = false
    @State private var emailPDFData: Data?
    @State private var emailStatusMessage: String?
    @State private var showEmailStatus = false
    
    // MARK: - Constants
    private enum PDFConstants {
        static let pageSize = CGSize(width: 612, height: 792) // Letter size @72dpi
        static let layoutDelay: TimeInterval = 0.2
        static let shareDelay: TimeInterval = 0.1
        static let filePermissions: UInt16 = 0o644
    }

    // MARK: - Body
    var body: some View {
        ScrollView {
            InvoicePDFView(invoice: invoice)
                .padding()
        }
        .navigationTitle("#\(invoice.number)")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                // Preview & Download button
                Button {
                    print("� Preview button pressed")
                    generateAndShowPreview()
                } label: {
                    Image(systemName: "doc.text.magnifyingglass")
                }
                .help("Preview PDF")
            }
        }
        .sheet(isPresented: $showShare) {
            if !shareItems.isEmpty {
                ShareSheet(activityItems: shareItems)
            } else {
                // Fallback view if no items to share
                Text("No content available to share")
                    .padding()
            }
        }
        .sheet(isPresented: $showEmail) {
            if let pdfData = emailPDFData {
                EmailComposer(
                    pdfData: pdfData,
                    invoiceNumber: invoice.number,
                    clientName: invoice.clientName,
                    onComplete: handleEmailResult
                )
            }
        }
        .sheet(isPresented: $showPDFPreview) {
            if let url = pdfURL {
                PDFPreviewView(
                    pdfURL: url, 
                    onShare: shareFromPreview,
                    onEmail: emailFromPreview
                )
            }
        }
        .alert("Email Status", isPresented: $showEmailStatus) {
            Button("OK") {
                emailStatusMessage = nil
            }
        } message: {
            if let message = emailStatusMessage {
                Text(message)
            }
        }
        .onAppear {
            // Generate PDF automatically when view appears for faster sharing
            if pdfURL == nil {
                print("🔄 Auto-generating PDF on view appear...")
                exportPDF()
            }
        }
    }

    // MARK: - Private Methods
    
    /// Generates PDF and shows preview with action buttons
    private func generateAndShowPreview() {
        print("� Generating PDF for preview...")
        
        if let url = pdfURL {
            print("� PDF already exists, showing preview: \(url.lastPathComponent)")
            showPDFPreview = true
        } else {
            print("🔄 Generating new PDF...")
            generatePDF { success in
                DispatchQueue.main.async {
                    if success {
                        print("✅ PDF generated successfully, showing preview")
                        self.showPDFPreview = true
                    } else {
                        print("❌ PDF generation failed")
                        // Could show an alert here if needed
                    }
                }
            }
        }
    }
    
    /// Handles the share action from the PDF preview
    private func handleShareFromPreview() {
        showPDFPreview = false
        DispatchQueue.main.asyncAfter(deadline: .now() + PDFConstants.shareDelay) {
            self.shareFromPreview()
        }
    }
    
    /// Simplified share function for use from preview (PDF already exists)
    private func shareFromPreview() {
        guard let url = pdfURL else {
            print("❌ No PDF available for sharing")
            return
        }
        
        print("📤 Sharing PDF from preview: \(url.lastPathComponent)")
        shareItems = [url]
        showShare = true
    }
    
    /// Simplified email function for use from preview (PDF already exists)  
    private func emailFromPreview() {
        guard let url = pdfURL else {
            print("❌ No PDF available for email")
            return
        }
        
        if EmailHelper.canSendEmail {
            print("📧 Sending email from preview")
            loadPDFDataForEmail(from: url)
        } else {
            print("📧 Mail not available from preview")
            showEmailNotAvailableAlert()
        }
    }
    
    // MARK: - Email Functions
    
    /// Prepares PDF for email and shows email composer
    private func prepareAndEmail() {
        if EmailHelper.canSendEmail {
            // Use native Mail app
            if let url = pdfURL {
                print("📧 Using existing PDF for email")
                loadPDFDataForEmail(from: url)
            } else {
                print("📧 Generating PDF for email...")
                generatePDF { success in
                    DispatchQueue.main.async {
                        if success, let url = self.pdfURL {
                            self.loadPDFDataForEmail(from: url)
                        } else {
                            self.emailStatusMessage = "Failed to generate PDF for email"
                            self.showEmailStatus = true
                        }
                    }
                }
            }
        } else {
            // Fallback to share sheet with email options
            print("📧 Mail not available, using share sheet")
            showEmailNotAvailableAlert()
        }
    }
    
    /// Shows alert when Mail is not available and offers share sheet
    private func showEmailNotAvailableAlert() {
        emailStatusMessage = "Mail app is not configured. You can still share the PDF using the Share button to send via email, messages, or other apps."
        showEmailStatus = true
    }
    
    /// Loads PDF data from URL for email attachment
    private func loadPDFDataForEmail(from url: URL) {
        do {
            let data = try Data(contentsOf: url)
            emailPDFData = data
            showEmail = true
            print("📧 PDF data loaded for email: \(data.count) bytes")
        } catch {
            print("❌ Failed to load PDF data for email: \(error)")
            emailStatusMessage = "Failed to prepare PDF for email"
            showEmailStatus = true
        }
    }
    
    /// Handles email composer result
    private func handleEmailResult(_ result: Result<MessageUI.MFMailComposeResult, Error>) {
        switch result {
        case .success(let mailResult):
            let message = EmailHelper.emailResultMessage(for: mailResult)
            print("📧 Email result: \(message)")
            
            // Only show success message for sent emails
            if mailResult == .sent {
                emailStatusMessage = message
                showEmailStatus = true
            }
            
        case .failure(let error):
            print("❌ Email error: \(error)")
            emailStatusMessage = "Failed to send email: \(error.localizedDescription)"
            showEmailStatus = true
        }
        
        // Reset email data
        emailPDFData = nil
        showEmail = false
    }
    
    /// Exports the invoice as a PDF file
    @MainActor
    private func exportPDF() {
        generatePDF { success in
            if success {
                print("📄 PDF generated and ready")
            }
        }
    }
    
    /// Generates the PDF with completion callback
    @MainActor
    private func generatePDF(completion: @escaping (Bool) -> Void) {
        // Try the simpler ImageRenderer approach first (iOS 16+)
        if #available(iOS 16.0, *) {
            generatePDFWithImageRenderer(completion: completion)
        } else {
            // Fallback to UIHostingController approach
            generatePDFWithHostingController(completion: completion)
        }
    }
    
    /// ALTERNATIVE METHOD 1: iOS 16+ ImageRenderer (más simple y confiable)
    @available(iOS 16.0, *)
    @MainActor
    private func generatePDFWithImageRenderer(completion: @escaping (Bool) -> Void) {
        print("📱 Using ImageRenderer method (iOS 16+)")
        
        let swiftUIView = createSwiftUIView()
        let renderer = ImageRenderer(content: swiftUIView)
        
        // Set the size and scale
        renderer.proposedSize = .init(PDFConstants.pageSize)
        renderer.scale = 2.0 // Retina quality
        
        // Render to PDF directly
        let pageRect = CGRect(origin: .zero, size: PDFConstants.pageSize)
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: pageRect)
        
        let pdfData = pdfRenderer.pdfData { context in
            context.beginPage()
            
            // Render the view
            renderer.render { size, renderInContext in
                renderInContext(context.cgContext)
            }
        }
        
        print("📦 ImageRenderer PDF size: \(pdfData.count) bytes")
        
        // Save the PDF
        savePDF(data: pdfData, completion: completion)
    }
    
    /// ALTERNATIVE METHOD 2: UIHostingController (método original, fallback para iOS 15)
    @MainActor
    private func generatePDFWithHostingController(completion: @escaping (Bool) -> Void) {
        print("📱 Using UIHostingController method (iOS 15)")
        
        let swiftUIView = createSwiftUIView()
        let hostingController = createHostingController(with: swiftUIView)
        
        // Force layout calculation
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        
        // Delay to ensure SwiftUI completes rendering
        DispatchQueue.main.asyncAfter(deadline: .now() + PDFConstants.layoutDelay) {
            self.renderPDF(from: hostingController, completion: completion)
        }
    }
    
    /// Creates the SwiftUI view for PDF rendering
    private func createSwiftUIView() -> some View {
        InvoicePDFView(invoice: invoice)
            .frame(width: PDFConstants.pageSize.width, height: PDFConstants.pageSize.height)
            .background(Color.white)
            .colorScheme(.light)
            .environment(\.colorScheme, .light)
    }
    
    /// Creates and configures the hosting controller
    private func createHostingController(with view: some View) -> UIHostingController<some View> {
        let pageRect = CGRect(origin: .zero, size: PDFConstants.pageSize)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = pageRect
        hostingController.view.backgroundColor = UIColor.white
        return hostingController
    }
    
    /// Renders the PDF from the hosting controller
    private func renderPDF(from hostingController: UIHostingController<some View>, completion: @escaping (Bool) -> Void) {
        let pageRect = CGRect(origin: .zero, size: PDFConstants.pageSize)
        
        print("📐 Page rect: \(pageRect)")
        
        // Render to image first
        let image = renderToImage(from: hostingController, in: pageRect)
        
        print("🖼️ Image size: \(image.size)")
        
        guard image.size.width > 0 && image.size.height > 0 else {
            print("❌ Error: Generated image is empty")
            completion(false)
            return
        }
        
        // Create PDF from image
        let pdfData = createPDFData(from: image, in: pageRect)
        
        // Save PDF
        savePDF(data: pdfData, completion: completion)
    }
    
    /// Renders the hosting controller to an image
    private func renderToImage(from hostingController: UIHostingController<some View>, in pageRect: CGRect) -> UIImage {
        print("🎨 Starting image render with bounds: \(pageRect)")
        print("🖥️ Hosting controller view frame: \(hostingController.view.frame)")
        
        let renderer = UIGraphicsImageRenderer(bounds: pageRect)
        let image = renderer.image { context in
            // White background to ensure non-transparent rendering
            UIColor.white.setFill()
            context.fill(pageRect)
            
            // Render the view
            let didRender = hostingController.view.drawHierarchy(in: pageRect, afterScreenUpdates: true)
            print("✏️ drawHierarchy result: \(didRender)")
        }
        
        print("🖼️ Rendered image size: \(image.size), scale: \(image.scale)")
        return image
    }
    
    /// Creates PDF data from the rendered image
    private func createPDFData(from image: UIImage, in pageRect: CGRect) -> Data {
        print("📝 Creating PDF data from image...")
        
        let documentInfo = createPDFDocumentInfo()
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: pageRect, format: UIGraphicsPDFRendererFormat())
        
        let data = pdfRenderer.pdfData { pdfContext in
            pdfContext.beginPage()
            image.draw(in: pageRect)
        }
        
        print("📦 PDF data created: \(data.count) bytes")
        return data
    }
    
    /// Creates PDF document metadata
    private func createPDFDocumentInfo() -> [String: Any] {
        return [
            kCGPDFContextTitle as String: "Invoice \(invoice.number)",
            kCGPDFContextAuthor as String: "Rose Legacy Home Solutions LLC",
            kCGPDFContextSubject as String: "Invoice #\(invoice.number)",
            kCGPDFContextCreator as String: "Invoice Maker App"
        ]
    }
    
    /// Saves the PDF data to the documents directory
    private func savePDF(data: Data, completion: @escaping (Bool) -> Void) {
        do {
            let url = try createPDFFileURL()
            try savePDFData(data, to: url)
            
            print("✅ PDF exported successfully: \(url.path), size: \(data.count) bytes")
            
            self.pdfURL = url
            completion(true)
            
        } catch {
            print("❌ Error saving PDF: \(error.localizedDescription)")
            handlePDFSaveError(error)
            completion(false)
        }
    }
    
    /// Creates the URL for the PDF file
    private func createPDFFileURL() throws -> URL {
        let documentsDirectory = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        
        let fileName = "Invoice-\(invoice.number).pdf"
        return documentsDirectory.appendingPathComponent(fileName)
    }
    
    /// Saves PDF data to the specified URL
    private func savePDFData(_ data: Data, to url: URL) throws {
        // Create directory if needed
        let directory = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        
        // Write with atomic option
        try data.write(to: url, options: [.atomic])
        
        // Verify file was written correctly
        let fileSize = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
        guard fileSize > 0 else {
            throw PDFError.emptyFile
        }
        
        // Set file permissions
        try FileManager.default.setAttributes(
            [.posixPermissions: PDFConstants.filePermissions],
            ofItemAtPath: url.path
        )
    }
    
    /// Handles PDF save errors
    private func handlePDFSaveError(_ error: Error) {
        DispatchQueue.main.async {
            // Here you could show an alert to the user if needed
            // For now, we just log the error
        }
    }
}

// MARK: - PDF Error Types
enum PDFError: LocalizedError {
    case emptyFile
    
    var errorDescription: String? {
        switch self {
        case .emptyFile:
            return "PDF file is empty"
        }
    }
}

// MARK: - PDF Preview View
struct PDFPreviewView: View {
    let pdfURL: URL
    let onShare: () -> Void
    let onEmail: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            PDFKitView(pdfURL: pdfURL)
                .navigationTitle("Invoice Preview")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Close") {
                            dismiss()
                        }
                    }
                    
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        // Email button
                        Button {
                            onEmail()
                        } label: {
                            Image(systemName: "envelope")
                        }
                        .help("Send Email")
                        
                        // Share button  
                        Button {
                            onShare()
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .help("Share PDF")
                    }
                }
        }
    }
}

// MARK: - PDFKit Wrapper
struct PDFKitView: UIViewRepresentable {
    let pdfURL: URL
    
    func makeUIView(context: Context) -> PDFView {
        print("📄 PDFKitView makeUIView called")
        print("📂 PDF URL: \(pdfURL)")
        print("📁 File exists: \(FileManager.default.fileExists(atPath: pdfURL.path))")
        
        let pdfView = PDFView()
        pdfView.backgroundColor = UIColor.systemBackground
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        
        // Try to load PDF immediately
        loadPDF(into: pdfView)
        
        return pdfView
    }
    
    func updateUIView(_ pdfView: PDFView, context: Context) {
        print("🔄 PDFKitView updateUIView called")
        loadPDF(into: pdfView)
    }
    
    private func loadPDF(into pdfView: PDFView) {
        // Check if file exists
        guard FileManager.default.fileExists(atPath: pdfURL.path) else {
            print("❌ PDF file does not exist at: \(pdfURL.path)")
            return
        }
        
        // Try to load PDF
        if let pdfDocument = PDFDocument(url: pdfURL) {
            print("✅ PDF loaded successfully, pages: \(pdfDocument.pageCount)")
            pdfView.document = pdfDocument
            
            // Force immediate display
            if let firstPage = pdfDocument.page(at: 0) {
                print("📄 First page bounds: \(firstPage.bounds(for: .mediaBox))")
                pdfView.go(to: firstPage)
            }
        } else {
            print("❌ Failed to create PDFDocument from URL: \(pdfURL)")
            
            // Try reading file data directly
            if let data = try? Data(contentsOf: pdfURL) {
                print("📦 File data size: \(data.count) bytes")
                if let pdfFromData = PDFDocument(data: data) {
                    print("✅ PDF loaded from data, pages: \(pdfFromData.pageCount)")
                    pdfView.document = pdfFromData
                } else {
                    print("❌ Failed to create PDFDocument from data")
                }
            } else {
                print("❌ Failed to read file data")
            }
        }
    }
}

// MARK: - URL Extensions
extension URL {
    /// Returns a human-readable file size string
    var fileSizeString: String {
        do {
            let resources = try resourceValues(forKeys: [.fileSizeKey])
            if let fileSize = resources.fileSize {
                return ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
            }
        } catch {
            print("Error getting file size: \(error)")
        }
        return "Unknown"
    }
}
