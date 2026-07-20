import 'package:flutter/material.dart';

import '../services/api_service.dart';
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
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Patients',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Create profile or view by ID',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () async {
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
              icon: const Icon(Icons.person_add),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Create Patient Profile'),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UploadPrescriptionScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.document_scanner_outlined),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Scan Prescription'),
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            TextField(
              controller: _patientIdCtrl,
              decoration: const InputDecoration(
                labelText: 'Patient ID',
                border: OutlineInputBorder(),
                hintText: 'Paste patient id here',
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _openPatient,
              icon: const Icon(Icons.search),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Read Patient'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
