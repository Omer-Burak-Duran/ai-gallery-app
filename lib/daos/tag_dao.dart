import '../services/db_service.dart';

class TagDao {
  final DBService _dbService = DBService();

  Future<void> upsertTag({required String tagId, required String label, required int createdAtMs}) async {
    final db = await _dbService.database;
    db.execute('''
      INSERT INTO ${DBService.tableTags}(tag_id, label, created_at)
      VALUES(?, ?, ?)
      ON CONFLICT(tag_id) DO UPDATE SET label = excluded.label
    ''', [tagId, label, createdAtMs]);
  }

  Future<List<String>> getAllTagLabels() async {
    final db = await _dbService.database;
    final rows = db.select('SELECT label FROM ${DBService.tableTags} ORDER BY label');
    return rows.map((r) => r['label'] as String).toList();
  }
}


