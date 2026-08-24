import 'package:condoleitura/models/no_reading_reason.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('noReadingReasons lists the expected fixed set of reasons', () {
    expect(noReadingReasons, [
      'Morador ausente',
      'Medidor inacessível',
      'Medidor danificado',
      'Recusa do morador',
      'Outro',
    ]);
  });

  test('NoReadingRecord round-trips through JSON preserving all fields', () {
    final record = NoReadingRecord(
      id: 'record-1',
      meterId: 'meter-1',
      reason: 'Morador ausente',
      notes: 'Ninguém atendeu às 14h.',
      createdAt: DateTime.utc(2026, 1, 1, 14),
    );

    final decoded = NoReadingRecord.fromJson(record.toJson());

    expect(decoded.id, record.id);
    expect(decoded.meterId, record.meterId);
    expect(decoded.reason, record.reason);
    expect(decoded.notes, record.notes);
    expect(decoded.createdAt, record.createdAt);
  });

  test('NoReadingRecord.notes defaults to empty string when absent', () {
    final decoded = NoReadingRecord.fromJson({
      'id': 'record-1',
      'meterId': 'meter-1',
      'reason': 'Outro',
      'createdAt': DateTime.utc(2026, 1, 1).toIso8601String(),
    });

    expect(decoded.notes, isEmpty);
  });
}
