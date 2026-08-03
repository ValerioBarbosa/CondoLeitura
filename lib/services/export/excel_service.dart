import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

class ExcelService {
  Future<File> generate(String fileName, List<List<dynamic>> rows) async {
    final workbook = Excel.createExcel();
    final sheet = workbook['Relatório'];
    for (final row in rows) {
      sheet.appendRow(row.map((e) => TextCellValue(e.toString())).toList());
    }
    final bytes = workbook.encode();
    if (bytes == null) throw StateError('Falha ao gerar Excel.');
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName.xlsx');
    await file.writeAsBytes(bytes);
    return file;
  }
}
