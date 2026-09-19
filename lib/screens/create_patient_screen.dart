import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/ui_components.dart';

class CreatePatientScreen extends StatefulWidget {
  const CreatePatientScreen({super.key});

  @override
  State<CreatePatientScreen> createState() => _CreatePatientScreenState();
}

class _CreatePatientScreenState extends State<CreatePatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _conditionsCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();
  final _medicationsCtrl = TextEditingController();
  final _api = ApiService();
  String _sex = 'male';
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dobCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _conditionsCtrl.dispose();
    _allergiesCtrl.dispose();
    _medicationsCtrl.dispose();
    super.dispose();
  }

  List<String> _splitList(String value) {
    return value
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final body = <String, dynamic>{
        'name': _nameCtrl.text.trim(),
        'sex': _sex,
        if (_dobCtrl.text.trim().isNotEmpty)
          'date_of_birth': _dobCtrl.text.trim(),
        if (_weightCtrl.text.trim().isNotEmpty)
          'weight_kg': double.tryParse(_weightCtrl.text.trim()),
        if (_heightCtrl.text.trim().isNotEmpty)
          'height_cm': double.tryParse(_heightCtrl.text.trim()),
        'conditions': _splitList(_conditionsCtrl.text),
        'allergies': _splitList(_allergiesCtrl.text),
        'current_medications': _splitList(_medicationsCtrl.text),
      };

      final data = await _api.createPatient(body);
      if (!mounted) return;
      final id = data['id']?.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            id != null
                ? 'Patient created. ID: $id'
                : 'Patient created successfully',
          ),
        ),
      );
      Navigator.pop(context, data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Patient')),
      body: AppGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionTitle(
                    title: 'Patient Profile',
                    subtitle: 'Fill in the health details below',
                  ),
                  const SizedBox(height: 16),
                  FormCard(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Full name *',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _dobCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Date of birth',
                                  hintText: 'YYYY-MM-DD',
                                  prefixIcon: Icon(Icons.cake_outlined),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _sex,
                                decoration: const InputDecoration(
                                  labelText: 'Sex',
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'male',
                                    child: Text('Male'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'female',
                                    child: Text('Female'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'other',
                                    child: Text('Other'),
                                  ),
                                ],
                                onChanged: (v) {
                                  if (v != null) setState(() => _sex = v);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _weightCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Weight (kg)',
                                  prefixIcon: Icon(Icons.monitor_weight_outlined),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _heightCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Height (cm)',
                                  prefixIcon: Icon(Icons.height_rounded),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _conditionsCtrl,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Conditions',
                            hintText: 'diabetes, hypertension',
                            prefixIcon: Icon(Icons.healing_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _allergiesCtrl,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Allergies',
                            hintText: 'penicillin, aspirin',
                            prefixIcon: Icon(Icons.warning_amber_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _medicationsCtrl,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Current medications',
                            hintText: 'Comma separated',
                            prefixIcon: Icon(Icons.medication_outlined),
                          ),
                        ),
                        const SizedBox(height: 24),
                        LoadingButton(
                          loading: _loading,
                          onPressed: _submit,
                          label: 'Save Patient',
                          icon: Icons.check_rounded,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
