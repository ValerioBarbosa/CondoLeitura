import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class PdfService {
  Future<File> generate(
      String fileName, String title, List<List<String>> rows) async {
    final doc = pw.Document();
    doc.addPage(pw.MultiPage(
        build: (_) => [
              pw.Text(title, style: const pw.TextStyle(fontSize: 20)),
              pw.SizedBox(height: 16),
              pw.TableHelper.fromTextArray(data: rows),
            ]));
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName.pdf');
    await file.writeAsBytes(await doc.save());
    return file;
  }
}
