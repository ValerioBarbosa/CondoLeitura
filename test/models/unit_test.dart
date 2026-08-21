import 'package:condoleitura/models/unit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Unit round-trips through JSON preserving all fields', () {
    final unit = Unit(
      id: 'unit-1',
      towerId: 'tower-1',
      number: '101',
      floor: '1',
      code: 'A101',
      notes: 'Chave reserva com o síndico.',
      isActive: false,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 2),
    );

    final decoded = Unit.fromJson(unit.toJson());

    expect(decoded.id, unit.id);
    expect(decoded.towerId, unit.towerId);
    expect(decoded.number, unit.number);
    expect(decoded.floor, unit.floor);
    expect(decoded.code, unit.code);
    expect(decoded.notes, unit.notes);
    expect(decoded.isActive, unit.isActive);
    expect(decoded.createdAt, unit.createdAt);
    expect(decoded.updatedAt, unit.updatedAt);
  });

  test('Unit.fromJson fills in defaults for missing optional fields', () {
    final decoded = Unit.fromJson({
      'id': 'unit-2',
      'towerId': 'tower-1',
      'number': '102',
    });

    expect(decoded.floor, '');
    expect(decoded.code, '');
    expect(decoded.notes, '');
    expect(decoded.isActive, isTrue);
  });

  test('copyWith changes only the given fields', () {
    final unit = Unit(
      id: 'unit-1',
      towerId: 'tower-1',
      number: '101',
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );

    final renumbered = unit.copyWith(number: '201');

    expect(renumbered.number, '201');
    expect(renumbered.id, unit.id);
    expect(renumbered.towerId, unit.towerId);
  });
}
