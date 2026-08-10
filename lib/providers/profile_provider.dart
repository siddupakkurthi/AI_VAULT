import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/medical_profile.dart';
import '../services/storage_service.dart';
import '../services/ai_summary_service.dart';
import '../services/firebase_service.dart';

class ProfileProvider extends ChangeNotifier {
  MedicalProfile? _profile;
  bool _isLoading = false;
  bool _isCloudSyncing = false;
  bool _isCloudSynced = false;
  String? _errorMessage;

  MedicalProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isCloudSyncing => _isCloudSyncing;
  bool get isCloudSynced => _isCloudSynced;
  String? get errorMessage => _errorMessage;
  bool get hasProfile => _profile != null;

  ProfileProvider() {
    _loadProfile();
  }

  // ---------------------------------------------------------------------------
  // Initial Load
  // ---------------------------------------------------------------------------

  Future<void> _loadProfile() async {
    // 1. Load from local Hive cache first (instant, works offline)
    _profile = HiveStorageService.getProfile();
    notifyListeners();

    // 2. If Firebase is ready & user is authenticated, sync from cloud
    if (FirebaseService.isInitialized && FirebaseService.currentUid != null) {
      await _fetchFromCloud(FirebaseService.currentUid!);
    }
  }

  /// Called externally when the user has just signed in (from splash/auth screen).
  /// Fetches the profile from Firestore and loads it into memory.
  Future<void> loadProfileForUser(String uid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cloudProfile = await FirebaseService.getProfileByUid(uid);
      if (cloudProfile != null) {
        await HiveStorageService.saveProfile(cloudProfile);
        _profile = cloudProfile;
        _isCloudSynced = true;
      } else {
        // No cloud profile yet — keep local if exists
        _profile = HiveStorageService.getProfile();
      }
    } catch (e) {
      debugPrint('loadProfileForUser error: $e');
      _profile = HiveStorageService.getProfile();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchFromCloud(String uid) async {
    try {
      final cloudProfile = await FirebaseService.getProfileByUid(uid);
      if (cloudProfile != null) {
        await HiveStorageService.saveProfile(cloudProfile);
        _profile = cloudProfile;
        _isCloudSynced = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Cloud fetch on init error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Save Profile
  // ---------------------------------------------------------------------------

  /// Saves or updates profile:
  /// 1. Generates AI summary
  /// 2. Saves to local Hive (offline-first)
  /// 3. Syncs to Firestore using Firebase Auth UID
  Future<void> saveProfile(MedicalProfile profile) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Generate AI summary (Gemini AI or fallback rules)
      final summary = await AiSummaryService.generateSummaryAsync(profile);
      final updated = profile.copyWith(
        aiSummary: summary,
        updatedAt: DateTime.now(),
      );

      // Save locally first (zero latency, works offline)
      await HiveStorageService.saveProfile(updated);
      _profile = updated;

      // Sync to Firebase Cloud Firestore
      if (FirebaseService.isInitialized) {
        _isCloudSyncing = true;
        notifyListeners();

        // Sign in anonymously if no user (shouldn't happen normally after auth gate)
        if (FirebaseService.currentUser == null) {
          await FirebaseService.signInAnonymously();
        }

        final synced = await FirebaseService.saveProfile(updated);
        _isCloudSynced = synced;
        _isCloudSyncing = false;
      }
    } catch (e) {
      _errorMessage = 'Failed to save profile. Please try again.';
      debugPrint('saveProfile error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Manual Cloud Sync
  // ---------------------------------------------------------------------------

  /// Manually push the local profile to Firebase Cloud Firestore.
  Future<bool> syncToCloud() async {
    if (_profile == null || !FirebaseService.isInitialized) {
      _isCloudSynced = false;
      notifyListeners();
      return false;
    }

    _isCloudSyncing = true;
    notifyListeners();

    try {
      if (FirebaseService.currentUser == null) {
        await FirebaseService.signInAnonymously();
      }

      final success = await FirebaseService.saveProfile(_profile!);
      _isCloudSynced = success;
      return success;
    } catch (e) {
      debugPrint('Cloud sync failed: $e');
      _isCloudSynced = false;
      return false;
    } finally {
      _isCloudSyncing = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Restore from Cloud
  // ---------------------------------------------------------------------------

  /// Fetch profile from Firebase Cloud Firestore by UID.
  Future<bool> restoreFromCloud(String uid) async {
    if (!FirebaseService.isInitialized) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final cloudProfile = await FirebaseService.getProfileByUid(uid);
      if (cloudProfile != null) {
        await HiveStorageService.saveProfile(cloudProfile);
        _profile = cloudProfile;
        _isCloudSynced = true;
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to restore from cloud.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Delete Profile
  // ---------------------------------------------------------------------------

  /// Deletes the profile from local storage. Also removes from Firestore
  /// if user is authenticated. Does NOT delete the Firestore doc on sign-out
  /// (only on explicit delete action).
  Future<void> deleteProfile() async {
    final uid = FirebaseService.currentUid;
    if (_profile != null && FirebaseService.isInitialized && uid != null) {
      await FirebaseService.deleteProfile(uid);
    }

    await HiveStorageService.deleteProfile();
    _profile = null;
    _isCloudSynced = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Clear in-memory state on sign-out (does NOT delete cloud data)
  // ---------------------------------------------------------------------------

  void clearProfileState() {
    _profile = null;
    _isCloudSynced = false;
    _isCloudSyncing = false;
    _errorMessage = null;
    // Also clear local Hive cache so next user starts fresh
    HiveStorageService.deleteProfile();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  MedicalProfile createEmptyProfile() {
    const uuid = Uuid();
    final id = uuid.v4();
    final qrId = 'EM-IND-${id.substring(0, 8).toUpperCase()}';

    return MedicalProfile(
      id: id,
      fullName: '',
      age: 0,
      gender: '',
      bloodGroup: '',
      height: 0,
      weight: 0,
      emergencyContactName: '',
      emergencyPhone: '',
      relationship: '',
      allergies: [],
      diseases: [],
      medications: [],
      isOrganDonor: false,
      medicalNotes: '',
      aiSummary: '',
      qrId: qrId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  String exportJson() {
    if (_profile == null) return '';
    return HiveStorageService.exportProfileJson(_profile!);
  }

  Future<bool> importJson(String jsonString) async {
    final imported = HiveStorageService.importProfileJson(jsonString);
    if (imported == null) return false;
    await saveProfile(imported);
    return true;
  }
}
