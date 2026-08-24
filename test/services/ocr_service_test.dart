import 'dart:typed_data';

import 'package:condoleitura/services/ocr/ocr_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('OCR is not available on this platform (not Android or iOS)', () async {
    // `flutter test` roda na VM do Dart diretamente no host (aqui, Linux),
    // então isso também comprova que o import condicional escolhe a
    // implementação certa em tempo de compilação, não só em runtime.
    expect(OcrService.isSupported, isFalse);
    expect(await OcrService.recognizeMeterDigits(Uint8List(0)), isNull);
  });
}
