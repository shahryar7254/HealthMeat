class MedicineItem {
  final String name;
  final String? dosage;
  final String? frequency;
  final String? duration;
  final String? strength;

  const MedicineItem({
    required this.name,
    this.dosage,
    this.frequency,
    this.duration,
    this.strength,
  });

  factory MedicineItem.fromJson(Map<String, dynamic> json) {
    final strength = json['strength']?.toString();
    final quantity = json['quantity_per_dose']?.toString();

    return MedicineItem(
      name: '${json['name'] ?? json['medicine_name'] ?? 'Unknown'}',
      strength: strength,
      dosage: quantity ?? strength ?? json['dosage']?.toString(),
      frequency: json['frequency']?.toString(),
      duration: json['duration']?.toString(),
    );
  }
}

class SafetyAlert {
  final String level;
  final String message;

  const SafetyAlert({required this.level, required this.message});

  factory SafetyAlert.fromJson(Map<String, dynamic> json) {
    return SafetyAlert(
      level: '${json['level'] ?? 'warning'}',
      message: '${json['message'] ?? json}',
    );
  }
}

class PrescriptionScanResult {
  final int? prescriptionId;
  final int? patientId;
  final String? doctorName;
  final String? clinicName;
  final String? patientName;
  final String? date;
  final String? diagnosis;
  final String? instructions;
  final String? rawText;
  final List<MedicineItem> medicines;
  final String? overallSafetyStatus;
  final List<SafetyAlert> dosageAlerts;
  final List<SafetyAlert> interactionAlerts;
  final List<SafetyAlert> contraindicationAlerts;
  final bool isMock;

  const PrescriptionScanResult({
    this.prescriptionId,
    this.patientId,
    this.doctorName,
    this.clinicName,
    this.patientName,
    this.date,
    this.diagnosis,
    this.instructions,
    this.rawText,
    this.medicines = const [],
    this.overallSafetyStatus,
    this.dosageAlerts = const [],
    this.contraindicationAlerts = const [],
    this.interactionAlerts = const [],
    this.isMock = false,
  });

  factory PrescriptionScanResult.fromJson(
    Map<String, dynamic> json, {
    bool isMock = false,
  }) {
    // Backend response: raw_extraction + safety_report nested hain.
    final rawExtraction = json['raw_extraction'];
    final extraction = rawExtraction is Map<String, dynamic>
        ? rawExtraction
        : json;

    final safety = json['safety_report'];
    final safetyMap = safety is Map<String, dynamic> ? safety : null;

    final meds = <MedicineItem>[];
    final rawMeds = json['medications_extracted'] ??
        extraction['medications'] ??
        json['medicines'] ??
        json['medications'] ??
        [];
    if (rawMeds is List) {
      for (final item in rawMeds) {
        if (item is Map<String, dynamic>) {
          meds.add(MedicineItem.fromJson(item));
        }
      }
    }

    List<SafetyAlert> parseAlerts(dynamic value) {
      if (value is! List) return const [];
      return value
          .whereType<Map<String, dynamic>>()
          .map(SafetyAlert.fromJson)
          .toList();
    }

    return PrescriptionScanResult(
      prescriptionId: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      patientId: json['patient_id'] is int
          ? json['patient_id'] as int
          : int.tryParse('${json['patient_id']}'),
      doctorName:
          (extraction['doctor_name'] ?? json['doctor_name'] ?? json['doctorName'])
              ?.toString(),
      clinicName:
          (extraction['clinic_name'] ?? json['clinic_name'] ?? json['clinicName'])
              ?.toString(),
      patientName: (extraction['patient_name'] ??
              json['patient_name'] ??
              json['patientName'])
          ?.toString(),
      date: (extraction['prescription_date'] ??
              extraction['date'] ??
              json['date'] ??
              json['prescription_date'])
          ?.toString(),
      diagnosis:
          (extraction['diagnosis'] ?? json['diagnosis'] ?? json['disease'])
              ?.toString(),
      instructions:
          (extraction['instructions'] ?? json['instructions'] ?? json['notes'])
              ?.toString(),
      rawText: (json['raw_text'] ?? json['extracted_text'])?.toString(),
      medicines: meds,
      overallSafetyStatus: (json['overall_safety_status'] ??
              safetyMap?['overall_status'])
          ?.toString(),
      dosageAlerts: parseAlerts(safetyMap?['dosage_alerts']),
      interactionAlerts: parseAlerts(safetyMap?['interaction_alerts']),
      contraindicationAlerts:
          parseAlerts(safetyMap?['contraindication_alerts']),
      isMock: isMock,
    );
  }

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
        'overall_safety_status': 'safe',
      },
      isMock: true,
    );
  }
}
