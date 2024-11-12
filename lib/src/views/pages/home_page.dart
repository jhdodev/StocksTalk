// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockstalk/src/views/widgets/build_stock_section.dart';
import 'package:stockstalk/src/view_models/home_view_model.dart';

//깃 테스트용 주석
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isFirstLoad = true; // 첫 로딩 여부를 체크하는 플래그 추가

  @override
  void initState() {
    super.initState();
    // 약간의 딜레이를 주어 빌드 프로세스가 완료된 후 실행되도록 함
    Future.microtask(() {
      context.read<HomeViewModel>().fetchStockData();
    });
  }

  Future<void> _fetchData() async {
    try {
      final homeViewModel = context.read<HomeViewModel>();
      setState(() {
        _isFirstLoad = false; // 데이터 로딩 후 플래그 false로 변경
      });
      await homeViewModel.fetchStockData();
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('종목 데이터'),
      ),
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, _) {
          if (_isFirstLoad && viewModel.isLoading) {
            // 첫 로딩일 때만 인디케이터 표시
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                BuildStockSection(
                  title: '등락률 상위 종목',
                  stockData: viewModel.topChangeRateStocks,
                ),
                const SizedBox(height: 20),
                BuildStockSection(
                  title: '거래대금 상위 종목',
                  stockData: viewModel.topTradingStocks,
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: context.read<HomeViewModel>().refreshStockData,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
