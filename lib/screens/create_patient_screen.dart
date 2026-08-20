import 'package:flutter/material.dart';

import '../services/api_service.dart';

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
      appBar: AppBar(title: const Text('Create Patient')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dobCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Date of birth',
                    border: OutlineInputBorder(),
                    hintText: 'YYYY-MM-DD',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _sex,
                  decoration: const InputDecoration(
                    labelText: 'Sex',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Male')),
                    DropdownMenuItem(value: 'female', child: Text('Female')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _sex = v);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _weightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _heightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Height (cm)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _conditionsCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Conditions',
                    border: OutlineInputBorder(),
                    hintText: 'Comma separated, e.g. diabetes, hypertension',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _allergiesCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Allergies',
                    border: OutlineInputBorder(),
                    hintText: 'Comma separated, e.g. penicillin, aspirin',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _medicationsCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Current medications',
                    border: OutlineInputBorder(),
                    hintText: 'Comma separated',
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create Patient'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
