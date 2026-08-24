import 'dart:typed_data';

import 'ocr_service_stub.dart' if (dart.library.io) 'ocr_service_io.dart' as platform;

/// Reconhecimento automático do valor exibido no medidor, a partir de uma
/// foto. Sempre uma sugestão a ser revisada manualmente antes de salvar —
/// nunca preenche e confirma uma leitura sozinho.
///
/// Só funciona em builds nativos de Android e iOS: `google_mlkit_text_recognition`
/// não tem implementação para Web nem para desktop (Windows/macOS/Linux).
/// A escolha de qual implementação compilar é feita em tempo de compilação
/// (import condicional por `dart.library.io`), então o pacote de ML Kit —
/// que usa `dart:io` — nunca entra na compilação do Web.
class OcrService {
  const OcrService._();

  static bool get isSupported => platform.isSupported;

  static Future<String?> recognizeMeterDigits(Uint8List bytes) => platform.recognizeMeterDigits(bytes);
}
