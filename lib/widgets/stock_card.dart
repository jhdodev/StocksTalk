import 'package:flutter/material.dart';
import 'package:stockstalk/utils/format_number.dart';

class StockCard extends StatelessWidget {
  final Map<String, dynamic> stock;
  final int index;

  const StockCard({super.key, required this.stock, required this.index});

  @override
  Widget build(BuildContext context) {
    final String stockName = stock['itmsNm']?.toString() ?? 'Unknown Stock';
    final String price = formatNumber(stock['clpr']?.toString() ?? '0');
    final String changePrice = formatNumber(stock['vs']?.toString() ?? '0');
    final String changeRate =
        formatNumber(stock['fltRt']?.toString() ?? '0', decimalDigits: 2);
    final String trPrc = formatNumber(stock['trPrc']?.toString() ?? '0');

    final double? parsedChangePrice =
        double.tryParse(changePrice.replaceAll(',', ''));
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
}
