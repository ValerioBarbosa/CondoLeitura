import 'package:share_plus/share_plus.dart';

class ShareService {
  Future<void> shareFiles(
    List<String> paths,
    String text, {
    String? subject,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: subject,
        files: paths.map((path) => XFile(path)).toList(),
      ),
    );
  }
}