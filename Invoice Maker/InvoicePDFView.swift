import SwiftUI

struct InvoicePDFView: View {
    // MARK: - Properties
    let invoice: Invoice
    
    // MARK: - Layout Constants
    private enum LayoutConstants {
        // Column widths optimized for 612pt letter width
        static let quantityColumnWidth: CGFloat = 60
        static let priceColumnWidth: CGFloat = 90
        static let totalColumnWidth: CGFloat = 110
        
        // Spacing and padding
        static let contentPadding: CGFloat = 24
        static let sectionSpacing: CGFloat = 12
        static let itemSpacing: CGFloat = 4
        static let headerSpacing: CGFloat = 2
        
        // Logo dimensions
        static let logoSize = CGSize(width: 50, height: 50)
        static let logoCornerRadius: CGFloat = 10
    }
    
    // MARK: - Company Constants
    private enum CompanyInfo {
        static let name = "Rose Legacy Home Solutions LLC"
        static let phone = "816-298-4828"
        static let email = "appointments@roselegacyhvac.com"
        static let services = "HVAC • Plumbing • Appliances • Remodeling"
        static let logoAssetName = "rl-logo"
        static let logoPlaceholder = "RL"
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: LayoutConstants.sectionSpacing) {
                headerSection
                Divider()
                billToSection
                Divider()
                itemsTableSection
                Divider()
                totalsSection
                
                if invoice.notes.isNotEmpty {
                    Divider()
                    notesSection
                }
                
                if invoice.paymentMethod != nil || invoice.terms?.isNotEmpty == true {
                    Divider()
                    paymentSection
                }
                
                // Warranty section with proper spacing
                Divider()
                warrantyFooter
                
                // Small spacer to prevent content from going to edge
                Spacer(minLength: 8)
            }
            .padding(LayoutConstants.contentPadding)
        }
    }
}

// MARK: - View Components

extension InvoicePDFView {
    
    /// Header section with logo, company info, and invoice details
    private var headerSection: some View {
        HStack(alignment: .top, spacing: LayoutConstants.sectionSpacing) {
            companyLogo
            companyInfo
            Spacer()
            invoiceDetails
        }
    }
    
    /// Company logo with fallback placeholder
    private var companyLogo: some View {
        Group {
            if UIImage(named: CompanyInfo.logoAssetName) != nil {
                Image(CompanyInfo.logoAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: LayoutConstants.logoSize.width, height: LayoutConstants.logoSize.height)
                    .clipShape(RoundedRectangle(cornerRadius: LayoutConstants.logoCornerRadius))
            } else {
                RoundedRectangle(cornerRadius: LayoutConstants.logoCornerRadius)
                    .stroke(lineWidth: 1)
                    .frame(width: LayoutConstants.logoSize.width, height: LayoutConstants.logoSize.height)
                    .overlay(
                        Text(CompanyInfo.logoPlaceholder)
                            .bold()
                    )
            }
        }
    }
    
    /// Company information section
    private var companyInfo: some View {
        VStack(alignment: .leading, spacing: LayoutConstants.headerSpacing) {
            Text(CompanyInfo.name)
                .font(.headline)
            
            Text("\(CompanyInfo.phone)  •  \(CompanyInfo.email)")
                .font(.footnote)
                .foregroundColor(.gray)
            
            Text(CompanyInfo.services)
                .font(.footnote)
                .foregroundColor(.gray)
        }
    }
    
    /// Invoice details (number and date)
    private var invoiceDetails: some View {
        VStack(alignment: .trailing, spacing: LayoutConstants.headerSpacing) {
            Text("INVOICE")
                .font(.title)
                .bold()
            
            Text("#\(invoice.number)")
                .font(.headline)
            
            Text(invoice.date, style: .date)
                .font(.footnote)
        }
    }
    
    /// Bill to section
    private var billToSection: some View {
        VStack(alignment: .leading, spacing: LayoutConstants.headerSpacing) {
            Text("Bill To")
                .bold()
            
            Text(invoice.clientName.isEmpty ? "—" : invoice.clientName)
        }
    }
    
    /// Items table section with header and rows
    private var itemsTableSection: some View {
        VStack(alignment: .leading, spacing: LayoutConstants.itemSpacing) {
            tableHeader
            itemRows
        }
    }
    
    /// Table header row
    private var tableHeader: some View {
        HStack {
            Text("Description")
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Qty")
                .bold()
                .frame(width: LayoutConstants.quantityColumnWidth, alignment: .trailing)
            
            Text("Price")
                .bold()
                .frame(width: LayoutConstants.priceColumnWidth, alignment: .trailing)
            
            Text("Total")
                .bold()
                .frame(width: LayoutConstants.totalColumnWidth, alignment: .trailing)
        }
        .padding(.top, LayoutConstants.headerSpacing)
    }
    
    /// Item rows
    private var itemRows: some View {
        ForEach(invoice.items) { item in
            HStack {
                Text(item.descriptionText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(item.quantity, format: .number)
                    .frame(width: LayoutConstants.quantityColumnWidth, alignment: .trailing)
                
                Text(item.unitPrice, format: .currency(code: "USD"))
                    .frame(width: LayoutConstants.priceColumnWidth, alignment: .trailing)
                
                Text(item.lineTotal, format: .currency(code: "USD"))
                    .frame(width: LayoutConstants.totalColumnWidth, alignment: .trailing)
            }
            .font(.callout)
        }
    }
    
    /// Totals section with subtotal, discount, tax, and final total
    private var totalsSection: some View {
        VStack(alignment: .trailing, spacing: LayoutConstants.itemSpacing) {
            subtotalRow
            
            if invoice.hasDiscount {
                discountRow
            }
            
            if invoice.hasTax {
                taxRow
            }
            
            totalRow
        }
    }
    
    /// Subtotal row
    private var subtotalRow: some View {
        HStack {
            Spacer()
            Text("Subtotal")
            Text(invoice.subTotal, format: .currency(code: "USD"))
                .frame(width: LayoutConstants.totalColumnWidth, alignment: .trailing)
        }
    }
    
    /// Discount row (only shown if discount > 0)
    private var discountRow: some View {
        HStack {
            Spacer()
            Text("Discount")
            Text(-invoice.discount, format: .currency(code: "USD"))
                .frame(width: LayoutConstants.totalColumnWidth, alignment: .trailing)
        }
    }
    
    /// Tax row (only shown if tax rate > 0)
    private var taxRow: some View {
        HStack {
            Spacer()
            Text("Tax")
            Text(invoice.tax, format: .currency(code: "USD"))
                .frame(width: LayoutConstants.totalColumnWidth, alignment: .trailing)
        }
    }
    
    /// Final total row
    private var totalRow: some View {
        HStack {
            Spacer()
            Text("TOTAL")
                .bold()
            Text(invoice.total, format: .currency(code: "USD"))
                .bold()
                .frame(width: LayoutConstants.totalColumnWidth, alignment: .trailing)
        }
    }
    
    /// Notes section
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: LayoutConstants.itemSpacing) {
            Text("Notes")
                .bold()
            
            Text(invoice.notes)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    /// Payment and terms section
    private var paymentSection: some View {
        VStack(alignment: .leading, spacing: LayoutConstants.itemSpacing) {
            if let paymentMethod = invoice.paymentMethod {
                HStack {
                    Text("Payment Method:")
                        .bold()
                    Text(paymentMethod.rawValue)
                }
            }
            
            if let terms = invoice.terms, terms.isNotEmpty {
                HStack {
                    Text("Terms:")
                        .bold()
                    Text(terms)
                }
            }
        }
    }
    
    /// Warranty footer
    private var warrantyFooter: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Warranty Disclaimer")
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            Text("This service includes warranty coverage only for the work performed today. Any future issues unrelated to this service requested will be quoted separately as new service requests.")
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - String Extensions
extension String {
    /// Returns true if the string is not empty
    var isNotEmpty: Bool {
        !isEmpty
    }
}
