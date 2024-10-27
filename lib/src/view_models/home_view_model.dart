// lib/view_models/home_view_model.dart
import 'package:flutter/foundation.dart';
import 'package:stockstalk/src/repositories/stock_repository.dart';
import '../models/stock.dart';

class HomeViewModel extends ChangeNotifier {
  final StockRepository _repository;

  HomeViewModel(this._repository); // 생성자 추가

  List<Stock> _topChangeRateStocks = [];
  List<Stock> _topTradingStocks = [];
  bool _isLoading = false;
  String? _error;

  // Getters는 그대로 유지
  List<Stock> get topChangeRateStocks => _topChangeRateStocks;
  List<Stock> get topTradingStocks => _topTradingStocks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchStockData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _topChangeRateStocks = await _repository.getTopChangeRateStocks();
      _topTradingStocks = await _repository.getTopTradingStocks();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
