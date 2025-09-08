import 'dart:typed_data';

import '../services/db_service.dart';

class EmbeddingDao {
  final DBService _dbService = DBService();

  Future<void> upsertPhotoEmbedding({required String photoId, required Uint8List embeddingBytes}) async {
    final db = await _dbService.database;
    db.execute('''
      INSERT INTO ${DBService.tablePhotoEmbeddings}(photo_id, embedding)
      VALUES(?, ?)
      ON CONFLICT(photo_id) DO UPDATE SET embedding = excluded.embedding
    ''', [photoId, embeddingBytes]);
  }

  Future<void> upsertFaceEmbedding({required String faceId, required Uint8List embeddingBytes}) async {
    final db = await _dbService.database;
    db.execute('''
      INSERT INTO ${DBService.tableFaceEmbeddings}(face_id, embedding)
      VALUES(?, ?)
      ON CONFLICT(face_id) DO UPDATE SET embedding = excluded.embedding
    ''', [faceId, embeddingBytes]);
  }
}


