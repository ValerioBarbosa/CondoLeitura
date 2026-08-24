import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/ocr/ocr_service.dart';

/// Campo para fotografar o medidor no momento da leitura.
///
/// A foto é lida como bytes e devolvida em base64 via [onChanged], em vez de
/// um caminho de arquivo: no Web não existe um caminho persistente entre
/// sessões, então bytes é a única representação que funciona igual em
/// Web, Android e iOS.
///
/// Quando o OCR está disponível na plataforma (Android/iOS nativo), tenta
/// reconhecer o valor mostrado no medidor e sugere via [onTextRecognized] —
/// sempre como sugestão editável, nunca preenchendo e enviando sozinho.
class PhotoCaptureField extends StatefulWidget {
  const PhotoCaptureField({super.key, required this.onChanged, this.onTextRecognized});

  final ValueChanged<String?> onChanged;
  final ValueChanged<String>? onTextRecognized;

  @override
  State<PhotoCaptureField> createState() => _PhotoCaptureFieldState();
}

class _PhotoCaptureFieldState extends State<PhotoCaptureField> {
  String? _photoBase64;
  bool _capturing = false;
  bool _recognizing = false;

  Future<void> _capture() async {
    setState(() => _capturing = true);
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 1600,
        imageQuality: 70,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      setState(() => _photoBase64 = base64Encode(bytes));
      widget.onChanged(_photoBase64);
      _recognize(bytes);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível acessar a câmera.')),
        );
      }
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  Future<void> _recognize(Uint8List bytes) async {
    if (!OcrService.isSupported || widget.onTextRecognized == null) return;
    setState(() => _recognizing = true);
    try {
      final digits = await OcrService.recognizeMeterDigits(bytes);
      if (digits != null && mounted) {
        widget.onTextRecognized!(digits);
      }
    } catch (_) {
      // Reconhecimento é só uma sugestão; qualquer falha apenas deixa de sugerir.
    } finally {
      if (mounted) setState(() => _recognizing = false);
    }
  }

  void _remove() {
    setState(() => _photoBase64 = null);
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final photo = _photoBase64;
    if (photo == null) {
      return OutlinedButton.icon(
        onPressed: _capturing ? null : _capture,
        icon: _capturing
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.add_a_photo_outlined),
        label: const Text('Fotografar medidor'),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                base64Decode(photo),
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            IconButton.filled(
              onPressed: _remove,
              icon: const Icon(Icons.close, size: 18),
              tooltip: 'Remover foto',
            ),
          ],
        ),
        if (_recognizing) ...[
          const SizedBox(height: 8),
          const Row(
            children: [
              SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 8),
              Text('Lendo o medidor...', style: TextStyle(fontStyle: FontStyle.italic)),
            ],
          ),
        ],
      ],
    );
  }
}
