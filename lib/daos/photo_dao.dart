import '../models/photo.dart';
import '../services/db_service.dart';

/// Minimal DAO for photos table. Focused on common operations needed by indexing & UI.
class PhotoDao {
  final DBService _dbService = DBService();

  Future<void> upsertPhoto(Photo photo) async {
    final db = await _dbService.database;
    db.execute('''
      INSERT INTO ${DBService.tablePhotos} (
        id, uri, width, height, timestamp, latitude, longitude, dominant_color_argb, is_screenshot, is_indexed
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(id) DO UPDATE SET
        uri = excluded.uri,
        width = excluded.width,
        height = excluded.height,
        timestamp = excluded.timestamp,
        latitude = excluded.latitude,
        longitude = excluded.longitude,
        dominant_color_argb = excluded.dominant_color_argb,
        is_screenshot = excluded.is_screenshot,
        is_indexed = excluded.is_indexed
    ''', [
      photo.id,
      photo.uri,
      photo.width,
      photo.height,
      photo.timestamp?.millisecondsSinceEpoch,
      photo.latitude,
      photo.longitude,
      photo.dominantColorArgb,
      photo.isScreenshot ? 1 : 0,
      photo.isIndexed ? 1 : 0,
    ]);
  }

  Future<Photo?> getPhotoById(String id) async {
    final db = await _dbService.database;
    final rows = db.select('SELECT * FROM ${DBService.tablePhotos} WHERE id = ?', [id]);
    if (rows.isEmpty) return null;
    final r = rows.first;
    return Photo(
      id: r['id'] as String,
      uri: r['uri'] as String,
      width: r['width'] as int,
      height: r['height'] as int,
      timestamp: (r['timestamp'] as int?) != null
          ? DateTime.fromMillisecondsSinceEpoch(r['timestamp'] as int)
          : null,
      latitude: (r['latitude'] as num?)?.toDouble(),
      longitude: (r['longitude'] as num?)?.toDouble(),
      dominantColorArgb: r['dominant_color_argb'] as int?,
      isScreenshot: (r['is_screenshot'] as int) == 1,
      isIndexed: (r['is_indexed'] as int) == 1,
    );
  }

  Future<int> countPhotos() async {
    final db = await _dbService.database;
    final rows = db.select('SELECT COUNT(*) as c FROM ${DBService.tablePhotos}');
    return (rows.first['c'] as int);
  }
}


