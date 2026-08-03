import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

class CsvService {
  Future<File> createCsv({
    required String fileName,
    required List<List<dynamic>> rows,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName.csv');

    final csvContent = excel.encode(rows);

    return file.writeAsString(
      csvContent,
      flush: true,
    );
  }
}
