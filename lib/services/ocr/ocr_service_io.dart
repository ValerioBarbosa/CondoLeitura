import 'dart:io';
import 'dart:typed_data';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';

import 'ocr_text_parser.dart';

/// google_mlkit_text_recognition só tem implementação nativa para Android e
/// iOS (nenhum suporte a Windows/macOS/Linux desktop, mesmo tendo dart:io
/// disponível ali). Fora dessas duas plataformas, o OCR fica indisponível.
bool get isSupported => Platform.isAndroid || Platform.isIOS;

Future<String?> recognizeMeterDigits(Uint8List bytes) async {
  if (!isSupported) return null;

  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/ocr_${DateTime.now().microsecondsSinceEpoch}.jpg');
  await file.writeAsBytes(bytes);

  final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
  try {
    final result = await recognizer.processImage(InputImage.fromFile(file));
    return extractMeterDigits(result.text);
  } finally {
    await recognizer.close();
    if (await file.exists()) {
      await file.delete();
    }
  }
}
