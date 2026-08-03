import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../database/database_service.dart';
import '../../models/condominium.dart';
import '../condominium_repository.dart';

class LocalCondominiumRepository implements CondominiumRepository {
  final DatabaseService databaseService;

  LocalCondominiumRepository(this.databaseService);

  @override
  Future<List<Condominium>> findAll({
    String? search,
    CondominiumStatus? status,
  }) async {
    final db = await databaseService.database;
    final where = <String>[];
    final args = <Object?>[];

    if (search != null && search.trim().isNotEmpty) {
      where.add('(name LIKE ? OR code LIKE ? OR city LIKE ?)');
      final term = '%${search.trim()}%';
      args.addAll([term, term, term]);
    }

    if (status != null) {
      where.add('status = ?');
      args.add(status.name);
    }

    final rows = await db.query(
      'condominiums',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'name COLLATE NOCASE ASC',
    );

    return rows.map(Condominium.fromMap).toList();
  }

  @override
  Future<Condominium?> findById(int id) async {
    final db = await databaseService.database;
    final rows = await db.query(
      'condominiums',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : Condominium.fromMap(rows.first);
  }

  @override
  Future<int> create(Condominium condominium) async {
    final db = await databaseService.database;
    return db.transaction((txn) async {
      final id = await txn.insert(
        'condominiums',
        condominium.toMap()..remove('id'),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      await txn.insert('sync_queue', {
        'entity_type': 'condominium',
        'entity_local_id': condominium.localId,
        'operation': 'upsert',
        'payload': jsonEncode(condominium.toMap()..remove('id')),
        'status': 'pending',
        'attempts': 0,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });

      return id;
    });
  }

  @override
  Future<void> update(Condominium condominium) async {
    if (condominium.id == null) {
      throw ArgumentError(
        'O condomínio precisa possuir um ID para atualização.',
      );
    }

    final db = await databaseService.database;
    final now = DateTime.now().toUtc();

    final updatedCondominium = condominium.copyWith(
      syncStatus: 'pending',
      updatedAt: now,
    );

    final data = updatedCondominium.toMap()..remove('id');

    await db.transaction((txn) async {
      final updatedRows = await txn.update(
        'condominiums',
        data,
        where: 'id = ?',
        whereArgs: [condominium.id],
      );

      if (updatedRows == 0) {
        throw StateError('Condomínio não encontrado para atualização.');
      }

      await txn.insert('sync_queue', {
        'entity_type': 'condominium',
        'entity_local_id': updatedCondominium.localId,
        'operation': 'upsert',
        'payload': jsonEncode(data),
        'status': 'pending',
        'attempts': 0,
        'created_at': now.toIso8601String(),
      });
    });
  }

  @override
  Future<void> archive(int id) async {
    final item = await findById(id);
    if (item == null) return;
    await update(item.copyWith(status: CondominiumStatus.archived));
  }

  @override
  Future<void> restore(int id) async {
    final item = await findById(id);
    if (item == null) return;
    await update(item.copyWith(status: CondominiumStatus.active));
  }

  @override
  Future<void> deletePermanently(int id) async {
    final item = await findById(id);
    if (item == null) return;

    final db = await databaseService.database;

    await db.transaction((txn) async {
      await txn.delete(
        'sync_queue',
        where: 'entity_type = ? AND entity_local_id = ?',
        whereArgs: ['condominium', item.localId],
      );

      final deletedRows = await txn.delete(
        'condominiums',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (deletedRows == 0) {
        throw StateError('Não foi possível excluir o condomínio.');
      }
    });
  }

  @override
  Future<int> duplicate(int id, String newName) async {
    final source = await findById(id);
    if (source == null) {
      throw StateError('Condomínio não encontrado.');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final copy = source.copyWith(
      id: null,
      localId: 'cond-$timestamp',
      remoteId: null,
      name: newName,
      code: source.code == null ? null : '${source.code}-COPIA-$timestamp',
      status: CondominiumStatus.active,
      syncStatus: 'pending',
      createdAt: DateTime.now().toUtc(),
      updatedAt: null,
    );

    return create(copy);
  }

  @override
  Future<void> synchronize(int id) async {
    final item = await findById(id);
    if (item == null) return;

    final db = await databaseService.database;
    await db.insert('sync_queue', {
      'entity_type': 'condominium',
      'entity_local_id': item.localId,
      'operation': 'upsert',
      'payload': jsonEncode(item.toMap()..remove('id')),
      'status': 'pending',
      'attempts': 0,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
  }
}
