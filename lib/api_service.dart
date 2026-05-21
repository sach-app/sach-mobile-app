import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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
        await _storage.write(
          key: 'refresh_token',
          value: data['refresh_token'],
        );
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

  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
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

  static Future<http.Response> put(
    String endpoint, [
    Map<String, dynamic>? body,
  ]) async {
    final headers = await _getAuthHeaders();
    var response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );

    if (response.statusCode == 401) {
      final refreshed = await _attemptTokenRefresh();
      if (refreshed) {
        final newHeaders = await _getAuthHeaders();
        response = await http.put(
          Uri.parse('${ApiConfig.baseUrl}$endpoint'),
          headers: newHeaders,
          body: body != null ? jsonEncode(body) : null,
        );
      } else {
        await _storage.delete(key: 'access_token');
        await _storage.delete(key: 'refresh_token');
      }
    }

    return response;
  }

  static Future<bool> uploadEvidence(String firId, String filePath) async {
    final token = await _storage.read(key: 'access_token');

    Future<http.StreamedResponse> sendRequest(String? accessToken) async {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/user/fir/$firId/evidence'),
      );
      if (accessToken != null) {
        request.headers['Authorization'] = 'Bearer $accessToken';
      }

      final ext = filePath.split('.').last.toLowerCase();
      MediaType mediaType;
      if (ext == 'pdf') {
        mediaType = MediaType('application', 'pdf');
      } else if (ext == 'png') {
        mediaType = MediaType('image', 'png');
      } else if (ext == 'webp') {
        mediaType = MediaType('image', 'webp');
      } else {
        mediaType = MediaType('image', 'jpeg');
      }

      request.files.add(await http.MultipartFile.fromPath(
        'file', 
        filePath,
        contentType: mediaType,
      ));
      return await request.send();
    }

    var response = await sendRequest(token);

    if (response.statusCode == 401) {
      final refreshed = await _attemptTokenRefresh();
      if (refreshed) {
        final newToken = await _storage.read(key: 'access_token');
        response = await sendRequest(newToken);
      } else {
        await _storage.delete(key: 'access_token');
        await _storage.delete(key: 'refresh_token');
      }
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> uploadProfilePicture(String filePath) async {
    // There is no multipart endpoint for profile pictures.
    // Instead, we convert to base64 and use the PUT /user/profile endpoint.
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final base64String = base64Encode(bytes);
    final ext = filePath.split('.').last.toLowerCase();
    final dataUri = 'data:image/$ext;base64,$base64String';

    // We must send the required fields along with the profile picture.
    // Because we don't have direct access to the store here without cyclic imports, 
    // we'll fetch the current profile first, update it, and send it back.
    final getResponse = await get('/user/profile');
    if (getResponse.statusCode != 200) {
      throw Exception('Failed to fetch current profile before updating.');
    }
    
    final currentProfile = jsonDecode(getResponse.body);
    
    final payload = {
      'full_name': currentProfile['full_name'] ?? '',
      'phone': currentProfile['phone'] ?? '',
      'email': currentProfile['email'] ?? '',
      'address': currentProfile['address'] ?? '',
      'profile_picture': dataUri,
    };

    final response = await put('/user/profile', payload);

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Server error ${response.statusCode}: ${response.body}');
    }
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
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }
}
