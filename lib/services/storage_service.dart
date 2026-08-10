import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/medical_profile.dart';

class HiveStorageService {
  static const String _profileBoxName = 'medical_profiles';
  static const String _settingsBoxName = 'settings';
  static const String _profileKey = 'current_profile';

  static Box<MedicalProfile>? _profileBox;
  static Box? _settingsBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MedicalProfileAdapter());
    }
    _profileBox = await Hive.openBox<MedicalProfile>(_profileBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  static Box<MedicalProfile> get profileBox {
    if (_profileBox == null || !_profileBox!.isOpen) {
      throw Exception('Profile box not initialized');
    }
    return _profileBox!;
  }

  static Box get settingsBox {
    if (_settingsBox == null || !_settingsBox!.isOpen) {
      throw Exception('Settings box not initialized');
    }
    return _settingsBox!;
  }

  // Profile Operations
  static Future<void> saveProfile(MedicalProfile profile) async {
    await profileBox.put(_profileKey, profile);
  }

  static MedicalProfile? getProfile() {
    return profileBox.get(_profileKey);
  }

  static Future<void> deleteProfile() async {
    await profileBox.delete(_profileKey);
  }

  static bool hasProfile() {
    return profileBox.containsKey(_profileKey);
  }

  // Settings Operations
  static Future<void> setSetting(String key, dynamic value) async {
    await settingsBox.put(key, value);
  }

  static T getSetting<T>(String key, T defaultValue) {
    return settingsBox.get(key, defaultValue: defaultValue) as T;
  }

  // Export / Import
  static String exportProfileJson(MedicalProfile profile) {
    return jsonEncode(profile.toJson());
  }

  static MedicalProfile? importProfileJson(String jsonString) {
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return MedicalProfile.fromJson(map);
    } catch (_) {
      return null;
    }
  }
}
