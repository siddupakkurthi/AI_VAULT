# Authentication + Firebase Full Setup Plan

## Summary

The **AI Life Vault** app already has Firebase dependencies (firebase_core, firebase_auth, cloud_firestore) and service/provider code written — but there is **no Login/Register UI screen**, **no `google-services.json`** (critical for Android to connect to Firebase), and the **splash screen skips directly to dashboard** without checking auth state.

I'll implement:
1. A beautiful **Login/Register screen** (email + password + anonymous guest)
2. **Auth-gated routing** — unauthenticated users go to login, authenticated go to dashboard
3. Fix the **Android `google-services.json`** issue (must be added by you)
4. Fix the **Android `build.gradle.kts`** to include Google Services plugin
5. Wire up **profile data to be linked to the logged-in user's UID** in Firestore

---

## User Review Required

> [!IMPORTANT]
> **You must do ONE thing in Firebase Console** for this to work:
> Download `google-services.json` from your Firebase project and place it at:
> `android/app/google-services.json`
> (See the detailed Firebase Setup Guide at the bottom)

> [!WARNING]
> The Android `firebase_options.dart` currently uses the **web** `appId` for android — this is incorrect. The proper android `appId` must match the one in your `google-services.json`. I'll flag this but you need to get the correct value from Firebase Console.

---

## Proposed Changes

### Auth UI
#### [NEW] `lib/screens/auth/login_screen.dart`
- Beautiful dark glassmorphism login/register screen
- Toggle between Login and Register tabs
- Email + Password fields with validation
- "Continue as Guest" anonymous sign-in button
- Firebase error message display

---

### Router Updates
#### [MODIFY] `lib/core/router/app_router.dart`
- Add `/login` route
- Add redirect logic: if not authenticated → go to `/login`; if authenticated → go to `/dashboard`

---

### Splash Screen Updates
#### [MODIFY] `lib/screens/splash_screen.dart`
- After loading, check auth state and redirect to login or dashboard accordingly

---

### Auth Provider Updates
#### [MODIFY] `lib/providers/auth_provider.dart`
- Add Google Sign-In (optional, can skip for now)
- Improve error parsing (Firebase errors → human-readable messages)

---

### Firebase Service Updates
#### [MODIFY] `lib/services/firebase_service.dart`
- Link Firestore profile document to `uid` (already partially done, but strengthen it)
- Add method to fetch profile by UID (not just profileId)

---

### Profile Provider Updates
#### [MODIFY] `lib/providers/profile_provider.dart`
- On auth state change (user logs in), auto-load their profile from Firestore by UID
- On sign out, clear local profile

---

### Android Firebase Config
#### [MODIFY] `android/app/build.gradle.kts`
- Add `id("com.google.gms.google-services")` plugin

#### [MODIFY] `android/build.gradle.kts`
- Add Google Services classpath dependency

#### [NEW] `android/app/google-services.json`
> [!CAUTION]
> This file must be **manually downloaded** from Firebase Console → Your Project → Project Settings → Your Apps → Android App → Download `google-services.json`
> Place it at `android/app/google-services.json`

---

## Firebase Console Setup Guide

Here's exactly what you need to do in the Firebase console:

### Step 1: Verify your Firebase project
- Go to [https://console.firebase.google.com](https://console.firebase.google.com)
- Open project: **blood-bank-app-9c6db**

### Step 2: Enable Authentication
1. Click **Authentication** → **Get Started**
2. Click **Sign-in method** tab
3. Enable **Email/Password** → Save
4. Enable **Anonymous** → Save

### Step 3: Enable Firestore
1. Click **Firestore Database** → **Create database**
2. Choose **Start in test mode** (for development)
3. Choose a region near you (e.g., `asia-south1` for India)

### Step 4: Add Android App (if not already added)
1. Click the gear icon → **Project settings**
2. Under "Your apps" → click **Add app** → Android icon
3. Android package name: `com.ailifevault.ai_life_vault`
4. Download `google-services.json`
5. Place it at: `android/app/google-services.json`

### Step 5: Set Firestore Security Rules
In Firestore → Rules, paste:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /medical_profiles/{profileId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null;
    }
  }
}
```

---

## Verification Plan

### Automated
- `flutter pub get` — ensure no dependency errors
- `flutter analyze` — ensure no static errors

### Manual
- App launches → shows Login screen
- Register with email → lands on dashboard
- Profile saved → appears in Firestore Console under `medical_profiles`
- Sign out → returns to Login screen
- Login again with same email → profile loads back from Firestore
