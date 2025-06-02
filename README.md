# 🏪 LONDRI Mobile Application

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL"/>
  <img src="https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white" alt="Supabase"/>
  <img src="https://img.shields.io/badge/Clean_Architecture-FF6B6B?style=for-the-badge" alt="Clean Architecture"/>
  <img src="https://img.shields.io/badge/BLoC_Pattern-4FC3F7?style=for-the-badge" alt="BLoC Pattern"/>
  <img src="https://img.shields.io/badge/Documentation-Complete-green?style=for-the-badge" alt="Documentation"/>
</div>

**LONDRI** is a comprehensive Flutter mobile application that revolutionizes laundry management
systems. Built with Clean Architecture principles and BLoC pattern, it provides secure
authentication with Role-Based Access Control (RBAC), real-time dashboard analytics, efficient
transaction management, comprehensive reporting, and customer relationship management.

**Perfect for laundry businesses of all sizes** - from small shops to large enterprises.

## ✨ Key Features

### 🔐 **Authentication & Authorization**

- **Role-Based Access Control (RBAC)** - Multi-tier permission system
- **Secure Authentication** - Powered by Supabase Auth
- **User Roles**: Super Admin, Admin, and User with distinct capabilities

### 📊 **Real-Time Dashboard Analytics**

- **Last 3 Days Statistics** - Optimized PostgreSQL functions for instant data
- **Revenue Tracking** - Real-time income monitoring with timezone support
- **Transaction Status** - Live status updates for "On Progress", "Ready for Pickup", "Picked Up"
- **Performance Optimized** - 5x faster data retrieval using server-side calculations

### 💼 **Transaction Management**

- **Efficient Recording** - Streamlined transaction entry and tracking
- **Status Management** - Complete workflow from entry to pickup
- **Customer History** - Full transaction history per customer
- **Service Integration** - Dynamic pricing and service management

### 📈 **Advanced Reporting**

- **Comprehensive Reports** - Detailed transaction and revenue analysis
- **Export Capabilities** - Data export in multiple formats
- **Period Analysis** - Custom date range reporting

### 👥 **Customer Relationship Management**

- **Customer Profiles** - Complete customer information management
- **Transaction History** - Full customer interaction timeline

## 👤 User Roles & Permissions

| Role            | Permissions                                                                                                                                                                                                 | Use Case                |
| --------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------- |
| **Super Admin** | • Manage Staffs<br>• Manage Customers<br>• Activate Customer<br>• Hard Delete Customer<br>• Manage Services<br>• Manage Transactions<br>• Hard Delete Transaction<br>• Export Reports<br>• Access Main Menu | System administration   |
| **Admin**       | • Manage Customers<br>• Manage Transactions<br>• Access Main Menu                                                                                                                                           | Branch/store management |
| **User**        | • Track Transactions                                                                                                                                                                                        | Front-desk operations   |

## 🏗️ Architecture & Project Structure

This project implements **Clean Architecture** principles with **BLoC** pattern for scalable and
maintainable code:

```
lib/
├── 📁 configs/               # Application Configuration
│   ├── assets/               # Static assets and resources
│   ├── routes/               # Navigation and routing configuration
│   ├── textstyle/            # Typography and text styling
│   ├── theme/                # Application theming and colors
│   └── i18n/                 # Internationalization (ID/EN)
├── 📁 core/                  # Core Framework Components
│   ├── error/                # Error handling and exceptions
│   ├── usecases/             # Abstract base use cases
│   └── utils/                # Utility functions and helpers
├── 📁 features/              # Feature-based Modules
│   ├── authentication/       # Auth & User Management
│   │   ├── data/             # Data sources and models
│   │   ├── domain/           # Business logic and entities
│   │   └── presentation/     # UI components and BLoC
│   └── home/                 # Dashboard & Statistics
│   └── other-features/       # Other features (e.g., transactions, customers)
├── injection_container.dart  # Dependency Injection Setup
└── main.dart                 # Application Entry Point
```

### 🏛️ Architecture Benefits

- **Separation of Concerns** - Clear boundaries between layers
- **Testability** - Easy unit and integration testing
- **Scalability** - Modular structure supports growth
- **Maintainability** - Clean code principles throughout
- **Dependency Injection** - Loose coupling between components

## 🚀 Quick Start Installation

### 📋 Prerequisites

- **Flutter SDK** (>=3.0.0)
- **Dart SDK** (>=3.0.0)
- **PostgreSQL/Supabase** account
- **IDE**: VS Code or Android Studio

### ⚡ Installation Steps

1. **Clone the repository:**

   ```bash
   git clone https://github.com/yourusername/mobile-londri.git
   cd mobile-londri
   ```

2. **Install dependencies:**

   ```bash
   flutter pub get
   ```

3. **Setup environment:**

   ```bash
   # Copy environment template
   cp .env.example .env
   # Edit .env with your Supabase credentials
   ```

4. **Database setup:**

   - Follow [Supabase Setup Guide](./docs/supabase.md)
   - Import database schema and functions

5. **Run the application:**

   ```bash
   # Debug mode
   flutter run

   # Release mode
   flutter run --release
   ```

### 🔧 Development Setup

```bash
# Run with hot reload
flutter run --hot

# Run tests
flutter test

# Build APK
flutter build apk

# Analyze code
flutter analyze
```

## 📚 Documentation Hub

<div align="center">
  <img src="https://img.shields.io/badge/Documentation-Complete-green?style=flat-square" alt="Documentation Complete"/>
  <img src="https://img.shields.io/badge/Quick_Access-Navigation-blue?style=flat-square" alt="Quick Access"/>
  <img src="https://img.shields.io/badge/Examples-Comprehensive-orange?style=flat-square" alt="Comprehensive Examples"/>
</div>

### 🎯 **Quick Start Documentation**

<table>
<tr>
<td width="50%">

#### 🚀 **Setup & Implementation**

1. **[📋 Documentation Hub](./docs/_navigation.md)** - All docs navigation
2. **[🗃️ Database Setup](./docs/supabase.md)** - PostgreSQL & Supabase
3. **[📊 Dashboard Analytics](./docs/dashboard_statistics.md)** - Real-time functions
4. **[📋 Database Schema](./docs/tables/)** - All table documentation

</td>
<td width="50%">

#### 📊 **Database Tables**

- **[👤 Users](./docs/tables/users.md)** - Authentication & RBAC
- **[🛍️ Transactions](./docs/tables/transactions.md)** - Business logic
- **[👥 Customers](./docs/tables/customers.md)** - Customer management
- **[🏷️ Services](./docs/tables/services.md)** - Service catalog

</td>
</tr>
</table>

### 📖 **Documentation Features**

- ✅ **Cross-linked navigation** between all documents
- ✅ **Step-by-step guides** with practical examples
- ✅ **Real-world code examples** for every feature
- ✅ **Performance optimization** tips and benchmarks
- ✅ **Testing procedures** and validation guides
- ✅ **Testing procedures** and validation queries
- ✅ **Troubleshooting sections** for common issues
- ✅ **Cross-references** between related documents
- ✅ **Performance metrics** and optimization tips

## 🛠️ Technical Stack & Architecture

<div align="center">

| **Layer**                   | **Technology**      | **Purpose**                   | **Documentation**                                         |
| --------------------------- | ------------------- | ----------------------------- | --------------------------------------------------------- |
| **🎨 Frontend**             | Flutter/Dart        | Cross-platform mobile UI      | Integration examples in docs                              |
| **🗄️ Database**             | PostgreSQL/Supabase | Data storage & real-time sync | [📖 Supabase Setup](./docs/supabase.md)                   |
| **⚡ Backend Logic**        | PL/pgSQL Functions  | Server-side business logic    | [📖 Dashboard Statistics](./docs/dashboard_statistics.md) |
| **🔐 Authentication**       | Supabase Auth       | Secure user management        | [📖 Users Table](./docs/tables/users.md)                  |
| **🏗️ State Management**     | BLoC Pattern        | Predictable state handling    | Clean Architecture implementation                         |
| **🌐 Internationalization** | ARB Files           | Multi-language support        | Indonesian & English                                      |

</div>

### 🚀 Technology Highlights

#### **Frontend Excellence**

- **Flutter Framework** - Single codebase for iOS and Android
- **Clean Architecture** - Scalable and maintainable code structure
- **BLoC Pattern** - Reactive state management with clear separation
- **Material Design 3** - Modern, accessible UI components

#### **Backend Performance**

- **PostgreSQL Functions** - Server-side calculations for optimal performance
- **Supabase Integration** - Real-time data synchronization
- **RPC Functions** - 5x faster data retrieval compared to complex queries
- **Timezone Support** - Proper Asia/Jakarta timezone handling

#### **Security & Reliability**

- **Role-Based Access Control** - Multi-tier permission system
- **Secure Authentication** - JWT-based authentication with Supabase
- **Data Validation** - Both client and server-side validation
- **Error Handling** - Comprehensive error management system

## 🎯 Getting Started Guide

### 📖 **Step 1: Documentation Reading Order**

1. **[Supabase Setup](./docs/supabase.md)** - Database foundation setup
2. **[Tables Documentation](./docs/tables/)** - Understand data structure
3. **[Dashboard Statistics](./docs/dashboard_statistics.md)** - Implement analytics


### 🗄️ **Step 2: Database Setup**

```sql
-- 1. Create Supabase project
-- 2. Run table creation scripts from docs/tables/
-- 3. Implement PostgreSQL functions from docs/dashboard_statistics.md
-- 4. Configure Row Level Security (RLS)
```

### 📱 **Step 3: Flutter Configuration**

```bash
# 1. Clone and setup project
git clone [repository-url]
flutter pub get

# 2. Configure environment
cp .env.example .env
# Add your Supabase URL and API key

# 3. Run application
flutter run
```

## 🔗 External Resources & References

### 📚 **Official Documentation**

- [📖 Supabase Documentation](https://supabase.com/docs) - Database and authentication
- [📖 PostgreSQL Documentation](https://www.postgresql.org/docs/) - SQL and PL/pgSQL functions
- [📖 Flutter Documentation](https://docs.flutter.dev/) - Framework and widget guides
- [📖 Dart Documentation](https://dart.dev/guides) - Language reference and best practices

### 🛠️ **Development Tools**

- [🔧 VS Code Flutter Extension](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)
- [🔧 Android Studio](https://developer.android.com/studio) - Full IDE for Android development
- [🔧 Supabase CLI](https://supabase.com/docs/guides/cli) - Database management tools

### 🎓 **Learning Resources**

- [📺 Flutter Widget of the Week](https://www.youtube.com/playlist?list=PLjxrf2q8roU23XGwz3Km7sQZFTdB996iG)
- [📺 PostgreSQL Tutorial](https://www.postgresqltutorial.com/)
- [📺 Clean Architecture Guide](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

## 🤝 Contributing & Support

### 🙋 **Getting Help**

- 📧 **Email**: [abuamar.albadawi@gmail.com](mailto:abuamar.albadawi@gmail.com)
- 📖 **Documentation**: Check our comprehensive docs first
- 🐛 **Issues**: Report bugs with detailed reproduction steps
- 💡 **Feature Requests**: Suggest improvements and new features

### 👥 **Contributing Guidelines**

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m '[AMAZING-FEATURE] : Add feature description`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request with detailed description

### 📋 **Code Standards**

- Follow **Clean Architecture** principles
- Update **documentation** for any changes
- Use **consistent code formatting** (dart format)
- Follow **conventional commits** for commit messages

---

<div align="center">
  <h3>🏪 LONDRI Mobile Application</h3>
  <p><em>Revolutionizing laundry management with modern technology</em></p>
  <p>
    <strong>Built with ❤️ using Flutter & PostgreSQL</strong><br>
    <em>Clean Architecture • BLoC Pattern • Real-time Analytics</em>
  </p>
  
  <div>
    <img src="https://img.shields.io/badge/Made_with-Flutter-02569B?style=flat&logo=flutter" alt="Made with Flutter"/>
    <img src="https://img.shields.io/badge/Powered_by-PostgreSQL-316192?style=flat&logo=postgresql" alt="Powered by PostgreSQL"/>
    <img src="https://img.shields.io/badge/Hosted_on-Supabase-3ECF8E?style=flat&logo=supabase" alt="Hosted on Supabase"/>
  </div>
</div>
