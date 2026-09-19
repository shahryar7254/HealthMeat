import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';

class PatientDetailScreen extends StatefulWidget {
  final String patientId;

  const PatientDetailScreen({super.key, required this.patientId});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  final _api = ApiService();
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _patient;

  static const _labels = {
    'name': 'Name',
    'sex': 'Sex',
    'date_of_birth': 'Date of Birth',
    'weight_kg': 'Weight (kg)',
    'height_cm': 'Height (cm)',
    'bmi': 'BMI',
    'conditions': 'Conditions',
    'allergies': 'Allergies',
    'current_medications': 'Medications',
    'user_id': 'User ID',
    'created_at': 'Created',
  };

  static const _icons = {
    'name': Icons.person_outline,
    'sex': Icons.wc_outlined,
    'date_of_birth': Icons.cake_outlined,
    'weight_kg': Icons.monitor_weight_outlined,
    'height_cm': Icons.height_rounded,
    'bmi': Icons.analytics_outlined,
    'conditions': Icons.healing_outlined,
    'allergies': Icons.warning_amber_outlined,
    'current_medications': Icons.medication_outlined,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _api.getPatient(widget.patientId);
      if (!mounted) return;
      setState(() {
        _patient = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  String _formatValue(dynamic value) {
    if (value is List) return value.join(', ');
    return '$value';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient #${widget.patientId}'),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: AppGradientBackground(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline,
                              size: 48, color: Colors.red.shade300),
                          const SizedBox(height: 12),
                          Text(_error!, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          OutlinedButton(onPressed: _load, child: const Text('Retry')),
                        ],
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.accent],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: Colors.white.withValues(alpha: 0.25),
                              child: const Icon(Icons.person, color: Colors.white, size: 32),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_patient?['name'] ?? 'Patient'}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (_patient?['sex'] != null)
                                    Text(
                                      '${_patient!['sex']}'.toUpperCase(),
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...?_patient?.entries
                          .where((e) => e.key != 'name' && e.key != 'id')
                          .map((e) {
                        final label = _labels[e.key] ?? e.key;
                        final icon = _icons[e.key] ?? Icons.info_outline;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Card(
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(icon, color: AppColors.primaryDark, size: 20),
                              ),
                              title: Text(
                                label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              subtitle: Text(
                                _formatValue(e.value),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
      ),
    );
  }
}
