import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StockService {
  final String apiKey = dotenv.env['API_KEY'] ?? '';
  final String baseUrl =
      'https://apis.data.go.kr/1160100/service/GetStockSecuritiesInfoService/getStockPriceInfo';

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
