import 'package:flutter/foundation.dart';

/// Represents a detected face within a photo.
@immutable
class Face {
  final String faceId; // UUID for the face
  final String photoId; // Foreign key to Photo.id
  final double boundingBoxLeft;
  final double boundingBoxTop;
  final double boundingBoxRight;
  final double boundingBoxBottom;
  final Map<String, double>? landmarks; // e.g., {"leftEyeX": ..., "leftEyeY": ...}

  const Face({
    required this.faceId,
    required this.photoId,
    required this.boundingBoxLeft,
    required this.boundingBoxTop,
    required this.boundingBoxRight,
    required this.boundingBoxBottom,
    this.landmarks,
  });
}


