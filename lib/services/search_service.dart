import 'db_service.dart';

/// Handles query parsing and photo search. Will support vector search later.
class SearchService {
  final DBService _dbService = DBService();

  /// Simple keyword search placeholder. Returns list of photo ids.
  Future<List<String>> searchPhotos(String query) async {
    final db = await _dbService.database;
    // Basic search:
    // - If query starts with '#', search tags
    // - Else, search in photo uri or OCR text
    if (query.startsWith('#')) {
      final tag = query.substring(1).toLowerCase();
      final result = db.select('''
        SELECT p.id FROM photos p
        JOIN photo_tags pt ON pt.photo_id = p.id
        JOIN tags t ON t.tag_id = pt.tag_id
        WHERE LOWER(t.label) LIKE ?
        ORDER BY p.timestamp DESC NULLS LAST
      ''', ['%$tag%']);
      return result.map((r) => r['id'] as String).toList();
    } else {
      final q = query.toLowerCase();
      final result = db.select('''
        SELECT id FROM photos
        WHERE LOWER(uri) LIKE ?
           OR id IN (SELECT photo_id FROM ocr_text WHERE LOWER(text) LIKE ?)
        ORDER BY timestamp DESC NULLS LAST
      ''', ['%$q%', '%$q%']);
      return result.map((r) => r['id'] as String).toList();
    }
  }

  // TODO: Add semantic vector search using sqlite-vec once embeddings are available.
}


