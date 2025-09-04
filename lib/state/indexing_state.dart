import 'package:flutter/foundation.dart';

/// Tracks indexing progress and state across the app.
class IndexingState extends ChangeNotifier {
  bool _isIndexing = false;
  int _indexedCount = 0;
  int _totalToIndex = 0;

  bool get isIndexing => _isIndexing;
  int get indexedCount => _indexedCount;
  int get totalToIndex => _totalToIndex;

  double get progress => _totalToIndex == 0 ? 0 : _indexedCount / _totalToIndex;

  void start(int total) {
    _isIndexing = true;
    _totalToIndex = total;
    _indexedCount = 0;
    notifyListeners();
  }

  void increment() {
    _indexedCount += 1;
    notifyListeners();
  }

  void complete() {
    _isIndexing = false;
    notifyListeners();
  }
}


