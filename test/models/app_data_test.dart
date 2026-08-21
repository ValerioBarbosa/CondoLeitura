import 'package:condoleitura/models/app_data.dart';
import 'package:condoleitura/models/meter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('removing a tower cascades to its units and meters', () async {
    final data = AppData();
    await data.load();

    final condominiumId = data.condominiums.first.id;
    data.addTower(condominiumId: condominiumId, name: 'Torre A', code: 'A');
    final towerId = data.towersFor(condominiumId).first.id;

    data.addUnit(towerId: towerId, number: '101');
    final unitId = data.unitsFor(towerId).first.id;

    data.addMeter(unitId: unitId, type: meterTypeWater);
    data.addMeter(unitId: unitId, type: meterTypeGas);
    final waterMeterId = data.metersFor(unitId).firstWhere((m) => m.type == meterTypeWater).id;
    data.addReading(meterId: waterMeterId, currentValue: 100);

    expect(data.unitCountForTower(towerId), 1);
    expect(data.meterCountForUnit(unitId), 2);
    expect(data.unitCountFor(condominiumId), 1);
    expect(data.meterCountForCondominium(condominiumId), 2);
    expect(data.readingsForMeter(waterMeterId), hasLength(1));

    data.removeTower(towerId);

    expect(data.unitsFor(towerId), isEmpty);
    expect(data.metersFor(unitId), isEmpty);
    expect(data.readingsForMeter(waterMeterId), isEmpty);
    expect(data.unitCountFor(condominiumId), 0);
    expect(data.meterCountForCondominium(condominiumId), 0);
  });

  test('removing a unit cascades to its meters but keeps sibling units', () async {
    final data = AppData();
    await data.load();

    final condominiumId = data.condominiums.first.id;
    data.addTower(condominiumId: condominiumId, name: 'Torre B', code: 'B');
    final towerId = data.towersFor(condominiumId).first.id;

    data.addUnit(towerId: towerId, number: '201');
    data.addUnit(towerId: towerId, number: '202');
    final units = data.unitsFor(towerId);
    final keptUnitId = units.firstWhere((u) => u.number == '201').id;
    final removedUnitId = units.firstWhere((u) => u.number == '202').id;

    data.addMeter(unitId: removedUnitId, type: meterTypeWater);

    data.removeUnit(removedUnitId);

    expect(data.unitsFor(towerId).map((u) => u.id), [keptUnitId]);
    expect(data.metersFor(removedUnitId), isEmpty);
  });

  test('addReading auto-fills previousValue from the meter\'s last reading', () async {
    final data = AppData();
    await data.load();

    final condominiumId = data.condominiums.first.id;
    data.addTower(condominiumId: condominiumId, name: 'Torre C', code: 'C');
    final towerId = data.towersFor(condominiumId).first.id;
    data.addUnit(towerId: towerId, number: '301');
    final unitId = data.unitsFor(towerId).first.id;
    data.addMeter(unitId: unitId, type: meterTypeWater);
    final meterId = data.metersFor(unitId).first.id;

    expect(data.lastReadingFor(meterId), isNull);

    final first = data.addReading(meterId: meterId, currentValue: 50);
    expect(first.previousValue, 0);
    expect(first.consumption, 50);

    final second = data.addReading(meterId: meterId, currentValue: 80);
    expect(second.previousValue, 50);
    expect(second.consumption, 30);

    expect(data.lastReadingFor(meterId)!.id, second.id);
    expect(data.readingsForMeter(meterId), hasLength(2));
    expect(data.totalConsumption, 80);
  });

  test('removing a meter cascades to its readings', () async {
    final data = AppData();
    await data.load();

    final condominiumId = data.condominiums.first.id;
    data.addTower(condominiumId: condominiumId, name: 'Torre D', code: 'D');
    final towerId = data.towersFor(condominiumId).first.id;
    data.addUnit(towerId: towerId, number: '401');
    final unitId = data.unitsFor(towerId).first.id;
    data.addMeter(unitId: unitId, type: meterTypeGas);
    final meterId = data.metersFor(unitId).first.id;
    data.addReading(meterId: meterId, currentValue: 10);

    data.removeMeter(meterId);

    expect(data.readingsForMeter(meterId), isEmpty);
    expect(data.totalConsumption, 0);
  });
}
