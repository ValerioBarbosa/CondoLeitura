import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'ocr/ocr_result.dart';

class OcrService {
  Future<OcrResult> recognize({
    required String imagePath,
    required int integerDigits,
    required int decimalDigits,
  }) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final text = await recognizer.processImage(
        InputImage.fromFilePath(imagePath),
      );
      final raw = text.text.trim();
      final candidates = RegExp(r'\d+[\.,]?\d*')
          .allMatches(raw)
          .map((match) => match.group(0)!)
          .toList();
      String? best;
      if (candidates.isNotEmpty) {
        candidates.sort(
          (a, b) => b
              .replaceAll(RegExp(r'\D'), '')
              .length
              .compareTo(a.replaceAll(RegExp(r'\D'), '').length),
        );
        best = candidates.first;
      }

      double? value;
      if (best != null) {
        final normalized = best.replaceAll(',', '.');
        value = double.tryParse(normalized);
        if (value == null || (!normalized.contains('.') && decimalDigits > 0)) {
          final digits = best.replaceAll(RegExp(r'\D'), '');
          if (digits.isNotEmpty) {
            final padded = digits.padLeft(decimalDigits + 1, '0');
            final split = padded.length - decimalDigits;
            value = double.tryParse(
              '${padded.substring(0, split)}.${padded.substring(split)}',
            );
          }
        }
      }

      final expected = integerDigits + decimalDigits;
      final count = best?.replaceAll(RegExp(r'\D'), '').length ?? 0;
      final confidence = raw.isEmpty
          ? 0.0
          : (count == expected ? 0.92 : (count >= integerDigits ? 0.68 : 0.35));
      return OcrResult(
        rawText: raw,
        value: value,
        confidence: confidence,
        requiresReview: value == null || confidence < 0.8,
      );
    } finally {
      await recognizer.close();
    }
  }
}
