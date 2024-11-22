import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/login_credentials.dart';

class AuthService {
  static const String _credentialsKey = 'stored_credentials';
  static const String _pinKey = 'stored_pin';
  static const String _useBiometricKey = 'use_biometric_auth';
  final LocalAuthentication _localAuth = LocalAuthentication();
  late final SharedPreferences _prefs;
  static AuthService? _instance;
  static bool _initialized = false;

  AuthService._();

  static Future<AuthService> getInstance() async {
    if (_instance == null || !_initialized) {
      _instance = AuthService._();
      await _instance!._initializeService();
    }
    return _instance!;
  }

  Future<void> _initializeService() async {
    try {
      print('Initializing AuthService...');
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
      print('AuthService initialized successfully');
      _printStoredData();
    } catch (e) {
      print('Error initializing AuthService: $e');
      _initialized = false;
      rethrow;
    }
  }

  void _printStoredData() {
    print('Current stored data:');
    print('Has credentials: ${_prefs.containsKey(_credentialsKey)}');
    if (_prefs.containsKey(_credentialsKey)) {
      final storedData = _prefs.getString(_credentialsKey);
      print('Stored credentials data: $storedData');
    }
    print('Has PIN: ${_prefs.containsKey(_pinKey)}');
    print('Use biometric: ${_prefs.getBool(_useBiometricKey)}');
  }

  Future<bool> canUseBiometrics() async {
    try {
      print('Checking biometric capability');
      final canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final canAuthenticate = await _localAuth.isDeviceSupported();
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      print('Can authenticate with biometrics: $canAuthenticateWithBiometrics');
      print('Device supports biometrics: $canAuthenticate');
      print('Available biometrics: $availableBiometrics');
      return canAuthenticateWithBiometrics && canAuthenticate;
    } on PlatformException catch (e) {
      print('Error checking biometric capability: $e');
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      print('Starting biometric authentication');
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access your account',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      print('Biometric authentication result: $authenticated');
      return authenticated;
    } on PlatformException catch (e) {
      print('Error during biometric authentication: $e');
      return false;
    }
  }

  Future<bool> saveCredentials(LoginCredentials credentials, bool useBiometric) async {
    try {
      print('Saving credentials and preferences');
      final json = jsonEncode(credentials.toJson());
      print('Credentials to save: $json');
      
      final results = await Future.wait([
        _prefs.setString(_credentialsKey, json),
        _prefs.setBool(_useBiometricKey, useBiometric),
      ]);

      await _prefs.reload(); // Force reload preferences
      _printStoredData();
      
      return results.every((success) => success == true);
    } catch (e) {
      print('Error saving credentials: $e');
      return false;
    }
  }

  Future<bool> savePin(String pin) async {
    try {
      print('Saving PIN');
      final result = await _prefs.setString(_pinKey, pin);
      await _prefs.reload(); // Force reload preferences
      print('PIN save result: $result');
      return result;
    } catch (e) {
      print('Error saving PIN: $e');
      return false;
    }
  }

  String? getPin() {
    try {
      final pin = _prefs.getString(_pinKey);
      print('Retrieved PIN: ${pin != null ? 'Present' : 'Not found'}');
      return pin;
    } catch (e) {
      print('Error getting PIN: $e');
      return null;
    }
  }

  bool hasPin() {
    try {
      final hasPin = _prefs.containsKey(_pinKey);
      print('Has PIN stored: $hasPin');
      return hasPin;
    } catch (e) {
      print('Error checking PIN: $e');
      return false;
    }
  }

  bool shouldUseBiometric() {
    try {
      final useBiometric = _prefs.getBool(_useBiometricKey) ?? false;
      print('Should use biometric: $useBiometric');
      return useBiometric;
    } catch (e) {
      print('Error checking biometric setting: $e');
      return false;
    }
  }

  LoginCredentials? getSavedCredentials() {
    try {
      final json = _prefs.getString(_credentialsKey);
      print('Retrieved stored credentials: $json');
      if (json == null) return null;
      
      final map = jsonDecode(json) as Map<String, dynamic>;
      return LoginCredentials.fromJson(map);
    } catch (e) {
      print('Error getting credentials: $e');
      return null;
    }
  }

  Future<bool> clearCredentials() async {
    try {
      print('Clearing all stored credentials and settings');
      final results = await Future.wait([
        _prefs.remove(_credentialsKey),
        _prefs.remove(_pinKey),
        _prefs.remove(_useBiometricKey),
      ]);
      await _prefs.reload(); // Force reload preferences
      _printStoredData();
      return results.every((success) => success == true);
    } catch (e) {
      print('Error clearing credentials: $e');
      return false;
    }
  }

  bool hasSavedCredentials() {
    try {
      final hasCredentials = _prefs.containsKey(_credentialsKey);
      print('Has saved credentials: $hasCredentials');
      return hasCredentials;
    } catch (e) {
      print('Error checking credentials: $e');
      return false;
    }
  }

  Future<bool> verifyPin(String enteredPin) async {
    try {
      final savedPin = getPin();
      final matches = savedPin != null && savedPin == enteredPin;
      print('PIN verification result: $matches');
      return matches;
    } catch (e) {
      print('Error verifying PIN: $e');
      return false;
    }
  }
}
