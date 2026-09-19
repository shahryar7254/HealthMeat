import 'package:flutter/material.dart';

import '../models/prescription_scan_result.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';

class PrescriptionResultScreen extends StatelessWidget {
  final PrescriptionScanResult result;

  const PrescriptionResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Results')),
      body: AppGradientBackground(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (result.isMock)
              Card(
                color: Colors.amber.shade50,
                child: const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Demo data'),
                  subtitle: Text('Mock response — real API use ho rahi hai normally.'),
                ),
              ),
            if (result.overallSafetyStatus != null) ...[
              _SafetyBanner(status: result.overallSafetyStatus!),
              const SizedBox(height: 16),
            ],
            _HeaderCard(result: result),
            const SizedBox(height: 16),
            if (result.diagnosis != null && result.diagnosis!.isNotEmpty) ...[
              const SectionTitle(title: 'Diagnosis'),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.medical_information_outlined,
                        color: AppColors.primaryDark),
                  ),
                  title: Text(result.diagnosis!),
                ),
              ),
              const SizedBox(height: 16),
            ],
            const SectionTitle(title: 'Medicines'),
            const SizedBox(height: 8),
            if (result.medicines.isEmpty)
              const Card(
                child: ListTile(title: Text('No medicines found')),
              )
            else
              ...result.medicines.map((m) => _MedicineCard(item: m)),
            if (result.dosageAlerts.isNotEmpty ||
                result.interactionAlerts.isNotEmpty ||
                result.contraindicationAlerts.isNotEmpty) ...[
              const SizedBox(height: 16),
              const SectionTitle(title: 'Safety Alerts'),
              const SizedBox(height: 8),
              ...result.dosageAlerts.map(
                (a) => _AlertTile(icon: Icons.warning_amber_outlined, alert: a),
              ),
              ...result.interactionAlerts.map(
                (a) => _AlertTile(icon: Icons.sync_problem_outlined, alert: a),
              ),
              ...result.contraindicationAlerts.map(
                (a) => _AlertTile(icon: Icons.block_outlined, alert: a),
              ),
            ],
            if (result.instructions != null &&
                result.instructions!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const SectionTitle(title: 'Instructions'),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(result.instructions!),
                ),
              ),
            ],
            if (result.rawText != null && result.rawText!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Card(
                child: ExpansionTile(
                  title: const Text('Raw extracted text'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(result.rawText!),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final PrescriptionScanResult result;

  const _HeaderCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.local_hospital_rounded, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.doctorName ?? 'Doctor not found',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      if (result.clinicName != null)
                        Text(
                          result.clinicName!,
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (result.patientName != null && result.patientName!.isNotEmpty)
              InfoChip(
                icon: Icons.person_outline,
                label: 'Patient',
                value: result.patientName!,
              ),
            if (result.date != null && result.date!.isNotEmpty) ...[
              const SizedBox(height: 8),
              InfoChip(
                icon: Icons.calendar_today_outlined,
                label: 'Date',
                value: result.date!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MedicineCard extends StatelessWidget {
  final MedicineItem item;

  const _MedicineCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.medication_outlined, color: Color(0xFF6366F1)),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            [
              if (item.strength != null) 'Strength: ${item.strength}',
              if (item.dosage != null) 'Dose: ${item.dosage}',
              if (item.frequency != null) item.frequency,
              if (item.duration != null) 'For ${item.duration}',
            ].join(' · '),
          ),
        ),
      ),
    );
  }
}

class _SafetyBanner extends StatelessWidget {
  final String status;

  const _SafetyBanner({required this.status});

  (Color bg, Color fg, IconData icon) get _style {
    switch (status.toLowerCase()) {
      case 'critical':
        return (Colors.red.shade50, Colors.red.shade800, Icons.error_outline);
      case 'warning':
        return (Colors.orange.shade50, Colors.orange.shade900,
            Icons.warning_amber_outlined);
      default:
        return (Colors.green.shade50, Colors.green.shade800,
            Icons.check_circle_outline);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = _style;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: fg.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Safety: ${status.toUpperCase()}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: fg,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Backend safety check complete',
                  style: TextStyle(color: fg.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final IconData icon;
  final SafetyAlert alert;

  const _AlertTile({required this.icon, required this.alert});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.orange.shade50,
      child: ListTile(
        leading: Icon(icon, color: Colors.orange.shade800),
        title: Text(alert.message),
        subtitle: Text('Level: ${alert.level}'),
      ),
    );
  }
}
