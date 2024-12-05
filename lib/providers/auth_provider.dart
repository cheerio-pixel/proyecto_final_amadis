
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final ApiService _apiService = ApiService();
  bool _isAuthenticated = false;
  String? _token;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;

  Future<bool> login(String username, String password) async {
    try {
      // Use the ApiService to perform login
      final success = await _apiService.login(username, password);
      if (success) {
        _isAuthenticated = true;
        _token = await _storage.read(key: 'token');
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      throw e;
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _storage.delete(key: 'token');
      _isAuthenticated = false;
      _token = null;
      notifyListeners();
    } catch (e) {
      // Handle logout error
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      _token = await _storage.read(key: 'token');
      if (_token != null) {
        // Optionally verify token validity with server
        final userInfo = await _apiService.getUserInfo();
        _isAuthenticated = userInfo != null;
      } else {
        _isAuthenticated = false;
      }
      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      _token = null;
      notifyListeners();
    }
  }
}