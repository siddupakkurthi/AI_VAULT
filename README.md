# 🆘 AI Life Vault — Emergency Medical ID & AI Risk System

<p align="center">
  <img src="assets/images/app_logo.png" width="120" height="120" alt="AI Life Vault Logo" />
</p>

<p align="center">
  <b>Universal Emergency Medical ID, Google Gemini AI Clinical Risk Analysis & Offline-First SOS Response System</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/Firebase-Core%20%7C%20Auth%20%7C%20Firestore-FFCA28?logo=firebase" alt="Firebase" />
  <img src="https://img.shields.io/badge/Google%20Gemini-1.5%20Flash-8E44AD?logo=google" alt="Gemini AI" />
  <img src="https://img.shields.io/badge/Offline-Hive%20Local%20Storage-27AE60" alt="Offline First" />
  <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License" />
</p>

---

## 📖 About AI Life Vault

**AI Life Vault** is a mission-critical mobile application designed to save lives during medical emergencies when patients are unconscious or unable to communicate. 

First responders, paramedics, and ER doctors can instantly scan a patient's **Universal Emergency QR Code** to access vital medical info—blood type, critical allergies, pre-existing conditions, active medications, organ donor status, emergency contact details, and an **AI-generated clinical risk assessment powered by Google Gemini 1.5 Flash**.

The app follows an **offline-first architecture**, utilizing local Hive storage for zero-latency instant access while automatically synchronizing data with Cloud Firestore when connected to the internet.

---

## 🔥 Key Features

### 1. 🔐 Secure Authentication & Multi-User Support
- **Firebase Auth**: Sign up/login with Email & Password or continue in **Guest Mode**.
- **User Account Link**: User credentials (`name`, `email`, `phone`, `createdAt`) are stored under `users/{userId}`.

### 2. 🩸 Complete Emergency Medical Profile
- Stores patient demographics (Name, Age, Gender, Blood Group, Height, Weight).
- Critical medical information (Allergies, Existing Conditions, Active Medications, Medical Notes).
- In Case of Emergency (ICE) contact name, relationship, and phone number.
- Registered Organ Donor verification badge.

### 3. 🤖 Google Gemini 1.5 Flash AI Emergency Summaries
- Analyzes patient medical records in real time.
- Highlights high-priority clinical risk flags (e.g., Insulin dependency, Cardiovascular alerts, Drug interaction warnings).
- **Built-in Offline Fallback**: Automatically switches to an embedded rule-based AI clinical engine when offline or if no API key is set.

### 4. 🔲 Universal QR Emergency Access
- Generates a high-contrast QR code with a compact payload (`qrId`, patient phone, blood group, allergies, ICE contact).
- Optimizes density for instant sub-second scanning under low-light or accident scene conditions.
- **Privacy-First**: Never exposes passwords, private credentials, or auth tokens inside QR data.

### 5. 🚨 First Responder Paramedic View
- High-visibility paramedic screen tailored for emergency personnel.
- Flashing emergency siren banner, giant blood group pill, and high-impact alert boxes (*"DO NOT ADMINISTER ALLERGENS"*).

### 6. 📲 One-Tap Instant SOS Actions
- 📞 **Direct Emergency Call**: Instantly dials ICE contact (`tel:${emergencyPhone}`).
- 📱 **Send SOS SMS**: Pre-fills emergency SMS with patient name, blood group, allergies, and unique QR ID.
- 📤 **Share SOS Card**: Shares formatted emergency medical card via WhatsApp, SMS, or system share sheet.

---

## 🗄️ Database Architecture & Firestore Schema

```text
users/{userId}
 ├── uid: string
 ├── name: string
 ├── email: string
 ├── phone: string
 ├── isAnonymous: boolean
 ├── createdAt: timestamp
 └── updatedAt: timestamp

emergencyProfiles/{userId}
 ├── userId: string (Firebase Auth UID)
 ├── fullName: string
 ├── userPhone: string
 ├── age: number
 ├── gender: string
 ├── bloodGroup: string
 ├── height: number
 ├── weight: number
 ├── allergies: array<string>
 ├── diseases: array<string>
 ├── medications: array<string>
 ├── emergencyContactName: string
 ├── emergencyPhone: string
 ├── relationship: string
 ├── isOrganDonor: boolean
 ├── medicalNotes: string
 ├── aiSummary: string
 ├── qrId: string (e.g., "EM-IND-8A2F1C9D")
 ├── createdAt: timestamp
 └── updatedAt: timestamp
```

---

## 🛡️ Production Firestore Security Rules

To configure database security in your **Firebase Console → Firestore Database → Rules**:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // User account documents (owner read/write)
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Emergency Profiles (owner write, public read for emergency QR scanning)
    match /emergencyProfiles/{userId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 📂 Project Structure

```text
lib/
├── main.dart                      # App entry point & service initialization
├── firebase_options.dart          # Firebase platform configuration
├── core/
│   ├── constants/                 # AppColors, AppStrings
│   └── router/                    # AppRouter navigation & route gating
├── models/
│   └── medical_profile.dart       # Hive annotated MedicalProfile model
├── providers/
│   ├── auth_provider.dart         # Firebase Auth state management
│   ├── profile_provider.dart      # Hive local cache + Firestore sync
│   └── theme_provider.dart        # Dark / Light theme state
├── services/
│   ├── firebase_service.dart      # Firestore WriteBatch & Auth operations
│   ├── ai_summary_service.dart    # Gemini 1.5 Flash API + Offline AI rules
│   ├── sos_service.dart           # Phone call dialer, SMS & Share alerts
│   └── storage_service.dart       # Hive local persistent storage
└── screens/
    ├── auth/login_screen.dart     # Dynamic height Sign In / Register UI
    ├── dashboard_screen.dart      # Dashboard with medical cards & quick actions
    ├── emergency_preview_screen.dart # Paramedic high-visibility emergency view
    ├── qr_screen.dart             # QR Code generator & SOS actions grid
    ├── settings_screen.dart       # Preferences, Account & Cloud Sync management
    └── splash_screen.dart         # Animated splash screen with auth routing
```

---

## 🚀 Getting Started

### 1. Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.19 or higher)
- [Dart SDK](https://dart.dev/get-dart) (v3.0 or higher)
- Android Studio / VS Code with Flutter extension
- Firebase account

### 2. Clone the Repository
```bash
git clone https://github.com/siddupakkurthi/AI_VAULT.git
cd AI_VAULT
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Run the Application

#### Standard Mode (Local AI Fallback Engine)
```bash
flutter run
```

#### With Live Gemini 1.5 Flash AI Enabled
```bash
flutter run --dart-define=GEMINI_API_KEY="YOUR_GEMINI_API_KEY"
```

#### Build Release APK
```bash
flutter build apk --dart-define=GEMINI_API_KEY="YOUR_GEMINI_API_KEY"
```

---

## 📝 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

<p align="center">
  Developed with ❤️ for Emergency First Responders & Healthcare Accessibility.
</p>
