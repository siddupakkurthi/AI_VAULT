import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';
import '../models/medical_profile.dart';

class FirebaseService {
  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  static FirebaseAuth get _auth => FirebaseAuth.instance;
  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  static const String _collectionUsers = 'users';
  static const String _collectionEmergencyProfiles = 'emergencyProfiles';

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  /// Initializes Firebase gracefully with fallback to local-only mode.
  static Future<bool> init() async {
    if (_isInitialized) return true;
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _isInitialized = true;
      debugPrint('✅ Firebase initialized successfully.');
      return true;
    } catch (e) {
      _isInitialized = false;
      debugPrint('⚠️ Firebase init notice: Running in local/offline mode ($e)');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Auth Operations
  // ---------------------------------------------------------------------------

  static User? get currentUser => _isInitialized ? _auth.currentUser : null;

  static String? get currentUid => currentUser?.uid;

  static Stream<User?> get authStateChanges =>
      _isInitialized ? _auth.authStateChanges() : const Stream.empty();

  /// Sign in anonymously (guest mode).
  static Future<UserCredential?> signInAnonymously() async {
    if (!_isInitialized) return null;
    try {
      return await _auth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Anonymous Auth error: ${e.code}');
      return null;
    }
  }

  /// Sign in with Email & Password.
  static Future<UserCredential?> signInWithEmail(
      String email, String password) async {
    if (!_isInitialized) return null;
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Register with Email & Password.
  static Future<UserCredential?> registerWithEmail(
      String email, String password) async {
    if (!_isInitialized) return null;
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out.
  static Future<void> signOut() async {
    if (!_isInitialized) return;
    await _auth.signOut();
  }

  // ---------------------------------------------------------------------------
  // User Account Document (users/{userId})
  // ---------------------------------------------------------------------------

  /// Creates or updates account details in users/{userId}.
  static Future<void> saveUserAccount(User user, {String? name, String? phone}) async {
    if (!_isInitialized) return;
    try {
      final docRef = _firestore.collection(_collectionUsers).doc(user.uid);
      await docRef.set({
        'uid': user.uid,
        'name': name ?? user.displayName ?? '',
        'phone': phone ?? user.phoneNumber ?? '',
        'email': user.email ?? '',
        'isAnonymous': user.isAnonymous,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore saveUserAccount error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Emergency Profile — Atomic Batch Operations (emergencyProfiles/{userId})
  // ---------------------------------------------------------------------------

  /// Atomically saves Medical Profile to emergencyProfiles/{userId} and syncs
  /// patient name to users/{userId} in a SINGLE Firestore WriteBatch.
  static Future<bool> saveProfile(MedicalProfile profile) async {
    if (!_isInitialized) return false;
    try {
      final uid = currentUid ?? profile.id;
      final data = profile.toJson();
      data['userId'] = uid;
      data['updatedAt'] = FieldValue.serverTimestamp();

      final batch = _firestore.batch();

      // Document 1: emergencyProfiles/{userId}
      final profileRef = _firestore.collection(_collectionEmergencyProfiles).doc(uid);
      batch.set(profileRef, data, SetOptions(merge: true));

      // Document 2: users/{userId} (Keep name & phone in sync)
      if (profile.fullName.isNotEmpty || profile.userPhone.isNotEmpty) {
        final userRef = _firestore.collection(_collectionUsers).doc(uid);
        batch.set(userRef, {
          'uid': uid,
          if (profile.fullName.isNotEmpty) 'name': profile.fullName,
          if (profile.userPhone.isNotEmpty) 'phone': profile.userPhone,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      await batch.commit();
      debugPrint('✅ Profile & User atomically saved to Firestore (doc: $uid)');
      return true;
    } catch (e) {
      debugPrint('❌ Firestore saveProfile error: $e');
      return false;
    }
  }

  /// Fetches Emergency Profile from emergencyProfiles/{userId}.
  /// If name is missing in profile, automatically joins name from users/{userId}.
  static Future<MedicalProfile?> getProfileByUid(String uid) async {
    if (!_isInitialized) return null;
    try {
      final doc = await _firestore.collection(_collectionEmergencyProfiles).doc(uid).get();

      if (doc.exists && doc.data() != null) {
        final profile = MedicalProfile.fromJson(doc.data()!);

        // If profile fullName is empty, join name from users/{userId}
        if (profile.fullName.isEmpty) {
          final userDoc = await _firestore.collection(_collectionUsers).doc(uid).get();
          if (userDoc.exists && userDoc.data() != null) {
            final userName = userDoc.data()?['name'] as String? ?? '';
            if (userName.isNotEmpty) {
              return profile.copyWith(fullName: userName);
            }
          }
        }
        return profile;
      }
      return null;
    } catch (e) {
      debugPrint('Firestore getProfileByUid error: $e');
      return null;
    }
  }

  /// Legacy fetch helper by profile.id
  static Future<MedicalProfile?> getProfile(String profileId) async {
    return getProfileByUid(profileId);
  }

  /// Fast indexed query to fetch emergency profile by unique QR ID (qrId).
  static Future<MedicalProfile?> getProfileByQrId(String qrId) async {
    if (!_isInitialized || qrId.isEmpty) return null;
    try {
      final query = await _firestore
          .collection(_collectionEmergencyProfiles)
          .where('qrId', isEqualTo: qrId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return MedicalProfile.fromJson(query.docs.first.data());
      }
      return null;
    } catch (e) {
      debugPrint('Firestore getProfileByQrId error: $e');
      return null;
    }
  }

  /// Real-time stream for emergency profile updates.
  static Stream<MedicalProfile?> streamProfile(String uid) {
    if (!_isInitialized) return Stream.value(null);
    return _firestore
        .collection(_collectionEmergencyProfiles)
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return MedicalProfile.fromJson(snapshot.data()!);
      }
      return null;
    });
  }

  /// Delete emergency profile from Firestore.
  static Future<bool> deleteProfile(String uid) async {
    if (!_isInitialized) return false;
    try {
      await _firestore.collection(_collectionEmergencyProfiles).doc(uid).delete();
      return true;
    } catch (e) {
      debugPrint('Firestore deleteProfile error: $e');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Error Helper
  // ---------------------------------------------------------------------------

  /// Converts Firebase Auth error codes into user-friendly messages.
  static String friendlyAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'No internet connection. Check your network.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}
