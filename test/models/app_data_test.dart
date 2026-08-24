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

  test('addReading stores the optional photo and defaults it to null', () async {
    final data = AppData();
    await data.load();

    final condominiumId = data.condominiums.first.id;
    data.addTower(condominiumId: condominiumId, name: 'Torre E', code: 'E');
    final towerId = data.towersFor(condominiumId).first.id;
    data.addUnit(towerId: towerId, number: '501');
    final unitId = data.unitsFor(towerId).first.id;
    data.addMeter(unitId: unitId, type: meterTypeWater);
    final meterId = data.metersFor(unitId).first.id;

    final withoutPhoto = data.addReading(meterId: meterId, currentValue: 10);
    expect(withoutPhoto.photoBase64, isNull);

    final withPhoto = data.addReading(meterId: meterId, currentValue: 20, photoBase64: 'Zm9v');
    expect(withPhoto.photoBase64, 'Zm9v');
  });

  test('addReading stores GPS coordinates and falls back to the settings reader name', () async {
    final data = AppData();
    await data.load();

    final condominiumId = data.condominiums.first.id;
    data.addTower(condominiumId: condominiumId, name: 'Torre F', code: 'F');
    final towerId = data.towersFor(condominiumId).first.id;
    data.addUnit(towerId: towerId, number: '601');
    final unitId = data.unitsFor(towerId).first.id;
    data.addMeter(unitId: unitId, type: meterTypeWater);
    final meterId = data.metersFor(unitId).first.id;

    data.updateSettings(data.settings.copyWith(readerName: 'Valério'));

    final withLocation = data.addReading(
      meterId: meterId,
      currentValue: 10,
      latitude: -23.5,
      longitude: -46.6,
    );
    expect(withLocation.latitude, -23.5);
    expect(withLocation.longitude, -46.6);
    expect(withLocation.hasLocation, isTrue);
    expect(withLocation.readerName, 'Valério');

    final explicitReader = data.addReading(meterId: meterId, currentValue: 20, readerName: 'Outro leiturista');
    expect(explicitReader.readerName, 'Outro leiturista');
    expect(explicitReader.hasLocation, isFalse);
  });

  test('updateSettings persists across reloads', () async {
    final data = AppData();
    await data.load();

    data.updateSettings(
      data.settings.copyWith(confirmReading: false, registerLocation: true, readerName: 'Valério'),
    );
    // updateSettings persists fire-and-forget; let the pending write land
    // before reading it back through a fresh AppData instance.
    await Future<void>.delayed(Duration.zero);

    final reloaded = AppData();
    await reloaded.load();

    expect(reloaded.settings.confirmReading, isFalse);
    expect(reloaded.settings.registerLocation, isTrue);
    expect(reloaded.settings.readerName, 'Valério');
  });

  test('no-reading records can be added, listed per meter, removed and cascade on meter removal', () async {
    final data = AppData();
    await data.load();

    final condominiumId = data.condominiums.first.id;
    data.addTower(condominiumId: condominiumId, name: 'Torre G', code: 'G');
    final towerId = data.towersFor(condominiumId).first.id;
    data.addUnit(towerId: towerId, number: '701');
    final unitId = data.unitsFor(towerId).first.id;
    data.addMeter(unitId: unitId, type: meterTypeWater);
    final meterId = data.metersFor(unitId).first.id;

    final record = data.addNoReadingRecord(meterId: meterId, reason: 'Morador ausente', notes: 'Sem resposta.');

    expect(data.noReadingRecordsForMeter(meterId), hasLength(1));
    expect(data.noReadingRecords, contains(record));

    data.removeNoReadingRecord(record.id);
    expect(data.noReadingRecordsForMeter(meterId), isEmpty);

    data.addNoReadingRecord(meterId: meterId, reason: 'Outro');
    data.removeMeter(meterId);
    expect(data.noReadingRecordsForMeter(meterId), isEmpty);
  });
}
