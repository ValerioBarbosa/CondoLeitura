import 'dart:io';

import '../ocr_service.dart';
import 'ocr_result.dart';

Future<OcrResult?> runPlatformOcr({
  required String imagePath,
  required int integerDigits,
  required int decimalDigits,
}) async {
  if (!Platform.isAndroid && !Platform.isIOS) return null;
  return OcrService().recognize(
    imagePath: imagePath,
    integerDigits: integerDigits,
    decimalDigits: decimalDigits,
  );
}
