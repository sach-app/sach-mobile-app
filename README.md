# 🛡️ SACH Mobile App (Frontend UI)

A **frontend mobile application template** designed for a decentralized FIR (First Information Report) registration system. This project serves as the visual and interactive foundation for a citizen-facing reporting portal, focusing on clean architecture and a seamless user experience.

---

## 🤔 What Does This Project Do?

This repository contains the **UI/UX implementation** of the SACH application. It demonstrates how a modern, secure citizen portal should look and feel before being connected to a live backend or blockchain network. 

Currently, the app features the complete interactive flow for:
- 📝 **Filing an FIR** — UI forms designed to capture incident details securely.
- 📍 **Location Tagging** — Integrated map interface using `flutter_map` for selecting incident coordinates.
- 🔍 **Tracking Reports** — Mocked dashboard interfaces for tracking the status of filed FIRs.
- 👤 **Profile Management** — Screens built for managing citizen identity and preferences.

---

## ✨ Key Frontend Features

| Feature | What It Means |
|---------|---------------|
| **Interactive Prototyping** | Fully navigable UI screens demonstrating the complete user journey |
| **Map Integration** | Ready-to-use OpenStreetMap rendering using `flutter_map` and `latlong2` |
| **State Management Setup** | Scaffolded stores (`fir_store`, `alert_store`) ready to be hooked up to an API |
| **Cross-Platform** | A single Flutter codebase compiled natively for both iOS and Android |
| **Responsive Design** | Adapts cleanly to different mobile screen sizes and orientations |

---

## 🏗️ Tech Stack

| Technology | Purpose |
|-----------|---------|
| **Flutter (^3.11.0)** | UI toolkit for building natively compiled mobile applications |
| **Dart** | The primary programming language for Flutter |
| **flutter_map (^7.0.2)** | Highly customizable mapping widget for Flutter |
| **latlong2 (^0.9.1)** | Lightweight library for calculating map coordinates and distances |
| **Cupertino & Material Icons** | Native-looking UI components for both iOS and Android |

---

## 📁 Project Structure

```text
sach-mobile-app/
├── pubspec.yaml            # Project dependencies and configuration
├── analysis_options.yaml   # Flutter linting and code quality rules
├── android/                # Native Android configuration files
├── ios/                    # Native iOS configuration files
├── test/                   # Unit and widget tests
└── lib/                    # Main application code
    ├── main.dart           # The main application entry point
    ├── sach_route.dart     # Application routing and navigation logic
    ├── theme.dart          # Global app styling and color schemes
    ├── app_strings.dart    # Centralized text and localization strings
    ├── models/
    │   └── fir_model.dart  # Data shape for an FIR record
    ├── stores/             # State management
    │   ├── fir_store.dart
    │   ├── user_profile_store.dart
    │   ├── alert_store.dart
    │   └── locale_store.dart
    └── screens/            # UI Views
        ├── login_screen.dart
        ├── signup_screen.dart
        ├── dashboard_screen.dart
        ├── file_fir_screen.dart
        ├── fir_detail_screen.dart
        ├── my_firs_screen.dart
        ├── alerts_screen.dart
        ├── profile_screen.dart
        └── ...settings screens
```

---

## 🚀 How to Set Up (Step by Step)

### Prerequisites

Make sure you have the following installed on your machine:
- **Flutter SDK** (Version 3.11.0 or higher) — [Download here](https://docs.flutter.dev/get-started/install)
- **Dart SDK** (Bundled with Flutter)
- **Android Studio** or **VS Code** (with Flutter/Dart extensions installed)

### 1. Clone this repository

```bash
git clone [https://github.com/koisarux/sach-mobile-app.git](https://github.com/koisarux/sach-mobile-app.git)
cd sach-mobile-app
```

### 2. Install dependencies

Fetch all the required Dart packages:
```bash
flutter pub get
```

### 3. Setup Native Environments (Optional but recommended)
- **For Android**: Ensure you have a valid Android Emulator running or a physical device connected via USB debugging.
- **For iOS**: Run `pod install` inside the `ios` directory (requires a Mac with Xcode).

### 4. Run the application

```bash
flutter run
```
This will compile the app and launch it on your connected device or emulator.

---

## 📱 Core Application Flows

| Flow | Description |
|--------|-------------|
| **Authentication** | Secure `signup_screen` and `login_screen` UI for citizen identity verification. |
| **Dashboard** | The central `dashboard_screen` providing a visual overview of active alerts and recent FIRs. |
| **FIR Management** | Navigate from `file_fir_screen` to submit a report, and `my_firs_screen` to view history. |
| **Settings** | UI configurations via `privacy_settings_screen` and `notification_settings_screen`. |

---

## 📄 License

MIT License — feel free to use this project for learning or as a portfolio piece.
