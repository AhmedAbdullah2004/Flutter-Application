import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;
  String? _tempUserId;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get tempUserId => _tempUserId;
  bool get isLoggedIn => _token != null;

  Future<void> loadToken() async {
    _token = await _secureStorage.read(key: 'auth_token');
    notifyListeners();
  }

  Future<bool> login(String emailOrPhone, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post(
        ApiConstants.authLogin,
        body: {
          "emailOrPhone": emailOrPhone,
          "password": password,
        },
      );

      final data = response['data'];
      _tempUserId = data?['userId']?.toString() ??
          response['userId']?.toString();

      if (_tempUserId == null || _tempUserId!.isEmpty) {
        _error = 'لم يتم استلام userId من السيرفر';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception:', '').trim();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp(String otpCode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post(
        ApiConstants.authVerifyOtp,
        body: {
          "userId": _tempUserId,
          "otpCode": otpCode,
          "code": otpCode,
          "otp": otpCode,
        },
      );

      debugPrint("VERIFY RESPONSE = $response");

      final data = response['data'];

      _token = data?['token']?.toString() ??
          response['token']?.toString();

      if (_token == null || _token!.isEmpty) {
        _error = 'لم يتم استلام Token من السيرفر';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _secureStorage.write(key: 'auth_token', value: _token);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("VERIFY ERROR = $e");

      _error = e.toString().replaceAll('Exception:', '').trim();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
      String name,
      String email,
      String password,
      ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.post(
        ApiConstants.authRegister,
        body: {
          "fullName": name,
          "email": email,
          "phoneNumber": "01012345678",
          "password": password,
          "confirmPassword": password,
        },
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception:', '').trim();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchUserProfile() async {
    if (_token == null) return;

    try {
      final response = await _apiService.get(
        ApiConstants.userProfile,
        token: _token,
      );

      _user = UserModel.fromJson(response['data'] ?? response);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    _tempUserId = null;
    await _secureStorage.delete(key: 'auth_token');
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}