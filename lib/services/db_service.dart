import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

/// Provides database access and schema initialization.
/// - Uses sqlite3 via Dart FFI
/// - Loads sqlite-vec extension if available
/// - Creates schema on first launch
class DBService {
  static final DBService _instance = DBService._internal();
  factory DBService() => _instance;
  DBService._internal();

  sqlite.Database? _db;

  Future<sqlite.Database> get database async {
    if (_db != null) return _db!;
    _db = await _openAndInit();
    return _db!;
  }

  Future<sqlite.Database> _openAndInit() async {
    // Choose a writable app document directory database path
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'lens_librarian.db');
    final db = sqlite.sqlite3.open(dbPath);

    // Attempt to load sqlite-vec extension if bundled
    // TODO: Place compiled sqlite-vec library under appropriate platform directories and load here
    try {
      // Example shared library name may vary by platform
      db.execute("SELECT load_extension('sqlitevec')");
    } catch (_) {
      // Extension is optional initially; ignore if not available yet
    }

    _createSchemaIfNeeded(db);
    _verifyRW(db);
    return db;
  }

  void _createSchemaIfNeeded(sqlite.Database db) {
    // Enable foreign keys
    db.execute('PRAGMA foreign_keys = ON');

    // Photos table
    db.execute('''
      CREATE TABLE IF NOT EXISTS photos (
        id TEXT PRIMARY KEY,
        uri TEXT NOT NULL,
        width INTEGER NOT NULL,
        height INTEGER NOT NULL,
        timestamp INTEGER,
        latitude REAL,
        longitude REAL,
        dominant_color_argb INTEGER,
        is_screenshot INTEGER NOT NULL DEFAULT 0,
        is_indexed INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Photo embeddings (global image features)
    db.execute('''
      CREATE TABLE IF NOT EXISTS photo_embeddings (
        photo_id TEXT PRIMARY KEY REFERENCES photos(id) ON DELETE CASCADE,
        -- Vector column; stored as BLOB or via sqlite-vec virtual table in the future
        embedding BLOB NOT NULL
      )
    ''');

    // Faces metadata
    db.execute('''
      CREATE TABLE IF NOT EXISTS faces (
        face_id TEXT PRIMARY KEY,
        photo_id TEXT NOT NULL REFERENCES photos(id) ON DELETE CASCADE,
        bbox_left REAL NOT NULL,
        bbox_top REAL NOT NULL,
        bbox_right REAL NOT NULL,
        bbox_bottom REAL NOT NULL,
        landmarks_json TEXT
      )
    ''');

    // Face embeddings
    db.execute('''
      CREATE TABLE IF NOT EXISTS face_embeddings (
        face_id TEXT PRIMARY KEY REFERENCES faces(face_id) ON DELETE CASCADE,
        embedding BLOB NOT NULL
      )
    ''');

    // Tags and mapping
    db.execute('''
      CREATE TABLE IF NOT EXISTS tags (
        tag_id TEXT PRIMARY KEY,
        label TEXT NOT NULL UNIQUE,
        created_at INTEGER NOT NULL
      )
    ''');
    db.execute('''
      CREATE TABLE IF NOT EXISTS photo_tags (
        photo_id TEXT NOT NULL REFERENCES photos(id) ON DELETE CASCADE,
        tag_id TEXT NOT NULL REFERENCES tags(tag_id) ON DELETE CASCADE,
        PRIMARY KEY (photo_id, tag_id)
      )
    ''');

    // People and mapping
    db.execute('''
      CREATE TABLE IF NOT EXISTS people (
        person_id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
    db.execute('''
      CREATE TABLE IF NOT EXISTS face_people (
        face_id TEXT NOT NULL REFERENCES faces(face_id) ON DELETE CASCADE,
        person_id TEXT NOT NULL REFERENCES people(person_id) ON DELETE CASCADE,
        PRIMARY KEY (face_id, person_id)
      )
    ''');

    // OCR text table (optional)
    db.execute('''
      CREATE TABLE IF NOT EXISTS ocr_text (
        photo_id TEXT PRIMARY KEY REFERENCES photos(id) ON DELETE CASCADE,
        text TEXT
      )
    ''');
  }

  void _verifyRW(sqlite.Database db) {
    // Insert a small test row and remove it to ensure write works
    db.execute("CREATE TABLE IF NOT EXISTS __probe(k TEXT PRIMARY KEY, v TEXT)");
    db.execute("INSERT OR REPLACE INTO __probe(k, v) VALUES('ok','ok')");
    final result = db.select("SELECT v FROM __probe WHERE k = 'ok'");
    if (result.isEmpty || result.first.values.first != 'ok') {
      throw StateError('Database probe failed');
    }
    db.execute("DELETE FROM __probe WHERE k = 'ok'");
  }

  Future<void> dispose() async {
    _db?.dispose();
    _db = null;
  }
}


