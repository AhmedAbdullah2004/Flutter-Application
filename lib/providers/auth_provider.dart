import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _token != null;

  // Mock test credentials
  static const String _mockEmail = 'ahmed@test.com';
  static const String _mockPassword = 'Pass@123';
  static const String _mockPhone = '01012345678';

  Future<void> loadToken() async {
    _token = await _secureStorage.read(key: 'auth_token');
    if (_token != null) {
      _user = UserModel(
        id: 'd2a979a4-3c0c-44ca-99d6-c3d4d860ca80',
        name: 'أحمد محمد',
        email: _mockEmail,
        phone: _mockPhone,
        kycLevel: 'Basic',
        status: 'Active',
      );
    }
    notifyListeners();
  }

  Future<bool> register(String emailOrPhone, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    if (emailOrPhone.isNotEmpty && password.length >= 6) {
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = 'يرجى إدخال بيانات صحيحة (كلمة المرور 6 أحرف على الأقل)';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String emailOrPhone, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 900));

    final isValid = (emailOrPhone == _mockEmail || emailOrPhone == _mockPhone) && 
                    password == _mockPassword;

    if (isValid) {
      _token = 'mock_jwt_token_for_testing_123456789';
      await _secureStorage.write(key: 'auth_token', value: _token);

      _user = UserModel(
        id: 'd2a979a4-3c0c-44ca-99d6-c3d4d860ca80',
        name: 'أحمد محمد',
        email: _mockEmail,
        phone: _mockPhone,
        kycLevel: 'Basic',
        status: 'Active',
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = 'بيانات الدخول غير صحيحة. يرجى المحاولة مرة أخرى.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchUserProfile() async {
    if (_user == null) {
      _user = UserModel(
        id: 'd2a979a4-3c0c-44ca-99d6-c3d4d860ca80',
        name: 'أحمد محمد',
        email: _mockEmail,
        phone: _mockPhone,
        kycLevel: 'Basic',
        status: 'Active',
      );
    }
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    await _secureStorage.delete(key: 'auth_token');
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}