// lib/repositories/stock_repository.dart
import '../models/stock.dart';
import '../services/stock_service.dart';

abstract class StockRepository {
  Future<List<Stock>> getTopChangeRateStocks();
  Future<List<Stock>> getTopTradingStocks();
}

class StockRepositoryImpl implements StockRepository {
  final StockService _stockService;

  StockRepositoryImpl(this._stockService);

  @override
  Future<List<Stock>> getTopChangeRateStocks() async {
    final data = await _stockService.fetchStockDataFltRt();
    return data.map((item) => Stock.fromJson(item)).toList();
  }

  @override
  Future<List<Stock>> getTopTradingStocks() async {
    final data = await _stockService.fetchStockDataTrPrc();
    return data.map((item) => Stock.fromJson(item)).toList();
  }
}
