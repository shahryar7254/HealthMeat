class ApiConfig {
  /// Change this to your backend URL (Swagger pe jo dikhta hai).
  static const String baseUrl = 'http://127.0.0.1:8000';

  static const String register = '/api/v1/auth/register';
  static const String login = '/api/v1/auth/login';
  static const String patients = '/api/v1/patients/';
  static const String scanPrescription = '/api/v1/prescriptions/scan';

  /// true = API ke baghair demo data; real API ready ho to false kar dena.
  static const bool useMockPrescriptionScan = true;

  static String patientById(String id) => '/api/v1/patients/$id';
}
