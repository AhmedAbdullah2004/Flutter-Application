import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiService {
  final String baseUrl = ApiConstants.baseUrl;

  Future<Map<String, dynamic>> get(String endpoint, {String? token}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return _send(() => http.get(url, headers: _headers(token)), url);
  }

  Future<Map<String, dynamic>> post(
      String endpoint, {
        Map<String, dynamic>? body,
        String? token,
      }) async {
    final url = Uri.parse('$baseUrl$endpoint');

    debugPrint('API POST: $url');
    debugPrint('BODY: ${jsonEncode(body)}');

    return _send(
          () => http.post(
        url,
        headers: _headers(token),
        body: body != null ? jsonEncode(body) : null,
      ),
      url,
    );
  }

  Map<String, String> _headers(String? token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> _send(
      Future<http.Response> Function() request,
      Uri url,
      ) async {
    try {
      final response = await request().timeout(
        const Duration(seconds: 20),
      );

      debugPrint('STATUS: ${response.statusCode}');

      if (response.body.isEmpty) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return {'success': true};
        }
        throw Exception('HTTP ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);

      final data = decoded is Map<String, dynamic>
          ? decoded
          : {'data': decoded};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      }

      throw Exception(
        data['message'] ??
            data['error'] ??
            data['title'] ??
            'HTTP ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('API ERROR: $e');
      throw Exception('حدث خطأ في الاتصال: $e');
    }
  }
}