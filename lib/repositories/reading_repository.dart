import '../models/reading.dart';
abstract interface class ReadingRepository {
  Future<int> insert(Reading reading);
  Future<List<Reading>> findByMeter(int meterId);
  Future<Reading?> latestByMeter(int meterId);
  Future<void> delete(int id);
}
