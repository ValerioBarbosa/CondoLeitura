class Migrations {
  static const createCondominiums = '''
    CREATE TABLE IF NOT EXISTS condominiums (
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

  static const createTowers = '''
    CREATE TABLE IF NOT EXISTS towers (
      id TEXT PRIMARY KEY,
      condominium_id TEXT NOT NULL,
      name TEXT NOT NULL,
      code TEXT,
      notes TEXT,
      active INTEGER NOT NULL DEFAULT 1,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );
  ''';

  static const createUnits = '''
    CREATE TABLE IF NOT EXISTS units (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      tower_id TEXT NOT NULL,
      number TEXT NOT NULL,
      floor TEXT,
      code TEXT,
      reading_order INTEGER NOT NULL DEFAULT 0,
      active INTEGER NOT NULL DEFAULT 1,
      notes TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT,
      FOREIGN KEY (tower_id) REFERENCES towers(id) ON DELETE CASCADE,
      UNIQUE(tower_id, number)
    );
  ''';

  static const createUnitsTowerIndex = '''
    CREATE INDEX IF NOT EXISTS idx_units_tower_id ON units(tower_id);
  ''';


  static const createMeters = '''
    CREATE TABLE IF NOT EXISTS meters (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      unit_id INTEGER NOT NULL,
      type TEXT NOT NULL CHECK(type IN ('water', 'gas')),
      serial_number TEXT NOT NULL COLLATE NOCASE UNIQUE,
      label TEXT,
      initial_reading REAL NOT NULL DEFAULT 0,
      integer_digits INTEGER NOT NULL DEFAULT 5,
      decimal_digits INTEGER NOT NULL DEFAULT 3,
      active INTEGER NOT NULL DEFAULT 1,
      installed_at TEXT,
      notes TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT,
      FOREIGN KEY (unit_id) REFERENCES units(id) ON DELETE CASCADE
    );
  ''';

  static const createMetersUnitIndex = '''
    CREATE INDEX IF NOT EXISTS idx_meters_unit_id ON meters(unit_id);
  ''';


  static const createReadings = '''
    CREATE TABLE IF NOT EXISTS readings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      local_id TEXT NOT NULL UNIQUE,
      unit_id INTEGER NOT NULL,
      meter_id INTEGER NOT NULL,
      value REAL NOT NULL,
      reading_date TEXT NOT NULL,
      photo_path TEXT NOT NULL,
      ocr_raw_text TEXT,
      ocr_confidence REAL,
      requires_review INTEGER NOT NULL DEFAULT 0,
      confirmed_manually INTEGER NOT NULL DEFAULT 0,
      notes TEXT,
      created_at TEXT NOT NULL,
      FOREIGN KEY (unit_id) REFERENCES units(id) ON DELETE CASCADE,
      FOREIGN KEY (meter_id) REFERENCES meters(id) ON DELETE CASCADE
    );
  ''';

  static const createReadingsMeterIndex = '''
    CREATE INDEX IF NOT EXISTS idx_readings_meter_date
    ON readings(meter_id, reading_date DESC);
  ''';

  static const createSyncQueue = '''
    CREATE TABLE IF NOT EXISTS sync_queue (
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
