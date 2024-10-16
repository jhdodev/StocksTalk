import 'package:flutter/material.dart';
import 'package:stockstalk/services/stock_service.dart';
import 'package:stockstalk/widgets/build_stock_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final StockService _stockService = StockService();
  List<dynamic> stockDataFltRt = [];
  List<dynamic> stockDataTrPrc = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final fltRtData = await _stockService.fetchStockDataFltRt();
      final trPrcData = await _stockService.fetchStockDataTrPrc();
      setState(() {
        stockDataFltRt = fltRtData;
        stockDataTrPrc = trPrcData;
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
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
                  BuildStockSection(
                      title: '등락률 상위 종목', stockData: stockDataFltRt),
                  const SizedBox(height: 20),
                  BuildStockSection(
                      title: '거래대금 상위 종목', stockData: stockDataTrPrc),
                ],
              ),
            ),
    );
  }
}
