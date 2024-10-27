// lib/widgets/build_stock_section.dart
import 'package:flutter/material.dart';
import 'package:stockstalk/components/stock_card.dart';
import 'package:stockstalk/models/stock.dart'; // Stock 모델 import

class BuildStockSection extends StatelessWidget {
  const BuildStockSection({
    super.key,
    required this.title,
    required this.stockData,
  });

  final String title;
  final List<Stock> stockData; // List<dynamic>에서 List<Stock>으로 변경

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stockData.length,
            itemBuilder: (context, index) {
              return StockCard(
                stock: stockData[index],
                index: index,
              );
            },
          ),
        ],
      ),
    );
  }
}
