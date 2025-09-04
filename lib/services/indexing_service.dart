// ignore_for_file: avoid_print, unused_local_variable, dead_code
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:onnxruntime/onnxruntime.dart' as onnx;
import 'package:photo_manager/photo_manager.dart';
import 'package:workmanager/workmanager.dart';

// import 'db_service.dart';

/// Coordinates background indexing of photos.
class IndexingService {
  static const String taskName = 'indexPhotosTask';

  // final DBService _dbService = DBService();

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
      // TODO: Load ONNX models from assets using onnxruntime APIs
      // Example (pseudo-code):
      // final imageModelBytes = await rootBundle.load('assets/models/clip_image.onnx');
      // clipImageSession = await onnx.OrtSession.fromBuffer(imageModelBytes.buffer);
      // final faceModelBytes = await rootBundle.load('assets/models/face_recognition.onnx');
      // faceEmbedSession = await onnx.OrtSession.fromBuffer(faceModelBytes.buffer);

      for (final asset in assets) {
        // 4) Retrieve downsized image bytes for faster processing
        final thumb = await asset.thumbnailDataWithSize(const ThumbnailSize(256, 256));
        if (thumb == null) continue;

        // TODO: Insert photo metadata row if not exists
        // await _insertOrUpdatePhoto(asset, thumb);

        // 5) Compute global image embedding with CLIP image encoder
        // TODO: Preprocess image -> tensor and run inference using clipImageSession
        // final Float32List imageEmbedding = await _computeImageEmbedding(thumb, clipImageSession);
        // TODO: store embedding in photo_embeddings

        // 6) Face detection
        final file = await asset.file;
        if (file == null) continue;
        final faces = await faceDetector.processImage(InputImage.fromFilePath(file.path));
        for (final face in faces) {
          // TODO: crop face region from original image or thumbnail
          // final Uint8List faceCrop = _cropFace(thumb, f.boundingBox);
          // TODO: run face embedding model and store 512-D descriptor
          // final Float32List faceEmbedding = await _computeFaceEmbedding(faceCrop, faceEmbedSession);
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
}


