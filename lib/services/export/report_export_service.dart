import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart' as csv;
import 'package:excel/excel.dart' as xls;
import 'package:pdf/widgets.dart' as pw;

import '../../models/app_data.dart';
import '../../models/reading.dart';
import 'save_bytes.dart';

/// Monta e entrega um relatório de consumo a partir das leituras já
/// registradas no aparelho. Não depende de nenhum backend: os dados vêm
/// sempre do [AppData] local.
class ReportExportService {
  const ReportExportService._();

  static List<List<String>> _rows(AppData data, List<Reading> readings) {
    final header = ['Data', 'Local', 'Anterior', 'Atual', 'Consumo', 'Leiturista', 'GPS'];
    final rows = <List<String>>[header];
    for (final reading in readings) {
      rows.add([
        reading.createdAt.toIso8601String(),
        data.meterLabel(reading.meterId),
        reading.previousValue.toStringAsFixed(1),
        reading.currentValue.toStringAsFixed(1),
        reading.consumption.toStringAsFixed(1),
        reading.readerName ?? '',
        reading.hasLocation ? '${reading.latitude}, ${reading.longitude}' : '',
      ]);
    }
    return rows;
  }

  static Future<void> exportCsv(AppData data, List<Reading> readings) async {
    final content = csv.csv.encode(_rows(data, readings));
    await saveGeneratedFile(
      fileName: 'relatorio-condoleitura.csv',
      bytes: Uint8List.fromList(utf8.encode(content)),
      mimeType: 'text/csv',
    );
  }

  static Future<void> exportExcel(AppData data, List<Reading> readings) async {
    final workbook = xls.Excel.createExcel();
    final sheet = workbook['Relatório'];
    for (final row in _rows(data, readings)) {
      sheet.appendRow(row.map((e) => xls.TextCellValue(e)).toList());
    }
    final bytes = workbook.encode();
    if (bytes == null) return;
    await saveGeneratedFile(
      fileName: 'relatorio-condoleitura.xlsx',
      bytes: Uint8List.fromList(bytes),
      mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
  }

  static Future<void> exportPdf(AppData data, List<Reading> readings) async {
    final rows = _rows(data, readings);
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        build: (_) => [
          pw.Text('Relatório de consumo - CondoLeitura', style: const pw.TextStyle(fontSize: 18)),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(data: rows),
        ],
      ),
    );
    final bytes = await doc.save();
    await saveGeneratedFile(fileName: 'relatorio-condoleitura.pdf', bytes: bytes, mimeType: 'application/pdf');
  }
}
