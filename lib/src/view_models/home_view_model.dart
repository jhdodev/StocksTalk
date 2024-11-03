// lib/view_models/home_view_model.dart
import 'package:flutter/foundation.dart';
import 'package:stockstalk/src/repositories/stock_repository.dart';
import '../models/stock.dart';

class HomeViewModel extends ChangeNotifier {
  final StockRepository _repository;
  bool _hasLoadedOnce = false; // 추가

  HomeViewModel(this._repository);

  List<Stock> _topChangeRateStocks = [];
  List<Stock> _topTradingStocks = [];
  bool _isLoading = false;
  String? _error;

  List<Stock> get topChangeRateStocks => _topChangeRateStocks;
  List<Stock> get topTradingStocks => _topTradingStocks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchStockData() async {
    if (_hasLoadedOnce) return; // 이미 로드된 경우 스킵

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _topChangeRateStocks = await _repository.getTopChangeRateStocks();
      _topTradingStocks = await _repository.getTopTradingStocks();
      _hasLoadedOnce = true; // 로드 완료 표시
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 수동 새로고침용 메서드 추가
  Future<void> refreshStockData() async {
    _hasLoadedOnce = false;
    await fetchStockData();
  }
}
