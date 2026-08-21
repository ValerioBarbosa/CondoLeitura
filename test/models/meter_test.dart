import 'package:condoleitura/models/meter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Meter round-trips through JSON preserving all fields', () {
    final meter = Meter(
      id: 'meter-1',
      unitId: 'unit-1',
      type: meterTypeGas,
      serialNumber: 'SN-123',
      notes: 'Trocado em 2025.',
      isActive: false,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 2),
    );

    final decoded = Meter.fromJson(meter.toJson());

    expect(decoded.id, meter.id);
    expect(decoded.unitId, meter.unitId);
    expect(decoded.type, meter.type);
    expect(decoded.serialNumber, meter.serialNumber);
    expect(decoded.notes, meter.notes);
    expect(decoded.isActive, meter.isActive);
    expect(decoded.createdAt, meter.createdAt);
    expect(decoded.updatedAt, meter.updatedAt);
  });

  test('Meter.fromJson defaults to water when type is missing', () {
    final decoded = Meter.fromJson({
      'id': 'meter-2',
      'unitId': 'unit-1',
    });

    expect(decoded.type, meterTypeWater);
    expect(decoded.serialNumber, '');
    expect(decoded.isActive, isTrue);
  });

  test('meterTypes lists exactly water and gas', () {
    expect(meterTypes, [meterTypeWater, meterTypeGas]);
  });
}
