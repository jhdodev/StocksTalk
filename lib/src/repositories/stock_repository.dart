// lib/repositories/stock_repository.dart
import '../models/stock.dart';
import '../services/stock_service.dart';

abstract class StockRepository {
  Future<List<Stock>> getTopChangeRateStocks();
  Future<List<Stock>> getTopTradingStocks();
  // 여기에 searchStocks 메소드 시그니처 추가
  Future<List<Stock>> searchStocks({String? keyword, String? marketType});
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

  @override
  // 여기에 searchStocks 구현 추가
  Future<List<Stock>> searchStocks(
      {String? keyword, String? marketType}) async {
    try {
      final data = await _stockService.searchStocks(
        likeItmsNm: keyword,
        mrktCtg: marketType,
      );
      return data.map((item) => Stock.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to search stocks: $e');
    }
  }
}
