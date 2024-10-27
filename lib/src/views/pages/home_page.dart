// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockstalk/components/build_stock_section.dart';
import 'package:stockstalk/view_models/home_view_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // 데이터 로드
    Future.microtask(() =>
        Provider.of<HomeViewModel>(context, listen: false).fetchStockData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('종목 데이터')),
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(child: Text('Error: ${viewModel.error}'));
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
    );
  }
}
