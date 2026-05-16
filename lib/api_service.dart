import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_config.dart';
import 'app_nav.dart';

class ApiService {
  static const _storage = FlutterSecureStorage();

  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _storage.read(key: 'access_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<bool> _attemptTokenRefresh() async {
    final refreshToken = await _storage.read(key: 'refresh_token');
    if (refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/user/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'access_token', value: data['access_token']);
        await _storage.write(key: 'refresh_token', value: data['refresh_token']);
        return true;
      }
    } catch (e) {
      return false;
    }

    return false;
  }

  static Future<http.Response> get(String endpoint) async {
    final headers = await _getAuthHeaders();
    var response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      headers: headers,
    );

    if (response.statusCode == 401) {
      final refreshed = await _attemptTokenRefresh();
      if (refreshed) {
        final newHeaders = await _getAuthHeaders();
        response = await http.get(
          Uri.parse('${ApiConfig.baseUrl}$endpoint'),
          headers: newHeaders,
        );
      } else {
        await _storage.delete(key: 'access_token');
        await _storage.delete(key: 'refresh_token');
      }
    }

    return response;
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getAuthHeaders();
    var response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      final refreshed = await _attemptTokenRefresh();
      if (refreshed) {
        final newHeaders = await _getAuthHeaders();
        response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}$endpoint'),
          headers: newHeaders,
          body: jsonEncode(body),
        );
      } else {
        await _storage.delete(key: 'access_token');
        await _storage.delete(key: 'refresh_token');
      }
    }

    return response;
  }

  static Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getAuthHeaders();
    var response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      final refreshed = await _attemptTokenRefresh();
      if (refreshed) {
        final newHeaders = await _getAuthHeaders();
        response = await http.put(
          Uri.parse('${ApiConfig.baseUrl}$endpoint'),
          headers: newHeaders,
          body: jsonEncode(body),
        );
      } else {
        await _storage.delete(key: 'access_token');
        await _storage.delete(key: 'refresh_token');
      }
    }

    return response;
  }


  static Future<void> logout(BuildContext context) async {
    try {
      await post('/user/logout', {});
    } catch (e) {
    } finally {
      await _storage.delete(key: 'access_token');
      await _storage.delete(key: 'refresh_token');
      appTabNotifier.value = 0;
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }
}
