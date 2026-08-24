import 'package:condoleitura/services/ocr/ocr_text_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('extracts the longest digit run as the meter value', () {
    expect(extractMeterDigits('01234\nm³'), '01234');
    expect(extractMeterDigits('HIDROMETRO A1\n008421\nSERIE 99'), '008421');
  });

  test('picks the longest run when multiple digit sequences exist', () {
    expect(extractMeterDigits('modelo 5\n123456'), '123456');
  });

  test('returns null when no digits are found', () {
    expect(extractMeterDigits('sem números aqui'), isNull);
    expect(extractMeterDigits(''), isNull);
  });
}
