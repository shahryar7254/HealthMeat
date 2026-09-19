import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';
import 'create_patient_screen.dart';
import 'login_screen.dart';
import 'patient_detail_screen.dart';
import 'upload_prescription_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _patientIdCtrl = TextEditingController();
  final _api = ApiService();

  @override
  void dispose() {
    _patientIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await _api.clearToken();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  void _openPatient() {
    final id = _patientIdCtrl.text.trim();
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter patient ID')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PatientDetailScreen(patientId: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HealthMate AI'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: AppGradientBackground(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.medical_services_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Manage patients & scan prescriptions',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionTitle(
              title: 'Quick Actions',
              subtitle: 'Choose what you want to do',
            ),
            const SizedBox(height: 12),
            ActionTile(
              icon: Icons.person_add_alt_1_rounded,
              title: 'Create Patient',
              subtitle: 'Add a new patient profile',
              color: AppColors.primary,
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreatePatientScreen(),
                  ),
                );
                if (result is Map && result['id'] != null) {
                  _patientIdCtrl.text = result['id'].toString();
                } else if (result is Map && result['patient_id'] != null) {
                  _patientIdCtrl.text = result['patient_id'].toString();
                }
              },
            ),
            const SizedBox(height: 10),
            ActionTile(
              icon: Icons.document_scanner_outlined,
              title: 'Scan Prescription',
              subtitle: 'Upload & analyze doctor prescription',
              color: const Color(0xFF6366F1),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UploadPrescriptionScreen(
                      initialPatientId: _patientIdCtrl.text.trim(),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),
            const SectionTitle(
              title: 'Find Patient',
              subtitle: 'Enter ID to view profile details',
            ),
            const SizedBox(height: 12),
            FormCard(
              child: Column(
                children: [
                  TextField(
                    controller: _patientIdCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Patient ID',
                      hintText: 'e.g. 1',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _openPatient,
                      icon: const Icon(Icons.search_rounded),
                      label: const Text('View Patient'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
