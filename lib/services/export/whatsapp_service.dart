import 'dart:io';

import 'package:share_plus/share_plus.dart';

class WhatsAppService {
  Future<void> share(
    File file,
    String message,
  ) async {
    await SharePlus.instance.share(
      ShareParams(
        text: message,
        files: [
          XFile(file.path),
        ],
      ),
    );
  }
}