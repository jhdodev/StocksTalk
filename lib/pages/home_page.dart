import 'dart:convert'; // JSON 파싱을 위한 import
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> stockData = [];
  bool isLoading = true; // 데이터를 로드 중인지 여부

  // API 호출 함수
  Future<void> fetchStockData() async {
    final String apiKey = dotenv.env['API_KEY'] ?? ''; // .env 파일에서 API_KEY를 가져옴

    const String baseUrl =
        'https://apis.data.go.kr/1160100/service/GetStockSecuritiesInfoService/getStockPriceInfo';
    final String apiUrl =
        '$baseUrl?serviceKey=$apiKey&numOfRows=10&resultType=json';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // API 응답을 JSON으로 변환
        final parsedData = json.decode(response.body);

        // 필요한 데이터 추출
        setState(() {
          stockData = parsedData['response']['body']['items']
              ['item']; // 실제 데이터 경로는 API 구조에 따라 다를 수 있음
          isLoading = false; // 데이터 로딩 완료
        });
      } else {
        throw Exception('Failed to load stock data');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false; // 오류 발생 시 로딩 중지
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchStockData(); // 페이지가 로드될 때 API 호출
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('홈'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // 데이터가 로딩 중일 때 표시
          : stockData.isEmpty
              ? const Center(child: Text('데이터를 불러올 수 없습니다.'))
              : ListView.builder(
                  itemCount: stockData.length,
                  itemBuilder: (context, index) {
                    final stock = stockData[index];

                    // 주식 정보
                    final String stockName =
                        stock['itmsNm'] ?? 'Unknown Stock'; // 종목명
                    final String price = stock['clpr'] ?? '0'; // 현재 가격
                    final String changePrice = stock['vs'] ?? '0'; // 등락폭
                    final String changeRate = stock['fltRt'] ?? '0'; // 등락률

                    // 상승/하락률이 양수인지 음수인지에 따라 텍스트 색상 변경
                    final double? parsedChangePrice =
                        double.tryParse(changePrice);
                    final Color changeColor =
                        (parsedChangePrice != null && parsedChangePrice > 0)
                            ? Colors.red // 상승: 빨간색
                            : Colors.blue; // 하락: 파란색

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stockName,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ), // 예: 주식 이름
                            const SizedBox(height: 8),
                            Text(
                              '$price원', // 예: 주식 가격
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  '($changePrice, ',
                                  style: TextStyle(color: changeColor),
                                ),
                                Text(
                                  '$changeRate%)',
                                  style: TextStyle(color: changeColor),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
