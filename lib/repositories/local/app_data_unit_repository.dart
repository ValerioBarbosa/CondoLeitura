import '../../models/app_data.dart';
import '../../models/tower.dart';
import '../../models/unit.dart';
import '../unit_repository.dart';

/// Implementação multiplataforma baseada no armazenamento já usado pelo MVP.
/// Funciona no Chrome, Windows, Android e iOS por meio do SharedPreferences.
class AppDataUnitRepository implements UnitRepository {
  AppDataUnitRepository(this._data);

  final AppData _data;

  @override
  Future<void> ensureTower(Tower tower) async {}

  @override
  Future<List<Unit>> findByTower(
    String towerId, {
    String? search,
    bool? active,
  }) async {
    return _data.unitsForTower(
      towerId,
      search: search,
      active: active,
    );
  }

  @override
  Future<Unit?> findById(int id) async => _data.unitById(id);

  @override
  Future<int> insert(Unit unit) async => _data.addUnit(unit);

  @override
  Future<void> update(Unit unit) async => _data.updateUnit(unit);

  @override
  Future<void> delete(int id) async => _data.removeUnit(id);

  @override
  Future<void> deleteTower(String towerId) async => _data.removeTower(towerId);

  @override
  Future<int> countByTower(String towerId) async => _data.unitCountForTower(towerId);

  @override
  Future<bool> numberExists({
    required String towerId,
    required String number,
    int? excludingId,
  }) async {
    return _data.unitIdentifierExists(
      towerId: towerId,
      identifier: number,
      excludingId: excludingId,
    );
  }
}
