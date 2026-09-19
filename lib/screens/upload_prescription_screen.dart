import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';
import 'prescription_result_screen.dart';

class UploadPrescriptionScreen extends StatefulWidget {
  final String? initialPatientId;

  const UploadPrescriptionScreen({super.key, this.initialPatientId});

  @override
  State<UploadPrescriptionScreen> createState() =>
      _UploadPrescriptionScreenState();
}

class _UploadPrescriptionScreenState extends State<UploadPrescriptionScreen> {
  final _picker = ImagePicker();
  final _api = ApiService();
  final _patientIdCtrl = TextEditingController();
  XFile? _image;
  Uint8List? _previewBytes;
  bool _scanning = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPatientId != null &&
        widget.initialPatientId!.trim().isNotEmpty) {
      _patientIdCtrl.text = widget.initialPatientId!.trim();
    }
  }

  @override
  void dispose() {
    _patientIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 2000,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      setState(() {
        _image = file;
        _previewBytes = bytes;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not pick image: $e')),
      );
    }
  }

  Future<void> _scan() async {
    final patientId = int.tryParse(_patientIdCtrl.text.trim());
    if (patientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Valid patient ID enter karo')),
      );
      return;
    }

    if (_image == null || _previewBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pehle image select / capture karo')),
      );
      return;
    }

    setState(() => _scanning = true);
    try {
      final result = await _api.scanPrescription(
        patientId: patientId,
        imageBytes: _previewBytes!,
        filename: _image!.name.isNotEmpty ? _image!.name : 'prescription.jpg',
      );
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PrescriptionResultScreen(result: result),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Prescription')),
      body: AppGradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionTitle(
                  title: 'Upload Prescription',
                  subtitle: 'Patient ID + clear photo of prescription',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _patientIdCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Patient ID *',
                    hintText: 'e.g. 1',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _previewBytes == null
                            ? AppColors.primary.withValues(alpha: 0.3)
                            : Colors.grey.shade200,
                        width: _previewBytes == null ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _previewBytes == null
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.receipt_long_rounded,
                                    size: 48,
                                    color: AppColors.primary.withValues(alpha: 0.7),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'No image selected',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Gallery se choose karo ya camera se lo',
                                  style: TextStyle(color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          )
                        : Image.memory(_previewBytes!, fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _scanning
                            ? null
                            : () => _pick(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Gallery'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _scanning
                            ? null
                            : () => _pick(ImageSource.camera),
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: const Text('Camera'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LoadingButton(
                  loading: _scanning,
                  onPressed: _scan,
                  label: 'Scan Prescription',
                  icon: Icons.document_scanner_outlined,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
