import 'dart:typed_data';

import 'save_bytes_web.dart' if (dart.library.io) 'save_bytes_io.dart' as platform;

/// Entrega um arquivo gerado (CSV/PDF/Excel) de forma apropriada para a
/// plataforma atual: download direto pelo navegador na Web, arquivo local
/// seguido de compartilhamento nativo em Android/iOS/desktop.
Future<void> saveGeneratedFile({
  required String fileName,
  required Uint8List bytes,
  required String mimeType,
}) =>
    platform.saveGeneratedFile(fileName: fileName, bytes: bytes, mimeType: mimeType);
