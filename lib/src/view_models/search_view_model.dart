// lib/view_models/search_view_model.dart
import 'package:flutter/foundation.dart';
import '../repositories/stock_repository.dart';
import '../models/stock.dart';

class SearchViewModel extends ChangeNotifier {
  final StockRepository _repository;

  SearchViewModel(this._repository);

  List<Stock> _searchResults = [];
  bool _isLoading = false;
  String? _error;

  List<Stock> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> searchStocks({
    String? keyword,
    String? marketType,
  }) async {
    if (keyword?.isEmpty ?? true) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _searchResults = await _repository.searchStocks(
        keyword: keyword,
        marketType: marketType,
      );
    } catch (e) {
      _error = e.toString();
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
