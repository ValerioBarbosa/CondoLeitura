import 'package:sqflite/sqflite.dart';

import '../../database/database_service.dart';
import '../../models/meter.dart';
import '../meter_repository.dart';

class LocalMeterRepository implements MeterRepository {
  LocalMeterRepository({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService.instance;

  final DatabaseService _databaseService;

  @override
  Future<List<Meter>> findByUnit(
    int unitId, {
    String? search,
    MeterType? type,
    bool? active,
  }) async {
    final db = await _databaseService.database;
    final where = <String>['unit_id = ?'];
    final args = <Object?>[unitId];

    final term = search?.trim();
    if (term != null && term.isNotEmpty) {
      where.add('(serial_number LIKE ? OR label LIKE ?)');
      args.addAll(['%$term%', '%$term%']);
    }
    if (type != null) {
      where.add('type = ?');
      args.add(type.databaseValue);
    }
    if (active != null) {
      where.add('active = ?');
      args.add(active ? 1 : 0);
    }

    final rows = await db.query(
      'meters',
      where: where.join(' AND '),
      whereArgs: args,
      orderBy: 'active DESC, type ASC, serial_number COLLATE NOCASE ASC',
    );
    return rows.map(Meter.fromMap).toList(growable: false);
  }

  @override
  Future<Meter?> findById(int id) async {
    final db = await _databaseService.database;
    final rows = await db.query(
      'meters',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : Meter.fromMap(rows.first);
  }

  @override
  Future<int> insert(Meter meter) async {
    final db = await _databaseService.database;
    final values = Map<String, Object?>.from(meter.toMap())..remove('id');
    return db.insert('meters', values);
  }

  @override
  Future<void> update(Meter meter) async {
    final id = meter.id;
    if (id == null) throw ArgumentError('Medidor sem ID.');
    final db = await _databaseService.database;
    final values = Map<String, Object?>.from(meter.toMap())..remove('id');
    final affected = await db.update(
      'meters',
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (affected == 0) throw StateError('Medidor não encontrado.');
  }

  @override
  Future<void> delete(int id) async {
    final db = await _databaseService.database;
    await db.delete('meters', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<int> countByUnit(int unitId) async {
    final db = await _databaseService.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM meters WHERE unit_id = ?',
      [unitId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<bool> serialNumberExists({
    required String serialNumber,
    int? excludingId,
  }) async {
    final db = await _databaseService.database;
    final where = StringBuffer('LOWER(serial_number) = LOWER(?)');
    final args = <Object?>[serialNumber.trim()];
    if (excludingId != null) {
      where.write(' AND id <> ?');
      args.add(excludingId);
    }
    final rows = await db.query(
      'meters',
      columns: ['id'],
      where: where.toString(),
      whereArgs: args,
      limit: 1,
    );
    return rows.isNotEmpty;
  }
}
