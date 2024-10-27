// lib/views/widgets/build_stock_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/stock.dart';
import '../../view_models/favorites_view_model.dart';
import 'stock_card.dart';

class BuildStockSection extends StatelessWidget {
  const BuildStockSection({
    super.key,
    required this.title,
    required this.stockData,
  });

  final String title;
  final List<Stock> stockData;

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
              final stock = stockData[index];
              return Consumer<FavoritesViewModel>(
                builder: (context, favoritesViewModel, _) {
                  return StockCard(
                    stock: stock,
                    index: index,
                    isFavorite: favoritesViewModel.isFavorite(stock.srtnCd),
                    onFavoritePressed: favoritesViewModel.toggleFavorite,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
