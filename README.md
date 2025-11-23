# 📱 Invoice Maker - Rose Legacy Home Solutions

> Professional invoice management app designed for Rose Legacy Home Solutions LLC

![iOS](https://img.shields.io/badge/iOS-15.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-3.0-green)
![Xcode](https://img.shields.io/badge/Xcode-15.0+-blue)

## 📋 Table of Contents

- [Features](#-features)
- [Requirements](#-requirements)
- [Installation](#-installation)
- [Usage](#-usage)
- [Architecture](#-architecture)
- [Security](#-security)
- [Backup & Export](#-backup--export)
- [Distribution](#-distribution)
- [Support](#-support)

## ✨ Features

### 📄 Invoice Management
- ✅ Create, edit, and delete invoices
- ✅ Professional PDF generation with company branding
- ✅ Line items with quantity and unit pricing
- ✅ Discount calculations
- ✅ Multiple payment methods (Cash, Card, Check, Zelle)
- ✅ Email invoices directly to clients
- ✅ Share PDFs via AirDrop, Messages, etc.
- ✅ Duplicate invoices for recurring work
- ✅ Search and filter invoices

### 👥 Customer Management
- ✅ Comprehensive customer database
- ✅ Contact information (phone, email, address)
- ✅ Service history tracking
- ✅ Customer statistics (total spent, average invoice, service count)
- ✅ Quick actions (call, email, create invoice)
- ✅ Search and sort customers
- ✅ Follow-up reminders for inactive customers

### 🔐 Security & Authentication
- ✅ Secure login with Keychain integration
- ✅ Session persistence across app launches
- ✅ Password change functionality
- ✅ User role management
- ✅ Data validation on all forms

### 💾 Data Management
- ✅ Automatic backup every 5 saves
- ✅ Manual backup creation
- ✅ Export to JSON (complete backup)
- ✅ Export to CSV (invoices & customers separately)
- ✅ Import/restore from backup
- ✅ Data persistence with UserDefaults
- ✅ Error handling and recovery

### 🎨 User Interface
- ✅ Modern SwiftUI design
- ✅ Tab-based navigation (Invoices, Customers, Settings)
- ✅ Animated splash screen
- ✅ Rose Legacy branded colors and logo
- ✅ Responsive layouts for iPhone and iPad
- ✅ Dark mode support
- ✅ Intuitive form validation

## 📋 Requirements

- **iOS**: 15.0 or later
- **Xcode**: 15.0 or later
- **Swift**: 5.9 or later
- **Device**: iPhone or iPad

### Supported Devices
- iPhone 13 and later
- iPad (all models)
- iPad Pro
- iPad Air
- iPad mini

## 🚀 Installation

### Option 1: Xcode Development

1. **Clone the repository**
   ```bash
   git clone https://github.com/handsfree8/invoice-maker-ui-.git
   cd invoice-maker-ui-
   ```

2. **Open the project in Xcode**
   ```bash
   open "Invoice Maker.xcodeproj"
   ```

3. **Select your target device**
   - Choose your connected iPhone/iPad or simulator
   - Or use "My Mac (Designed for iPad)"

4. **Build and run**
   - Press `Cmd + R` or click the Play button
   - The app will build and launch on your selected device

### Option 2: TestFlight Distribution (Recommended for Production)

1. **Prepare for TestFlight**
   - Archive the app in Xcode: `Product → Archive`
   - Upload to App Store Connect
   - Add internal or external testers

2. **Install via TestFlight**
   - Download TestFlight from App Store
   - Accept the invitation email
   - Install "Invoice Maker" from TestFlight

### Option 3: Ad-Hoc Distribution

1. **Connect your iPhone to your Mac**

2. **Register the device** in Apple Developer Portal

3. **Create an Ad-Hoc provisioning profile**

4. **Archive and export** for Ad-Hoc distribution

5. **Install via Xcode**
   - Window → Devices and Simulators
   - Drag the .ipa file to your device

## 🎯 Usage

### First Launch

1. **Login Screen**
   - Default credentials:
     - Username: `admin` / Password: `RoseLegacy2025`
     - Username: `usuario` / Password: `Invoice2025`
     - Username: `roselegacy` / Password: `HomesSolutions`

2. **Splash Screen**
   - Beautiful animated Rose Legacy logo
   - Auto-dismisses after 2.5 seconds

### Creating an Invoice

1. Navigate to **Invoices** tab
2. Tap **+** button
3. Fill in invoice details:
   - Invoice number (auto-generated)
   - Client name
   - Date
   - Line items (description, quantity, price)
   - Discount percentage
   - Payment method
   - Terms
4. Tap **Done** to save

### Managing Customers

1. Navigate to **Customers** tab
2. Tap **Add Customer**
3. Enter customer information:
   - Name (required)
   - Phone, email, address
   - Notes
4. View customer details:
   - Service statistics
   - Contact information
   - Quick actions

### Exporting Data

1. Navigate to **Settings** tab
2. Choose export option:
   - **Complete Backup (JSON)**: Full data export
   - **Invoices (CSV)**: Spreadsheet-compatible
   - **Customers (CSV)**: Contact list
3. Share via:
   - Email
   - AirDrop
   - Files app
   - Cloud storage

### Backup & Restore

**Automatic Backup**
- Created every 5 saves
- Stored in app's Documents folder

**Manual Backup**
1. Settings → Create Manual Backup
2. File saved locally

**Restore Data**
1. Settings → Import Backup
2. Select backup file
3. Confirm restoration

## 🏗️ Architecture

### Project Structure

```
Invoice Maker/
├── App Entry
│   ├── Invoice_MakerApp.swift       # App entry point
│   └── AppRootView.swift             # Root view controller
│
├── Authentication
│   ├── AuthenticationManager.swift   # Login & session management
│   └── LoginView.swift               # Login UI
│
├── Models
│   ├── models.swift                  # Invoice & LineItem models
│   └── CustomerModels.swift          # Customer model
│
├── Storage & Persistence
│   ├── InvoiceStorage.swift          # Invoice data management
│   ├── CustomerStorage.swift         # Customer data management
│   └── DataBackupManager.swift       # Backup & export system
│
├── Views - Invoices
│   ├── ContentView.swift             # Main tab view
│   ├── InvoiceEditView.swift         # Create/edit invoices
│   ├── InvoiceDetailView.swift       # View invoice details
│   └── InvoicePDFView.swift          # PDF generation
│
├── Views - Customers
│   ├── CustomersView.swift           # Customer list
│   ├── CustomerDetailView.swift      # Customer details
│   └── CustomerEditView.swift        # Create/edit customers
│
├── Views - Settings
│   └── SettingsView.swift            # App settings & data management
│
├── Integration
│   └── CustomerInvoiceIntegration.swift # Customer-invoice linking
│
├── Utilities
│   ├── ValidationHelper.swift        # Form validation
│   ├── EmailComposer.swift           # Email functionality
│   └── ShareSheet.swift              # Share sheet wrapper
│
├── UI Components
│   ├── SplashView.swift              # Animated splash screen
│   └── LaunchScreenView.swift        # Launch screen
│
└── Assets
    └── Assets.xcassets               # Images, icons, colors
```

### Design Patterns

- **MVVM**: Model-View-ViewModel architecture
- **ObservableObject**: SwiftUI state management
- **Singleton**: Storage managers
- **Dependency Injection**: View initialization
- **Delegate Pattern**: Email and share sheets

### Data Flow

```
User Input → View → Storage Manager → UserDefaults
                                    ↓
                            Automatic Backup
                                    ↓
                              Documents Folder
```

## 🔒 Security

### Authentication
- **Keychain Storage**: Secure credential storage
- **Session Management**: Persistent login state
- **Password Validation**: Strong password requirements
  - Minimum 8 characters
  - At least one number
  - At least one letter

### Data Protection
- **UserDefaults Encryption**: Coming soon
- **Backup Encryption**: Planned feature
- **Biometric Authentication**: Future enhancement

### Best Practices
- ✅ Never commit credentials to Git
- ✅ Use `.gitignore` for sensitive files
- ✅ Validate all user inputs
- ✅ Handle errors gracefully
- ✅ Log security events

### Current Limitations
⚠️ **For Production Use, Implement:**
- End-to-end encryption for data at rest
- Server-side authentication
- API key management
- Certificate pinning
- Jailbreak detection

## 💾 Backup & Export

### Backup Formats

#### JSON (Complete Backup)
```json
{
  "version": "1.0.0",
  "exportDate": "2025-11-19T12:00:00Z",
  "invoices": [...],
  "customers": [...]
}
```

**Use case**: Complete data migration, disaster recovery

#### CSV (Invoices)
```csv
Invoice Number,Date,Client Name,Subtotal,Discount,Tax,Total,...
RL-00001,11/19/25,John Smith,259.00,0.00,0.00,259.00,...
```

**Use case**: Accounting software import, Excel analysis

#### CSV (Customers)
```csv
Name,Phone,Email,Address,City,Zip Code,...
John Smith,(816) 555-1234,john@email.com,123 Oak St,Overland Park,66213,...
```

**Use case**: CRM import, mailing lists

### Backup Schedule

| Backup Type | Trigger | Location | Retention |
|-------------|---------|----------|-----------|
| Automatic | Every 5 saves | Documents/ | Overwrites |
| Manual | User-initiated | Documents/ | User manages |
| Export | User-initiated | User chooses | User manages |

## 📦 Distribution

### For Personal Use (Recommended)

**Method 1: Direct Installation**
1. Connect iPhone to Mac
2. Open project in Xcode
3. Select your device
4. `Cmd + R` to build and install
5. Trust developer in Settings → General → VPN & Device Management

**Method 2: TestFlight (Beta)**
1. Create an Apple Developer account ($99/year)
2. Archive the app in Xcode
3. Upload to App Store Connect
4. Add yourself as an internal tester
5. Install via TestFlight app

### For App Store Distribution

1. **Prepare for submission**
   - Update Bundle ID: `com.roselegacy.invoicemaker`
   - Set version and build numbers
   - Add app icons (all sizes)
   - Create screenshots
   - Write app description

2. **Archive and validate**
   ```
   Product → Archive
   Validate App
   Distribute App
   ```

3. **Submit for review**
   - Fill out App Store Connect metadata
   - Add privacy policy
   - Submit for review (7-14 days)

### Bundle Configuration

```swift
Bundle Identifier: com.roselegacy.invoicemaker
Version: 1.0.0
Build: 1
Minimum iOS Version: 15.0
```

## 🔧 Troubleshooting

### Build Errors

**Error**: "No code signing identities found"
- **Solution**: Add your Apple ID in Xcode → Settings → Accounts

**Error**: "Provisioning profile doesn't match"
- **Solution**: Select "Automatically manage signing" in project settings

### Runtime Issues

**Issue**: Login doesn't persist
- **Solution**: Already fixed - session saves to Keychain

**Issue**: PDF generation fails
- **Solution**: Check that logo image "rl-logo" exists in Assets

**Issue**: Export shows empty file
- **Solution**: Ensure data exists before exporting

### Common Questions

**Q: Can I use this without an Apple Developer account?**
A: Yes, for personal use on your own devices (requires Mac + Xcode)

**Q: How do I reset my password?**
A: Currently, passwords are hardcoded. Contact admin to change.

**Q: Can I customize the invoice template?**
A: Yes, edit `InvoicePDFView.swift` to customize layout/branding

**Q: Is my data backed up to iCloud?**
A: Not yet - coming in future version. Use manual exports for now.

## 🆘 Support

### Contact Information

**Rose Legacy Home Solutions LLC**
- 📞 Phone: (816) 298-4828
- ✉️ Email: appointments@roselegacyhvac.com
- 🌐 Services: HVAC • Plumbing • Appliances • Remodeling

### Developer Support

- 📧 Technical Issues: [Create GitHub Issue](https://github.com/handsfree8/invoice-maker-ui-/issues)
- 💬 Feature Requests: [Discussions](https://github.com/handsfree8/invoice-maker-ui-/discussions)
- 📚 Documentation: This README

### Reporting Bugs

When reporting bugs, please include:
1. Device model and iOS version
2. App version (see Settings)
3. Steps to reproduce
4. Expected vs actual behavior
5. Screenshots if applicable

## 📝 License

© 2025 Rose Legacy Home Solutions LLC. All Rights Reserved.

This software is proprietary and confidential. Unauthorized copying, modification, distribution, or use of this software is strictly prohibited.

## 🙏 Acknowledgments

- Built with ❤️ using SwiftUI
- Designed for Rose Legacy Home Solutions
- Icons from SF Symbols
- PDF generation using UIKit

## 📅 Version History

### Version 1.0.0 (November 19, 2025)
- ✨ Initial release
- ✅ Invoice management
- ✅ Customer database
- ✅ PDF generation & export
- ✅ Backup & restore
- ✅ Settings & configuration
- ✅ Form validation
- ✅ Security improvements

### Upcoming Features (v1.1.0)
- ⏳ iCloud sync
- ⏳ Enhanced reporting
- ⏳ Recurring invoices
- ⏳ Payment tracking
- ⏳ Tax calculations
- ⏳ Multi-user support
- ⏳ Apple Watch companion

---

**Built with 💜 for Rose Legacy Home Solutions**

*Professional invoice management designed specifically for your business needs.*
