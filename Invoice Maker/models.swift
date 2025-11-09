import Foundation

// MARK: - Line Item Model
/// Represents a single line item on an invoice
struct LineItem: Identifiable, Codable, Hashable {
    // MARK: - Properties
    let id: UUID
    var descriptionText: String
    var quantity: Double
    var unitPrice: Double
    
    // MARK: - Computed Properties
    /// Calculates the total for this line item (quantity × unit price)
    /// Returns 0 if either quantity or unit price is negative
    var lineTotal: Double {
        max(0, quantity) * max(0, unitPrice)
    }
    
    // MARK: - Initializers
    init(
        id: UUID = UUID(),
        descriptionText: String = "",
        quantity: Double = 1,
        unitPrice: Double = 0
    ) {
        self.id = id
        self.descriptionText = descriptionText
        self.quantity = quantity
        self.unitPrice = unitPrice
    }
}

// MARK: - Invoice Model
/// Represents a complete invoice with line items, taxes, and discounts
struct Invoice: Identifiable, Codable, Hashable {
    // MARK: - Properties
    let id: UUID
    var number: String
    var date: Date
    var clientName: String
    var items: [LineItem]
    var discount: Double      // Fixed amount discount
    var taxRate: Double       // Tax rate as decimal (0.085 = 8.5%)
    var notes: String
    var paymentMethod: PaymentMethod?  // New field
    var terms: String?                 // New field
    
    // MARK: - Computed Properties
    
    /// Sum of all line item totals before discount and tax
    var subTotal: Double {
        items.reduce(0) { $0 + $1.lineTotal }
    }
    
    /// Subtotal minus discount (never less than 0)
    var discounted: Double {
        max(0, subTotal - max(0, discount))
    }
    
    /// Tax amount calculated on the discounted total
    var tax: Double {
        discounted * max(0, taxRate)
    }
    
    /// Final total including tax
    var total: Double {
        discounted + tax
    }
    
    /// Indicates whether the invoice has any line items
    var hasItems: Bool {
        !items.isEmpty
    }
    
    /// Indicates whether a discount is applied
    var hasDiscount: Bool {
        discount > 0
    }
    
    /// Indicates whether tax is applied
    var hasTax: Bool {
        taxRate > 0
    }
    
    // MARK: - Initializers
    init(
        id: UUID = UUID(),
        number: String,
        date: Date = Date(),
        clientName: String = "",
        items: [LineItem] = [],
        discount: Double = 0,
        taxRate: Double = 0,
        notes: String = "",
        paymentMethod: PaymentMethod? = nil,
        terms: String? = nil
    ) {
        self.id = id
        self.number = number
        self.date = date
        self.clientName = clientName
        self.items = items
        self.discount = discount
        self.taxRate = taxRate
        self.notes = notes
        self.paymentMethod = paymentMethod
        self.terms = terms
    }
}

// MARK: - Payment Method Enum
enum PaymentMethod: String, CaseIterable, Codable {
    case cash = "Cash"
    case card = "Card"
    case check = "Check"
    case zelle = "Zelle"
    case other = "Other"
}
