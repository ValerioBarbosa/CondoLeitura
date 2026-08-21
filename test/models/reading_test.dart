import 'package:condoleitura/models/reading.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Reading round-trips through JSON preserving all fields', () {
    final reading = Reading(
      id: 'reading-1',
      meterId: 'meter-1',
      previousValue: 10,
      currentValue: 15.5,
      createdAt: DateTime.utc(2026, 1, 1, 12, 30),
    );

    final decoded = Reading.fromJson(reading.toJson());

    expect(decoded.id, reading.id);
    expect(decoded.meterId, reading.meterId);
    expect(decoded.previousValue, reading.previousValue);
    expect(decoded.currentValue, reading.currentValue);
    expect(decoded.createdAt, reading.createdAt);
  });

  test('Reading round-trips photoBase64, and defaults to null when absent', () {
    final withPhoto = Reading(
      id: 'reading-1',
      meterId: 'meter-1',
      previousValue: 0,
      currentValue: 10,
      createdAt: DateTime.utc(2026, 1, 1),
      photoBase64: 'ZmFrZS1ieXRlcw==',
    );
    expect(Reading.fromJson(withPhoto.toJson()).photoBase64, 'ZmFrZS1ieXRlcw==');

    final withoutPhoto = Reading.fromJson({
      'id': 'reading-2',
      'meterId': 'meter-1',
      'previousValue': 0,
      'currentValue': 10,
      'createdAt': DateTime.utc(2026, 1, 1).toIso8601String(),
    });
    expect(withoutPhoto.photoBase64, isNull);
  });

  test('consumption is currentValue minus previousValue', () {
    final reading = Reading(
      id: 'reading-1',
      meterId: 'meter-1',
      previousValue: 10,
      currentValue: 15.5,
      createdAt: DateTime.now(),
    );

    expect(reading.consumption, 5.5);
  });

  test('copyWith changes only the given fields', () {
    final reading = Reading(
      id: 'reading-1',
      meterId: 'meter-1',
      previousValue: 10,
      currentValue: 15,
      createdAt: DateTime.utc(2026, 1, 1),
    );

    final corrected = reading.copyWith(currentValue: 20);

    expect(corrected.currentValue, 20);
    expect(corrected.previousValue, reading.previousValue);
    expect(corrected.id, reading.id);
  });
}
