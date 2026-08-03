import 'dart:io';
import 'package:printing/printing.dart';

class PrintService {
  Future<void> printPdf(File file) async {
    final bytes = await file.readAsBytes();
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }
}
