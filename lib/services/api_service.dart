import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/prescription_scan_result.dart';

class ApiService {
  static const _tokenKey = 'access_token';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final body = <String, dynamic>{
      'email': email,
      'password': password,
    };
    if (fullName != null && fullName.isNotEmpty) {
      body['full_name'] = fullName;
    }

    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.register}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    // FastAPI OAuth2 form style (common)
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.login}'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'username': email,
        'password': password,
      },
    );

    final data = _handle(res);
    final token = data['access_token']?.toString();
    if (token != null && token.isNotEmpty) {
      await saveToken(token);
    }
    return data;
  }

  Future<Map<String, dynamic>> createPatient(Map<String, dynamic> body) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Please login first');
    }

    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.patients}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> getPatient(String patientId) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Please login first');
    }

    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.patientById(patientId)}'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    return _handle(res);
  }

  /// Upload prescription image → scan API → structured data.
  Future<PrescriptionScanResult> scanPrescription({
    required List<int> imageBytes,
    required String filename,
  }) async {
    if (ApiConfig.useMockPrescriptionScan) {
      await Future<void>.delayed(const Duration(seconds: 1));
      return PrescriptionScanResult.mock();
    }

    final token = await getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.scanPrescription}'),
    );
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: filename,
      ),
    );

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    final data = _handle(res);
    return PrescriptionScanResult.fromJson(data);
  }

  Map<String, dynamic> _handle(http.Response res) {
    Map<String, dynamic> body = {};
    if (res.body.isNotEmpty) {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) {
        body = decoded;
      } else {
        body = {'data': decoded};
      }
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body;
    }

    final detail = body['detail'];
    throw Exception(
      detail?.toString() ?? 'Request failed (${res.statusCode})',
    );
  }
}
