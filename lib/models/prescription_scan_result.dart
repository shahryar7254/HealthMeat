class MedicineItem {
  final String name;
  final String? dosage;
  final String? frequency;
  final String? duration;

  const MedicineItem({
    required this.name,
    this.dosage,
    this.frequency,
    this.duration,
  });

  factory MedicineItem.fromJson(Map<String, dynamic> json) {
    return MedicineItem(
      name: '${json['name'] ?? json['medicine_name'] ?? 'Unknown'}',
      dosage: json['dosage']?.toString(),
      frequency: json['frequency']?.toString(),
      duration: json['duration']?.toString(),
    );
  }
}

class PrescriptionScanResult {
  final String? doctorName;
  final String? clinicName;
  final String? patientName;
  final String? date;
  final String? diagnosis;
  final String? instructions;
  final String? rawText;
  final List<MedicineItem> medicines;
  final bool isMock;

  const PrescriptionScanResult({
    this.doctorName,
    this.clinicName,
    this.patientName,
    this.date,
    this.diagnosis,
    this.instructions,
    this.rawText,
    this.medicines = const [],
    this.isMock = false,
  });

  factory PrescriptionScanResult.fromJson(
    Map<String, dynamic> json, {
    bool isMock = false,
  }) {
    final meds = <MedicineItem>[];
    final rawMeds = json['medicines'] ?? json['medications'] ?? [];
    if (rawMeds is List) {
      for (final item in rawMeds) {
        if (item is Map<String, dynamic>) {
          meds.add(MedicineItem.fromJson(item));
        }
      }
    }

    return PrescriptionScanResult(
      doctorName: (json['doctor_name'] ?? json['doctorName'])?.toString(),
      clinicName: (json['clinic_name'] ?? json['clinicName'])?.toString(),
      patientName: (json['patient_name'] ?? json['patientName'])?.toString(),
      date: (json['date'] ?? json['prescription_date'])?.toString(),
      diagnosis: (json['diagnosis'] ?? json['disease'])?.toString(),
      instructions: (json['instructions'] ?? json['notes'])?.toString(),
      rawText: (json['raw_text'] ?? json['extracted_text'])?.toString(),
      medicines: meds,
      isMock: isMock,
    );
  }

  /// Demo response — jab real API ready nahi.
  factory PrescriptionScanResult.mock() {
    return PrescriptionScanResult.fromJson(
      {
        'doctor_name': 'Dr. Ayesha Khan',
        'clinic_name': 'City Care Clinic',
        'patient_name': 'Ali Ahmed',
        'date': '2026-07-18',
        'diagnosis': 'Seasonal Allergy / Mild Fever',
        'instructions':
            'Take medicines after meals. Drink plenty of water. Follow up in 5 days.',
        'medicines': [
          {
            'name': 'Cetirizine',
            'dosage': '10mg',
            'frequency': 'Once daily',
            'duration': '5 days',
          },
          {
            'name': 'Paracetamol',
            'dosage': '500mg',
            'frequency': 'Twice daily',
            'duration': '3 days',
          },
        ],
        'raw_text':
            'Dr. Ayesha Khan\nCity Care Clinic\nPatient: Ali Ahmed\n...',
      },
      isMock: true,
    );
  }
}
