// lib/view_models/favorites_view_model.dart
import 'package:flutter/foundation.dart';
import '../models/stock.dart';
import '../repositories/favorites_repository.dart';

class FavoritesViewModel extends ChangeNotifier {
  final FavoritesRepository _repository;
  final Map<String, Stock> _favorites = {}; // srtnCd를 키로 사용
  bool _isLoading = false;
  String? _error;

  FavoritesViewModel(this._repository) {
    _loadFavorites();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Stock> get favorites => _favorites.values.toList();

  void _loadFavorites() {
    _repository.getFavorites().listen(
      (stocks) {
        for (var stock in stocks) {
          _favorites[stock.srtnCd] = stock;
        }
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  bool isFavorite(String stockCode) {
    return _favorites.containsKey(stockCode);
  }

  Future<void> toggleFavorite(Stock stock) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (isFavorite(stock.srtnCd)) {
        await _repository.removeFavorite(stock);
        _favorites.remove(stock.srtnCd);
      } else {
        await _repository.addFavorite(stock);
        _favorites[stock.srtnCd] = stock;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
