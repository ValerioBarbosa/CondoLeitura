import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'migrations.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();

  Database? _database;

  DatabaseService._internal();

  factory DatabaseService() => instance;

  Future<Database> get database async {
    final currentDatabase = _database;
    if (currentDatabase != null && currentDatabase.isOpen) {
      return currentDatabase;
    }

    _database = await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'condoleitura.db');

    return openDatabase(
      path,
      version: 2,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.transaction((txn) async {
      await txn.execute(Migrations.createCondominiums);
      await txn.execute(Migrations.createSyncQueue);
    });
  }

  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.transaction((txn) async {
        await _upgradeCondominiumsTable(txn);
        await txn.execute(Migrations.createSyncQueue.replaceFirst(
          'CREATE TABLE sync_queue',
          'CREATE TABLE IF NOT EXISTS sync_queue',
        ));
      });
    }
  }

  Future<void> _upgradeCondominiumsTable(DatabaseExecutor db) async {
    final columns = await db.rawQuery('PRAGMA table_info(condominiums)');
    final existingColumns = columns
        .map((column) => column['name'] as String?)
        .whereType<String>()
        .toSet();

    final additions = <String, String>{
      'local_id': 'TEXT',
      'remote_id': 'TEXT',
      'document': 'TEXT',
      'state': 'TEXT',
      'zip_code': 'TEXT',
      'phone': 'TEXT',
      'email': 'TEXT',
      'administrator': 'TEXT',
      'contact_name': 'TEXT',
      'notes': 'TEXT',
      'photo_path': 'TEXT',
      'sync_status': "TEXT NOT NULL DEFAULT 'pending'",
    };

    for (final entry in additions.entries) {
      if (!existingColumns.contains(entry.key)) {
        await db.execute(
          'ALTER TABLE condominiums ADD COLUMN ${entry.key} ${entry.value}',
        );
      }
    }

    // A versão antiga exigia updated_at. A versão atual permite valor nulo,
    // portanto não é necessária alteração estrutural nessa coluna.
    await db.rawUpdate('''
      UPDATE condominiums
      SET local_id = 'cond-' || id
      WHERE local_id IS NULL OR TRIM(local_id) = ''
    ''');

    await db.execute('''
      CREATE UNIQUE INDEX IF NOT EXISTS idx_condominiums_local_id
      ON condominiums(local_id)
    ''');
  }

  Future<void> close() async {
    final db = _database;
    if (db == null) return;

    await db.close();
    _database = null;
  }
}
