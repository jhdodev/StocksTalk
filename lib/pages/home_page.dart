import 'dart:convert'; // JSON 파싱을 위한 import
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart'; // NumberFormat을 사용하기 위한 import

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> stockDataFltRt = [];
  List<dynamic> stockDataTrPrc = [];
  bool isLoading = true; // 데이터를 로드 중인지 여부

  // API 호출 함수 (등락률 20% 이상 종목 조회)
  Future<void> fetchStockDataFltRt() async {
    final String apiKey = dotenv.env['API_KEY'] ?? ''; // .env 파일에서 API_KEY를 가져옴

    const String baseUrl =
        'https://apis.data.go.kr/1160100/service/GetStockSecuritiesInfoService/getStockPriceInfo';
    final String apiUrl =
        '$baseUrl?serviceKey=$apiKey&numOfRows=10&beginFltRt=20&resultType=json';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final parsedData = json.decode(response.body);

        setState(() {
          stockDataFltRt = (parsedData['response']['body']['items']['item']
                  as List<dynamic>)
              .where((item) => item['fltRt'] != null)
              .toList()
            ..sort((a, b) => double.parse(b['fltRt'].toString())
                .compareTo(double.parse(a['fltRt'].toString())));

          isLoading = false;
        });
      } else {
        throw Exception('Failed to load stock data');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // API 호출 함수 (거래대금 상위 종목 조회)
  Future<void> fetchStockDataTrPrc() async {
    final String apiKey = dotenv.env['API_KEY'] ?? '';

    const String baseUrl =
        'https://apis.data.go.kr/1160100/service/GetStockSecuritiesInfoService/getStockPriceInfo';
    final String apiUrl =
        '$baseUrl?serviceKey=$apiKey&numOfRows=10&resultType=json&beginTrPrc=1000000000'; // 거래대금 10억 이상

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final parsedData = json.decode(response.body);

        setState(() {
          stockDataTrPrc = (parsedData['response']['body']['items']['item']
                  as List<dynamic>)
              .where((item) => item['trPrc'] != null)
              .toList()
            ..sort((a, b) => double.parse(b['trPrc'].toString())
                .compareTo(double.parse(a['trPrc'].toString())));

          isLoading = false;
        });
      } else {
        throw Exception('Failed to load stock data');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchStockDataFltRt(); // 등락률 상위 데이터 호출
    fetchStockDataTrPrc(); // 거래대금 상위 데이터 호출
  }

  // 숫자 형식 변환 함수 (소수점 2자리 고정)
  String formatNumber(String number, {int decimalDigits = 0}) {
    final double? parsedNumber = double.tryParse(number);
    if (parsedNumber != null) {
      // 정수인 경우 소수점 표시하지 않도록 처리
      if (parsedNumber == parsedNumber.roundToDouble()) {
        return NumberFormat('#,###', 'en_US').format(parsedNumber);
      }
      return NumberFormat('###,###,##0.${'0' * decimalDigits}', 'en_US')
          .format(parsedNumber);
    }
    return number;
  }

  // 수정된 buildStockCard 함수
  Widget buildStockCard(Map<String, dynamic> stock, int index) {
    // 주식 정보
    final String stockName = stock['itmsNm']?.toString() ?? 'Unknown Stock';
    final String price =
        formatNumber(stock['clpr']?.toString() ?? '0'); // 가격은 쉼표 구분만
    final String changePrice =
        formatNumber(stock['vs']?.toString() ?? '0'); // 등락폭은 쉼표 구분만, 소수점 없앰
    final String changeRate = formatNumber(stock['fltRt']?.toString() ?? '0',
        decimalDigits: 2); // 등락률은 소수점 2자리
    final String trPrc =
        formatNumber(stock['trPrc']?.toString() ?? '0'); // 거래대금은 쉼표 구분만

    // 상승/하락 판단 및 색상/아이콘 설정
    final double? parsedChangePrice =
        double.tryParse(changePrice.replaceAll(',', '')); // 쉼표 제거 후 숫자 변환
    final bool isRising = parsedChangePrice != null && parsedChangePrice > 0;
    final Color changeColor = isRising ? Colors.red : Colors.blue;
    final String icon = isRising ? '▲' : '▼';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${index + 1}. $stockName',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('가격: $price원', style: const TextStyle(fontSize: 14)),
            Row(
              children: [
                Text(
                  icon,
                  style: TextStyle(color: changeColor, fontSize: 14),
                ),
                Text(
                  '$changePrice $changeRate%',
                  style: TextStyle(color: changeColor, fontSize: 14),
                ),
              ],
            ),
            Text('거래대금: $trPrc원', style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('종목 데이터'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // 등락률 상위 종목 섹션
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '등락률 상위 종목',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: stockDataFltRt.length,
                          itemBuilder: (context, index) {
                            final stock = stockDataFltRt[index];
                            return buildStockCard(stock, index);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 거래대금 상위 종목 섹션
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '거래대금 상위 종목',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: stockDataTrPrc.length,
                          itemBuilder: (context, index) {
                            final stock = stockDataTrPrc[index];
                            return buildStockCard(stock, index);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
