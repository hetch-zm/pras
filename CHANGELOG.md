# 📝 Changelog

All notable changes to the Purchase Requisition System will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [3.0.0] - 2025-01-06

### 🎉 Initial Release

Complete purchase requisition management system with full workflow support.

### Added
- **Multi-level Approval Workflow**
  - Initiator → HOD → Finance → MD → Procurement flow
  - Role-based access control
  - Real-time status updates

- **User Management**
  - User authentication with JWT
  - Password hashing with bcrypt
  - Refresh token support
  - Role-based permissions (Admin, MD, Finance, Procurement, HOD, Initiator)

- **Budget Management**
  - Department budget tracking
  - FX rate management (ZMW/USD)
  - Budget balance calculations
  - Real-time budget status

- **Quotes & Adjudication**
  - Support for 3 vendor quotes
  - Comparative analysis
  - Adjudication workflow
  - Justification for vendor selection

- **Purchase Orders**
  - PO generation from approved requisitions
  - Sequential PO numbering
  - Delivery tracking
  - Invoice management

- **Analytics & Reporting**
  - Dashboard with key metrics
  - Requisition status analytics
  - Budget utilization reports
  - Department-wise analysis
  - Excel report generation
  - PDF report generation

- **Document Management**
  - File upload support
  - Attachment storage
  - Vendor document management

- **PDF Generation**
  - Requisition PDFs
  - Purchase Order PDFs
  - Custom report PDFs
  - Professional formatting with logo

- **Security Features**
  - Rate limiting
  - Input validation
  - SQL injection prevention
  - XSS protection
  - CSRF protection
  - Secure password storage

- **Logging & Monitoring**
  - Winston logging
  - Request logging
  - Error tracking
  - Audit trail

### Technical Details
- **Backend**: Node.js, Express.js, SQLite
- **Frontend**: HTML, CSS, JavaScript
- **Authentication**: JWT tokens
- **Database**: SQLite with proper indexing
- **File Storage**: Local filesystem
- **PDF Generation**: PDFKit
- **Excel Generation**: ExcelJS

### Documentation
- User guides
- Admin console guide
- API documentation
- Workflow diagrams
- Troubleshooting guide
- Security documentation

---

## How to Use This Changelog

### When Adding Entries

Use these categories:
- **Added** for new features
- **Changed** for changes in existing functionality
- **Deprecated** for soon-to-be removed features
- **Removed** for now removed features
- **Fixed** for any bug fixes
- **Security** for vulnerability fixes

### Version Numbers

- **MAJOR** version (4.0.0) - Incompatible API changes
- **MINOR** version (3.1.0) - New features, backwards compatible
- **PATCH** version (3.0.1) - Bug fixes

### Example Future Entries

```markdown
## [3.0.1] - 2025-01-10

### Fixed
- HOD approval comments not saving to database
- PDF generation failing for special characters
- Budget calculations rounding errors

### Changed
- Improved error messages for failed uploads
- Updated user interface colors for better contrast

## [3.1.0] - 2025-01-15

### Added
- Email notifications for approval stages
- SMS alerts for urgent requisitions
- Export to CSV functionality
- Advanced search filters

### Changed
- Redesigned dashboard layout
- Improved mobile responsiveness
```

---

## Unreleased

Changes that are in development but not yet released.

### Planned Features
- [ ] Email notification system
- [ ] SMS notifications
- [ ] Mobile app
- [ ] Offline mode
- [ ] Advanced analytics dashboard
- [ ] Integration with accounting systems
- [ ] Barcode scanning
- [ ] Inventory management
- [ ] Supplier portal
- [ ] Contract management

---

## Support

For issues or questions:
- Check TROUBLESHOOTING.md
- Review VERSION_CONTROL_GUIDE.md
- Check Git history: `git log`
