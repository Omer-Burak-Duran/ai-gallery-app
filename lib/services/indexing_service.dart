// ignore_for_file: avoid_print, unused_local_variable, dead_code
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:onnxruntime/onnxruntime.dart' as onnx;
import 'package:photo_manager/photo_manager.dart';
import 'package:workmanager/workmanager.dart';

// import 'db_service.dart';

/// Coordinates background indexing of photos.
class IndexingService {
  static const String taskName = 'indexPhotosTask';

  // final DBService _dbService = DBService();
  // TODO: Wire DAOs when implementing inserts
  // final PhotoDao _photoDao = PhotoDao();
  // final EmbeddingDao _embeddingDao = EmbeddingDao();

  /// Workmanager callback dispatcher. Must be a top-level or static function.
  static void callbackDispatcher() {
    Workmanager().executeTask((taskName, input) async {
      // Initialize any needed singletons here.
      final service = IndexingService();
      await service._indexBatch();
      return Future.value(true);
    });
  }

  /// Public entry point to schedule a one-off indexing task.
  Future<void> scheduleIndexingOnce() async {
    await Workmanager().registerOneOffTask('index_once', taskName);
  }

  /// Example batch indexing logic (placeholder).
  Future<void> _indexBatch() async {
    // TODO: read last indexed position from DB or preferences
    // 1) Request permission if not granted (in UI flow ideally)
    final perm = await PhotoManager.requestPermissionExtend();
    if (!perm.isAuth) {
      return; // No permission
    }

    // 2) Query recent images
    final paths = await PhotoManager.getAssetPathList(type: RequestType.image);
    if (paths.isEmpty) return;
    final recent = paths.first;
    final assets = await recent.getAssetListPaged(page: 0, size: 100);

    // 3) Initialize ML components (lazy)
    final faceDetector = FaceDetector(options: FaceDetectorOptions());
    final textRecognizer = TextRecognizer();
    onnx.OrtSession? clipImageSession;
    onnx.OrtSession? faceEmbedSession;

    try {
      // Initialize ONNX Runtime
      onnx.OrtEnv.instance; // ensure native is initialized

      // Load ONNX models from assets
      try {
        final imageModel = await rootBundle.load('assets/models/clip_image.onnx');
        final imageBytes = imageModel.buffer.asUint8List(imageModel.offsetInBytes, imageModel.lengthInBytes);
        clipImageSession = await onnx.OrtSession.fromBuffer(imageBytes, onnx.OrtSessionOptions());
      } catch (e) {
        // Model is placeholder; skip embedding until real model is bundled
        clipImageSession = null;
      }
      try {
        final faceModel = await rootBundle.load('assets/models/face_recognition.onnx');
        final faceBytes = faceModel.buffer.asUint8List(faceModel.offsetInBytes, faceModel.lengthInBytes);
        faceEmbedSession = await onnx.OrtSession.fromBuffer(faceBytes, onnx.OrtSessionOptions());
      } catch (e) {
        faceEmbedSession = null;
      }

      for (final asset in assets) {
        // 4) Retrieve downsized image bytes for faster processing
        final thumb = await asset.thumbnailDataWithSize(const ThumbnailSize(256, 256));
        if (thumb == null) continue;

        // TODO: Insert photo metadata row if not exists using PhotoDao
        // await _photoDao.upsertPhoto(Photo(...));

        // 5) Compute global image embedding with CLIP image encoder
        if (clipImageSession != null) {
          // TODO: Preprocess image -> tensor per model requirements
          // final Float32List vec = await _computeImageEmbedding(thumb, clipImageSession);
          // TODO: store vec in photo_embeddings via EmbeddingDao
        }

        // 6) Face detection
        final file = await asset.file;
        if (file == null) continue;
        final faces = await faceDetector.processImage(InputImage.fromFilePath(file.path));
        for (final face in faces) {
          // TODO: crop face region from original image or thumbnail
          // final Uint8List faceCrop = _cropFace(thumb, f.boundingBox);
          // TODO: run face embedding model and store 512-D descriptor
          // if (faceEmbedSession != null) {
          //   final Float32List faceEmbedding = await _computeFaceEmbedding(faceCrop, faceEmbedSession);
          //   // store in face_embeddings via EmbeddingDao
          // }
          // TODO: insert faces + face_embeddings rows
        }

        // 7) OCR for likely text images (heuristic placeholder)
        // TODO: decide if screenshot or text-likely; if so, run OCR and store text
        // final RecognizedText recognized = await textRecognizer.processImage(InputImage.fromFilePath(file.path));

        // 8) Mark photo as indexed in DB and update progress provider
        // TODO: DB update is_indexed = 1; notify provider
      }
    } finally {
      await faceDetector.close();
      await textRecognizer.close();
      clipImageSession?.release();
      faceEmbedSession?.release();
    }
  }

  // Placeholder: preprocess + run model to get Float32 embeddings
  // ignore: unused_element
  Future<Float32List> _computeImageEmbedding(Uint8List rgbaBytes, onnx.OrtSession session) async {
    // TODO: Implement real preprocessing (resize, normalize, transpose) and inference
    // final onnxValue = onnx.TensorElementDataFloat.fromList(preprocessed);
    // final outputs = await session.run(inputs: {'input': onnxValue});
    // Extract Float32List from outputs
    return Float32List(0);
  }
}


