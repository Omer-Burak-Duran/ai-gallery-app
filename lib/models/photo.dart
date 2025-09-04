import 'package:flutter/foundation.dart';

/// Represents a photo asset in the user's library.
@immutable
class Photo {
  final String id; // Asset ID from photo_manager or generated UUID
  final String uri; // Platform-specific URI/path reference
  final int width;
  final int height;
  final DateTime? timestamp;
  final double? latitude;
  final double? longitude;
  final int? dominantColorArgb;
  final bool isScreenshot;
  final bool isIndexed; // Has this photo been processed by the indexer

  const Photo({
    required this.id,
    required this.uri,
    required this.width,
    required this.height,
    this.timestamp,
    this.latitude,
    this.longitude,
    this.dominantColorArgb,
    this.isScreenshot = false,
    this.isIndexed = false,
  });

  Photo copyWith({
    String? id,
    String? uri,
    int? width,
    int? height,
    DateTime? timestamp,
    double? latitude,
    double? longitude,
    int? dominantColorArgb,
    bool? isScreenshot,
    bool? isIndexed,
  }) {
    return Photo(
      id: id ?? this.id,
      uri: uri ?? this.uri,
      width: width ?? this.width,
      height: height ?? this.height,
      timestamp: timestamp ?? this.timestamp,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      dominantColorArgb: dominantColorArgb ?? this.dominantColorArgb,
      isScreenshot: isScreenshot ?? this.isScreenshot,
      isIndexed: isIndexed ?? this.isIndexed,
    );
  }
}


