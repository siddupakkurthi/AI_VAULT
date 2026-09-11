import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/hospital_model.dart';
import '../services/hospital_service.dart';

enum HospitalSearchStatus {
  idle,
  loadingLocation,
  searchingHospitals,
  success,
  permissionDenied,
  locationDisabled,
  noHospitals,
  error,
}

class HospitalProvider extends ChangeNotifier {
  HospitalSearchStatus _status = HospitalSearchStatus.idle;
  HospitalSearchStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  double? _responderLat;
  double? get responderLat => _responderLat;

  double? _responderLng;
  double? get responderLng => _responderLng;

  List<Hospital> _hospitals = [];
  List<Hospital> get hospitals => List.unmodifiable(_hospitals);

  Hospital? _selectedHospital;
  Hospital? get selectedHospital => _selectedHospital;

  void selectHospital(Hospital? hospital) {
    _selectedHospital = hospital;
    notifyListeners();
  }

  /// Initiates location permission check and fetches emergency hospitals near the responder.
  Future<bool> fetchNearbyEmergencyHospitals() async {
    _status = HospitalSearchStatus.loadingLocation;
    _errorMessage = null;
    _hospitals = [];
    _selectedHospital = null;
    notifyListeners();

    try {
      // 1. Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _status = HospitalSearchStatus.locationDisabled;
        _errorMessage = 'Please enable location services to find emergency care nearby.';
        notifyListeners();
        return false;
      }

      // 2. Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _status = HospitalSearchStatus.permissionDenied;
          _errorMessage = 'Location permission is required to find emergency care near you.';
          notifyListeners();
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _status = HospitalSearchStatus.permissionDenied;
        _errorMessage = 'Location permission is permanently denied. Please enable it in system settings.';
        notifyListeners();
        return false;
      }

      // 3. Get responder's current position (with fallback for web browser prompts)
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 30),
          ),
        );
      } catch (e) {
        debugPrint('High accuracy position fetch failed or timed out: $e. Retrying with medium accuracy...');
        try {
          position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 15),
            ),
          );
        } catch (e2) {
          debugPrint('Medium accuracy position fetch failed: $e2');
          position = await Geolocator.getLastKnownPosition();
        }
      }

      if (position == null) {
        _status = HospitalSearchStatus.error;
        _errorMessage = 'Unable to determine your current location. Please ensure GPS is enabled and permissions are granted.';
        notifyListeners();
        return false;
      }

      _responderLat = position.latitude;
      _responderLng = position.longitude;

      // 4. Search nearby emergency care facilities
      _status = HospitalSearchStatus.searchingHospitals;
      notifyListeners();

      final results = await HospitalService.fetchNearbyHospitals(
        _responderLat!,
        _responderLng!,
      );

      _hospitals = results;

      if (_hospitals.isEmpty) {
        _status = HospitalSearchStatus.noHospitals;
        _errorMessage = 'No nearby emergency hospitals were found.';
      } else {
        _status = HospitalSearchStatus.success;
        _selectedHospital = _hospitals.first;
      }

      notifyListeners();
      return _status == HospitalSearchStatus.success;
    } catch (e) {
      debugPrint('Error in fetchNearbyEmergencyHospitals: $e');
      _status = HospitalSearchStatus.error;
      _errorMessage = 'Unable to load nearby emergency care. Please check your internet connection.';
      notifyListeners();
      return false;
    }
  }

  /// Opens app settings if location permission was permanently denied
  Future<void> openSettings() async {
    await Geolocator.openAppSettings();
  }

  /// Opens location service settings if GPS is disabled
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
}
