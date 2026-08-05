import '../../database/database_service.dart';
import '../../models/reading.dart';
import '../reading_repository.dart';

class LocalReadingRepository implements ReadingRepository {
  LocalReadingRepository({DatabaseService? databaseService}) : _dbService = databaseService ?? DatabaseService.instance;
  final DatabaseService _dbService;
  @override Future<int> insert(Reading reading) async { final db=await _dbService.database; final v=Map<String,Object?>.from(reading.toMap())..remove('id'); return db.insert('readings',v); }
  @override Future<List<Reading>> findByMeter(int meterId) async { final db=await _dbService.database; final rows=await db.query('readings',where:'meter_id = ?',whereArgs:[meterId],orderBy:'reading_date DESC'); return rows.map(Reading.fromMap).toList(); }
  @override Future<Reading?> latestByMeter(int meterId) async { final list=await findByMeter(meterId); return list.isEmpty?null:list.first; }
  @override Future<void> delete(int id) async { final db=await _dbService.database; await db.delete('readings',where:'id = ?',whereArgs:[id]); }
}
