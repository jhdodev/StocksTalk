// lib/views/widgets/stock_card.dart
import 'package:flutter/material.dart';
import 'package:stockstalk/models/stock.dart';
import 'package:stockstalk/utils/format_number.dart';

class StockCard extends StatelessWidget {
  final Stock stock;
  final int index;

  const StockCard({
    required this.stock,
    required this.index,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Color changeColor = stock.isRising ? Colors.red : Colors.blue;
    final String icon = stock.isRising ? '▲' : '▼';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${index + 1}. ${stock.name}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('가격: ${formatNumber(stock.price)}원',
                style: const TextStyle(fontSize: 14)),
            Row(
              children: [
                Text(
                  icon,
                  style: TextStyle(color: changeColor, fontSize: 14),
                ),
                Text(
                  '${formatNumber(stock.changePrice)} ${formatNumber(stock.changeRate, decimalDigits: 2)}%',
                  style: TextStyle(color: changeColor, fontSize: 14),
                ),
              ],
            ),
            Text('거래대금: ${formatNumber(stock.tradingVolume)}원',
                style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
