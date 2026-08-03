import 'dart:io';

import 'package:share_plus/share_plus.dart';

class EmailService {
  Future<void> send(
    List<File> files,
    String subject,
    String body,
  ) async {
    await SharePlus.instance.share(
      ShareParams(
        subject: subject,
        text: body,
        files: files.map((file) => XFile(file.path)).toList(),
      ),
    );
  }
}
