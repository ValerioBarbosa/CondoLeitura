import 'package:sqflite/sqflite.dart';

import '../../database/database_service.dart';
import '../../models/tower.dart';
import '../../models/unit.dart';
import '../unit_repository.dart';

class LocalUnitRepository implements UnitRepository {
  LocalUnitRepository({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService.instance;

  final DatabaseService _databaseService;

  @override
  Future<void> ensureTower(Tower tower) async {
    final db = await _databaseService.database;
    final values = <String, Object?>{
      'condominium_id': tower.condominiumId,
      'name': tower.name,
      'code': tower.code.trim().isEmpty ? null : tower.code.trim(),
      'notes': tower.notes.trim().isEmpty ? null : tower.notes.trim(),
      'active': tower.isActive ? 1 : 0,
      'updated_at': tower.updatedAt.toIso8601String(),
    };
    final affected = await db.update(
      'towers',
      values,
      where: 'id = ?',
      whereArgs: [tower.id],
    );
    if (affected == 0) {
      await db.insert('towers', {
        'id': tower.id,
        ...values,
        'created_at': tower.createdAt.toIso8601String(),
      });
    }
  }

  @override
  Future<List<Unit>> findByTower(
    String towerId, {
    String? search,
    bool? active,
  }) async {
    final db = await _databaseService.database;
    final where = <String>['tower_id = ?'];
    final args = <Object?>[towerId];

    final term = search?.trim();
    if (term != null && term.isNotEmpty) {
      where.add('(number LIKE ? OR code LIKE ? OR floor LIKE ?)');
      final like = '%$term%';
      args.addAll([like, like, like]);
    }

    if (active != null) {
      where.add('active = ?');
      args.add(active ? 1 : 0);
    }

    final rows = await db.query(
      'units',
      where: where.join(' AND '),
      whereArgs: args,
      orderBy:
          'CASE WHEN reading_order = 0 THEN 1 ELSE 0 END, reading_order, number COLLATE NOCASE',
    );
    return rows.map(Unit.fromMap).toList(growable: false);
  }

  @override
  Future<Unit?> findById(int id) async {
    final db = await _databaseService.database;
    final rows = await db.query(
      'units',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : Unit.fromMap(rows.first);
  }

  @override
  Future<int> insert(Unit unit) async {
    final db = await _databaseService.database;
    final map = unit.toMap()..remove('id');
    return db.insert('units', map, conflictAlgorithm: ConflictAlgorithm.abort);
  }

  @override
  Future<void> update(Unit unit) async {
    final id = unit.id;
    if (id == null) throw ArgumentError('A unidade precisa possuir ID.');
    final db = await _databaseService.database;
    final affected = await db.update(
      'units',
      unit.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [id],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    if (affected == 0) throw StateError('Unidade não encontrada.');
  }

  @override
  Future<void> delete(int id) async {
    final db = await _databaseService.database;
    await db.delete('units', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> deleteTower(String towerId) async {
    final db = await _databaseService.database;
    await db.delete('towers', where: 'id = ?', whereArgs: [towerId]);
  }

  @override
  Future<int> countByTower(String towerId) async {
    final db = await _databaseService.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM units WHERE tower_id = ?',
      [towerId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<bool> numberExists({
    required String towerId,
    required String number,
    int? excludingId,
  }) async {
    final db = await _databaseService.database;
    final where = StringBuffer('tower_id = ? AND LOWER(number) = LOWER(?)');
    final args = <Object?>[towerId, number.trim()];
    if (excludingId != null) {
      where.write(' AND id <> ?');
      args.add(excludingId);
    }
    final result = await db.query(
      'units',
      columns: ['id'],
      where: where.toString(),
      whereArgs: args,
      limit: 1,
    );
    return result.isNotEmpty;
  }
}
