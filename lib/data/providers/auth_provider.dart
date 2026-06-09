import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../../core/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _loading = false;
  String? _error;

  UserModel? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('user');
    if (raw != null) {
      _user = UserModel.fromJson(jsonDecode(raw));
      ApiService.setToken(_user!.token);
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    final res = await AuthService.login(email, password);
    _loading = false;

    if (res.success && res.data != null) {
      _user = UserModel.fromJson(res.data!['user']);
      ApiService.setToken(_user!.token);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(_user!.toJson()));
      notifyListeners();
      return true;
    } else {
      _error = res.message ?? 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? city,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    final res = await AuthService.register(
      name: name,
      email: email,
      password: password,
      phone: phone,
      city: city,
    );
    _loading = false;

    if (res.success && res.data != null) {
      _user = UserModel.fromJson(res.data!['user']);
      ApiService.setToken(_user!.token);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(_user!.toJson()));
      notifyListeners();
      return true;
    } else {
      _error = res.message ?? 'فشل إنشاء الحساب';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    ApiService.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    notifyListeners();
  }
}
