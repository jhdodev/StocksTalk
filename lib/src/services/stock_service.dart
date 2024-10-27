// lib/services/stock_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StockService {
  final String apiKey = dotenv.env['API_KEY'] ?? '';
  final String baseUrl =
      'https://apis.data.go.kr/1160100/service/GetStockSecuritiesInfoService/getStockPriceInfo';

// lib/services/stock_service.dart
  Future<List<dynamic>> searchStocks({
    String? likeItmsNm,
    String? mrktCtg,
  }) async {
    try {
      if (likeItmsNm?.isEmpty ?? true) return [];

      final String apiUrl =
          'https://apis.data.go.kr/1160100/service/GetStockSecuritiesInfoService/getStockPriceInfo'
          '?serviceKey=$apiKey'
          '&numOfRows=100' // 충분한 데이터를 가져오기 위해 증가
          '&resultType=json';

      String fullUrl = apiUrl;
      if (likeItmsNm != null) {
        fullUrl += '&likeItmsNm=$likeItmsNm';
      }
      if (mrktCtg != null && mrktCtg != '전체') {
        fullUrl += '&mrktCtg=$mrktCtg';
      }

      final response = await http.get(Uri.parse(fullUrl));

      if (response.statusCode == 200) {
        final parsedData = json.decode(response.body);

        // response가 비어있는 경우 체크
        if (parsedData['response']['body']['items'] == '') {
          return [];
        }

        final items = parsedData['response']['body']['items']['item'];

        // items가 List가 아닌 경우(단일 항목인 경우) 처리
        if (items is! List) {
          return [items];
        }

        // 종목별로 가장 최근 데이터만 필터링
        final Map<String, dynamic> latestData = {};
        for (var item in items) {
          final String itmsNm = item['itmsNm']; // 종목명
          final String basDt = item['basDt']; // 기준일자

          if (!latestData.containsKey(itmsNm) ||
              latestData[itmsNm]['basDt'].compareTo(basDt) < 0) {
            latestData[itmsNm] = item;
          }
        }

        return latestData.values.toList();
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load stock data');
      }
    } catch (e) {
      print('Error in searchStocks: $e');
      return [];
    }
  }

  Future<List<dynamic>> fetchStockDataFltRt() async {
    final String apiUrl =
        '$baseUrl?serviceKey=$apiKey&numOfRows=10&beginFltRt=20&resultType=json';
    return _fetchData(apiUrl, 'fltRt');
  }

  Future<List<dynamic>> fetchStockDataTrPrc() async {
    final String apiUrl =
        '$baseUrl?serviceKey=$apiKey&numOfRows=10&resultType=json&beginTrPrc=1000000000';
    return _fetchData(apiUrl, 'trPrc');
  }

  Future<List<dynamic>> _fetchData(String apiUrl, String sortKey) async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final parsedData = json.decode(response.body);
        final List<dynamic> items =
            parsedData['response']['body']['items']['item'];

        return items.where((item) => item[sortKey] != null).toList()
          ..sort((a, b) => double.parse(b[sortKey].toString())
              .compareTo(double.parse(a[sortKey].toString())));
      } else {
        throw Exception('Failed to load stock data');
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }
}
