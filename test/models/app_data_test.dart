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

    expect(data.unitCountForTower(towerId), 1);
    expect(data.meterCountForUnit(unitId), 2);
    expect(data.unitCountFor(condominiumId), 1);
    expect(data.meterCountForCondominium(condominiumId), 2);

    data.removeTower(towerId);

    expect(data.unitsFor(towerId), isEmpty);
    expect(data.metersFor(unitId), isEmpty);
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
}
