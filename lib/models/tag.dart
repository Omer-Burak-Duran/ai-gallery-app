import 'package:flutter/foundation.dart';

/// Represents a user-defined tag that can be attached to photos.
@immutable
class Tag {
  final String tagId; // UUID for the tag
  final String label;
  final DateTime createdAt;

  const Tag({
    required this.tagId,
    required this.label,
    required this.createdAt,
  });
}


