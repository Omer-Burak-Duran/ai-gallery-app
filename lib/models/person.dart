import 'package:flutter/foundation.dart';

/// Represents a person label, potentially associated with multiple faces.
@immutable
class Person {
  final String personId; // UUID for the person
  final String name; // User-defined label
  final DateTime createdAt;

  const Person({
    required this.personId,
    required this.name,
    required this.createdAt,
  });
}


