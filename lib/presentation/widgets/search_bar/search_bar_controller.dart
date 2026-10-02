import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class SearchableListController<T> extends ChangeNotifier {
  final PagingController<int, T> _pagingController;
  bool _isSearching = false;

  SearchableListController({required PagingController<int, T> pagingController})
    : _pagingController = pagingController;

  bool get isSearching => _isSearching;
  PagingController<int, T> get pagingController => _pagingController;

  void startSearch() {
    if (!_isSearching) {
      _isSearching = true;
      notifyListeners();
    }
  }

  void endSearch() {
    if (_isSearching) {
      _isSearching = false;
      notifyListeners();
    }
  }

  void refresh() {
    _pagingController.refresh();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
