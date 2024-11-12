// lib/views/widgets/stock_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:stockstalk/src/models/stock.dart';
import 'package:stockstalk/src/utils/format_number.dart';
import 'package:stockstalk/src/views/pages/stock_chat_room_page.dart';

class StockCard extends StatelessWidget {
  final Stock stock;
  final int index;
  final bool isFavorite; // 추가
  final Function(Stock) onFavoritePressed; // 추가

  const StockCard({
    super.key,
    required this.stock,
    required this.index,
    required this.isFavorite,
    required this.onFavoritePressed,
  });

  @override
  Widget build(BuildContext context) {
    final Color changeColor = stock.isRising ? Colors.red : Colors.blue;
    final String icon = stock.isRising ? '▲' : '▼';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${index + 1}. ${stock.name}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
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
                const SizedBox(height: 8),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: isFavorite ? Colors.amber : Colors.grey,
              ),
              onPressed: () => onFavoritePressed(stock),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StockChatRoomPage(stock: stock),
                  ),
                );
              },
              icon: const Icon(CupertinoIcons.chat_bubble_2_fill),
              label: const Text('종목토론'),
            ),
          ),
        ],
      ),
    );
  }
}
