import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  String? _id;
  String? _email;
  String? _name;
  String? _phone;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get email => _email;
  String? get name => _name;
  bool get isLoading => _isLoading;

  static const String baseUrl = 'http://127.0.0.1:5000/donors';

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

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final donor = data['donor'];

        await _handleAuthSuccess(donor);
        return true;
      } else {
        debugPrint('Login error: ${data['error']}');
        return false;
      }
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signup(
      String name, String email, String password, String phone) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.post(
        Uri.parse('$baseUrl/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
        }),
      );

      // Check if response is JSON
      String contentType = response.headers['content-type'] ?? '';
      if (!contentType.contains('application/json')) {
        debugPrint('Server returned non-JSON response: ${response.body}');
        return false;
      }

      // Safely try to decode JSON
      Map<String, dynamic> data;
      try {
        data = json.decode(response.body);
        print(data); // required data :3
      } catch (e) {
        debugPrint('Failed to decode JSON: ${response.body}');
        return false;
      }

      if (response.statusCode == 201) {
        await _handleAuthSuccess(data);
        return true;
      } else {
        debugPrint('Signup error: ${data['error'] ?? 'Unknown error'}');
        return false;
      }
    } catch (e) {
      debugPrint('Signup error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _handleAuthSuccess(Map<String, dynamic> donor) async {
    _id = donor['id'].toString();
    _email = donor['email'];
    _name = donor['name'];
    _phone = donor['phone'];
    _isAuthenticated = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('id', _id!);
    await prefs.setString('email', _email!);
    await prefs.setString('name', _name!);
    await prefs.setString('phone', _phone!);
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      _id = null;
      _email = null;
      _name = null;
      _phone = null;
      _isAuthenticated = false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      notifyListeners();
    } catch (e) {
      debugPrint('Logout error: $e');
      throw Exception('Failed to logout: $e');
    }
  }

  Future<bool> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _id = prefs.getString('id');
    _email = prefs.getString('email');
    _name = prefs.getString('name');
    _phone = prefs.getString('phone');
    _isAuthenticated = _id != null;
    notifyListeners();
    return _isAuthenticated;
  }
}
