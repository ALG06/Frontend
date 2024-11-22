import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  String? _accessToken;
  String? _refreshToken;
  String? _email;
  String? _name;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  String? get email => _email;
  String? get name => _name;
  bool get isLoading => _isLoading;

  // Constants
  static const String baseUrl = 'http://127.0.0.1:5000';

  Future<void> checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString('access_token');
      _refreshToken = prefs.getString('refresh_token');
      _email = prefs.getString('email');
      _name = prefs.getString('name');
      _isAuthenticated = _accessToken != null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error checking auth status: $e');
      _isAuthenticated = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _handleAuthSuccess(data);
        return true;
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('Login Error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _handleAuthSuccess(Map<String, dynamic> data) async {
    _accessToken = data['access_token'];
    _refreshToken = data['refresh_token'];
    _email = data['email'];
    _name = data['name'];
    _isAuthenticated = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', _accessToken!);
    await prefs.setString('refresh_token', _refreshToken!);
    await prefs.setString('email', _email!);
    await prefs.setString('name', _name!);

    notifyListeners();
  }

  Future<void> logout() async {
    try {
      _accessToken = null;
      _refreshToken = null;
      _email = null;
      _name = null;
      _isAuthenticated = false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      notifyListeners();
    } catch (e) {
      debugPrint('Logout Error: $e');
      throw Exception('Failed to logout: $e');
    }
  }
}
