# LONDRI Mobile Application

LONDRI is a Flutter app that simplifies laundry management. It offers secure authentication with RBAC, efficient transaction recording, report generation, and customer information management. Suitable for Super Admins, Admins, and Users, LONDRI ensures an organized laundry management experience.

## Features

- Authentication implement RBAC
- Record and manage laundry transactions efficiently.
- Generate comprehensive transaction reports.
- Manage customer information and history.

## Users on this System

- **Super Admin**: Access to all data and functionalities.
- **Admin**: Manage roles and services.
- **User**: Manage customers and transactions.

## Project Structure

This project follows the Clean Architecture principles and uses BLoC for state management. Below is the folder structure:

```
lib/
├── configs/
│   ├── assets/
│   ├── routes/
│   ├── textstyle/
│   ├── theme/
├── core/
│   ├── error/
│   ├── usecases/
│   └── utils/
├── features/
│   ├── authentication/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── home/
│       ├── data/
│       ├── domain/
│       └── presentation/
├── injection_container.dart
└── main.dart
```

- `configs/`: Contains configuration files such as assets, routes, text styles, and themes.
- `core/`: Contains core functionalities such as error handling, use cases, and utility functions.
- `features/`: Contains the different features of the application, each feature is divided into `data`, `domain`, and `presentation` layers.
- `injection_container.dart`: Handles dependency injection.
- `main.dart`: The entry point of the application.

## Installation

1. Clone the repository:
    ```bash
    git clone https://github.com/yourusername/mobile-londri.git
    ```
2. Navigate to the project directory:
    ```bash
    cd mobile-londri
    ```
3. Install dependencies:
    ```bash
    flutter pub get
    ```
4. Run the application:
    ```bash
    flutter run
    ```

## Requirements

- Flutter SDK
- Dart SDK

## Contact

For any inquiries or issues, please contact [abuamar.albadawi@gmail.com](mailto:abuamar.albadawi@gmail.com).
