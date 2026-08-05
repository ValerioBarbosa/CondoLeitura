import '../models/tower.dart';
import '../models/unit.dart';

abstract interface class UnitRepository {
  Future<void> ensureTower(Tower tower);

  Future<List<Unit>> findByTower(
    String towerId, {
    String? search,
    bool? active,
  });

  Future<Unit?> findById(int id);

  Future<int> insert(Unit unit);

  Future<void> update(Unit unit);

  Future<void> delete(int id);

  Future<void> deleteTower(String towerId);

  Future<int> countByTower(String towerId);

  Future<bool> numberExists({
    required String towerId,
    required String number,
    int? excludingId,
  });
}
