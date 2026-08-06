import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/app_data.dart';
import '../../models/meter.dart';
import '../../models/meter_reading.dart';
import '../../models/unit.dart';
import '../../services/camera_service.dart';
import '../../services/ocr/ocr_runner.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({
    super.key,
    required this.unit,
    required this.meter,
  });

  final Unit unit;
  final Meter meter;

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _notesController = TextEditingController();
  final _camera = CameraService();

  XFile? _image;
  Uint8List? _imageBytes;
  String? _ocrRawText;
  double? _ocrConfidence;
  bool _processing = false;

  @override
  void dispose() {
    _valueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage({required bool camera}) async {
    setState(() => _processing = true);
    try {
      final image = camera
          ? await _camera.capture()
          : await _camera.pickFromGallery();
      if (image == null || !mounted) return;

      final bytes = await image.readAsBytes();
      setState(() {
        _image = image;
        _imageBytes = bytes;
        _ocrRawText = null;
        _ocrConfidence = null;
      });

      final result = await runPlatformOcr(
        imagePath: image.path,
        integerDigits: widget.meter.integerDigits,
        decimalDigits: widget.meter.decimalDigits,
      );
      if (!mounted || result == null) return;
      setState(() {
        _ocrRawText = result.rawText;
        _ocrConfidence = result.confidence;
        if (result.value != null) {
          _valueController.text = result.value!.toStringAsFixed(
            widget.meter.decimalDigits,
          );
        }
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível processar a imagem: $error')),
      );
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final meterId = widget.meter.id;
    final unitId = widget.unit.id;
    if (meterId == null || unitId == null) return;

    final normalized = _valueController.text.trim().replaceAll(',', '.');
    final value = double.parse(normalized);
    final data = context.read<AppData>();
    final previous = data.previousValueForMeter(widget.meter);

    if (value < previous) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Leitura menor que a anterior'),
          content: Text(
            'A leitura atual (${value.toStringAsFixed(widget.meter.decimalDigits)}) '
            'é menor que a anterior (${previous.toStringAsFixed(widget.meter.decimalDigits)}). '
            'Deseja salvar mesmo assim?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Revisar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Salvar'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    data.addMeterReading(
      MeterReading(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        meterId: meterId,
        unitId: unitId,
        value: value,
        previousValue: previous,
        readingDate: DateTime.now(),
        photoPath: _image?.path,
        ocrRawText: _ocrRawText,
        ocrConfidence: _ocrConfidence,
        confirmedManually: _ocrConfidence == null || _ocrConfidence! < 0.80,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      ),
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final previous = context.watch<AppData>().previousValueForMeter(widget.meter);
    final confidence = _ocrConfidence;

    return Scaffold(
      appBar: AppBar(title: const Text('Nova leitura')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              '${widget.unit.number} • ${widget.meter.label ?? widget.meter.type.label}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text('Leitura anterior: ${previous.toStringAsFixed(widget.meter.decimalDigits)}'),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _imageBytes == null
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.camera_alt_outlined, size: 48),
                            SizedBox(height: 8),
                            Text('Fotografe ou selecione a imagem do visor'),
                          ],
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: _processing || kIsWeb
                      ? null
                      : () => _pickImage(camera: true),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Câmera'),
                ),
                OutlinedButton.icon(
                  onPressed: _processing ? null : () => _pickImage(camera: false),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(kIsWeb ? 'Selecionar imagem' : 'Galeria'),
                ),
              ],
            ),
            if (_processing) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
            ],
            if (confidence != null) ...[
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: Icon(
                    confidence >= 0.8 ? Icons.verified_outlined : Icons.warning_amber_outlined,
                  ),
                  title: Text('Confiança do OCR: ${(confidence * 100).round()}%'),
                  subtitle: Text(
                    confidence >= 0.8
                        ? 'Confira o valor antes de salvar.'
                        : 'Revisão manual recomendada.',
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            TextFormField(
              controller: _valueController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Valor da leitura *',
                prefixIcon: Icon(Icons.pin_outlined),
              ),
              validator: (value) {
                final normalized = value?.trim().replaceAll(',', '.') ?? '';
                final parsed = double.tryParse(normalized);
                if (parsed == null) return 'Informe uma leitura válida.';
                if (parsed < 0) return 'A leitura não pode ser negativa.';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Observações',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _processing ? null : _save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Salvar leitura'),
            ),
            if (kIsWeb) ...[
              const SizedBox(height: 12),
              Text(
                'No Chrome, a leitura pode ser informada manualmente. O OCR automático é validado no Android/iOS.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
