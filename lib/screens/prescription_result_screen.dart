import 'package:flutter/material.dart';

import '../models/prescription_scan_result.dart';

class PrescriptionResultScreen extends StatelessWidget {
  final PrescriptionScanResult result;

  const PrescriptionResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Scanned Prescription')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (result.isMock)
            Card(
              color: Colors.amber.shade50,
              child: const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Demo data'),
                subtitle: Text(
                  'Real API ready nahi — mock response dikha raha hai. '
                  'ApiConfig.useMockPrescriptionScan = false karna.',
                ),
              ),
            ),
          const SizedBox(height: 8),
          _HeaderCard(result: result),
          const SizedBox(height: 16),
          if (result.diagnosis != null && result.diagnosis!.isNotEmpty) ...[
            Text('Diagnosis', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.medical_information_outlined),
                title: Text(result.diagnosis!),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text('Medicines', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (result.medicines.isEmpty)
            const Card(
              child: ListTile(title: Text('No medicines found')),
            )
          else
            ...result.medicines.map((m) => _MedicineCard(item: m)),
          if (result.instructions != null &&
              result.instructions!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Instructions', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(result.instructions!),
              ),
            ),
          ],
          if (result.rawText != null && result.rawText!.isNotEmpty) ...[
            const SizedBox(height: 16),
            ExpansionTile(
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
          ],
        ],
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.local_hospital,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.doctorName ?? 'Doctor not found',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (result.clinicName != null)
                        Text(
                          result.clinicName!,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _row(Icons.person_outline, 'Patient', result.patientName),
            _row(Icons.calendar_today_outlined, 'Date', result.date),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
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
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.medication_outlined),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          [
            if (item.dosage != null) 'Dose: ${item.dosage}',
            if (item.frequency != null) item.frequency,
            if (item.duration != null) 'For ${item.duration}',
          ].join(' · '),
        ),
      ),
    );
  }
}
