import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<User?>? _authSubscription;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isAnonymous => _user?.isAnonymous ?? false;
  bool get isSignedIn => _user != null;
  String get uid => _user?.uid ?? '';
  String get userEmail => _user?.email ?? (_user?.isAnonymous == true ? 'Guest User' : 'Not signed in');
  String get displayName => _user?.displayName ?? userEmail;

  AuthProvider() {
    _initAuth();
  }

  void _initAuth() {
    if (FirebaseService.isInitialized) {
      _user = FirebaseService.currentUser;
      _authSubscription = FirebaseService.authStateChanges.listen((user) {
        _user = user;
        notifyListeners();
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Sign In Anonymously (Guest Mode)
  // ---------------------------------------------------------------------------

  Future<bool> signInAnonymously() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final creds = await FirebaseService.signInAnonymously();
      _user = creds?.user;
      if (_user != null) {
        await FirebaseService.saveUserAccount(_user!);
      }
      return _user != null;
    } on FirebaseAuthException catch (e) {
      _errorMessage = FirebaseService.friendlyAuthError(e);
      return false;
    } catch (e) {
      _errorMessage = 'Guest sign in failed. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Sign In with Email & Password
  // ---------------------------------------------------------------------------

  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final creds = await FirebaseService.signInWithEmail(email, password);
      _user = creds?.user;
      if (_user != null) {
        await FirebaseService.saveUserAccount(_user!);
      }
      return _user != null;
    } on FirebaseAuthException catch (e) {
      _errorMessage = FirebaseService.friendlyAuthError(e);
      return false;
    } catch (e) {
      _errorMessage = 'Login failed. Please check your connection.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Register with Email & Password
  // ---------------------------------------------------------------------------

  Future<bool> registerWithEmail(String email, String password, {String? name}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final creds = await FirebaseService.registerWithEmail(email, password);
      _user = creds?.user;
      if (_user != null) {
        if (name != null && name.isNotEmpty) {
          try {
            await _user!.updateDisplayName(name);
          } catch (_) {}
        }
        await FirebaseService.saveUserAccount(_user!, name: name);
      }
      return _user != null;
    } on FirebaseAuthException catch (e) {
      _errorMessage = FirebaseService.friendlyAuthError(e);
      return false;
    } catch (e) {
      _errorMessage = 'Registration failed. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Sign Out
  // ---------------------------------------------------------------------------

  Future<void> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await FirebaseService.signOut();
      _user = null;
    } catch (e) {
      _errorMessage = 'Sign out failed. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
