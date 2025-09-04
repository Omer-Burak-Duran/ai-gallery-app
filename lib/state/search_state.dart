import 'package:flutter/foundation.dart';

/// Holds search query and results ids for UI binding.
class SearchState extends ChangeNotifier {
  String _query = '';
  List<String> _resultPhotoIds = <String>[];

  String get query => _query;
  List<String> get resultPhotoIds => List.unmodifiable(_resultPhotoIds);

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setResults(List<String> ids) {
    _resultPhotoIds = ids;
    notifyListeners();
  }
}


