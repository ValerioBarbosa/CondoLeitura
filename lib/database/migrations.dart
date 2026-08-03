class Migrations {
  static const createCondominiums = '''
    CREATE TABLE condominiums (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      local_id TEXT NOT NULL UNIQUE,
      remote_id TEXT,
      name TEXT NOT NULL,
      code TEXT,
      document TEXT,
      address TEXT,
      city TEXT,
      state TEXT,
      zip_code TEXT,
      phone TEXT,
      email TEXT,
      administrator TEXT,
      contact_name TEXT,
      notes TEXT,
      photo_path TEXT,
      status TEXT NOT NULL DEFAULT 'active',
      sync_status TEXT NOT NULL DEFAULT 'pending',
      created_at TEXT NOT NULL,
      updated_at TEXT
    );
  ''';

  static const createUnits = '''
    CREATE TABLE units (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      tower_id INTEGER NOT NULL,
      number TEXT NOT NULL,
      floor TEXT,
      code TEXT,
      active INTEGER NOT NULL DEFAULT 1,
      notes TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT,
      FOREIGN KEY (tower_id) REFERENCES towers(id) ON DELETE CASCADE,
      UNIQUE(tower_id, number)
    );
  ''';

  static const createSyncQueue = '''
    CREATE TABLE sync_queue (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      entity_type TEXT NOT NULL,
      entity_local_id TEXT NOT NULL,
      operation TEXT NOT NULL,
      payload TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'pending',
      attempts INTEGER NOT NULL DEFAULT 0,
      last_error TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT
    );
  ''';
}
