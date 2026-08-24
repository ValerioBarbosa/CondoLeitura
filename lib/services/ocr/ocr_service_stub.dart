import 'dart:typed_data';

/// Implementação usada quando `dart:io` não está disponível (Web).
/// google_mlkit_text_recognition não tem suporte a Web, então o OCR
/// simplesmente fica indisponível nessa plataforma — a captura de foto e a
/// digitação manual continuam funcionando normalmente.
const bool isSupported = false;

Future<String?> recognizeMeterDigits(Uint8List bytes) async => null;
