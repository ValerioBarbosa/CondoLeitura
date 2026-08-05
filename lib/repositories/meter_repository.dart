import '../models/meter.dart';

abstract interface class MeterRepository {
  Future<List<Meter>> findByUnit(
    int unitId, {
    String? search,
    MeterType? type,
    bool? active,
  });

  Future<Meter?> findById(int id);

  Future<int> insert(Meter meter);

  Future<void> update(Meter meter);

  Future<void> delete(int id);

  Future<int> countByUnit(int unitId);

  Future<bool> serialNumberExists({
    required String serialNumber,
    int? excludingId,
  });
}
