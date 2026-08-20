import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Physical device par test karne ke liye apne PC ka LAN IP yahan set karo.
  /// Example: 'http://192.168.1.5:8000'
  static const String? physicalDeviceHost = null;

  /// Backend base URL — platform ke hisaab se auto select.
  static String get baseUrl {
    if (physicalDeviceHost != null && physicalDeviceHost!.isNotEmpty) {
      return physicalDeviceHost!;
    }
    if (kIsWeb) return 'http://127.0.0.1:8000';
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://127.0.0.1:8000';
  }

  static const String register = '/api/v1/auth/register';
  static const String login = '/api/v1/auth/login';
  static const String patients = '/api/v1/patients/';
  static const String scanPrescription = '/api/v1/prescriptions/scan';

  /// false = real backend API use hogi.
  static const bool useMockPrescriptionScan = false;

  static String patientById(String id) => '/api/v1/patients/$id';
}
