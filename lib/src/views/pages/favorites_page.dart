// lib/views/pages/favorites_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/favorites_view_model.dart';
import '../widgets/stock_card.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('관심종목'),
      ),
      body: Consumer<FavoritesViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(child: Text('Error: ${viewModel.error}'));
          }

          if (viewModel.favorites.isEmpty) {
            return const Center(
              child: Text('관심종목이 없습니다.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: viewModel.favorites.length,
            itemBuilder: (context, index) {
              final stock = viewModel.favorites[index];
              return StockCard(
                stock: stock,
                index: index,
                isFavorite: true,
                onFavoritePressed: viewModel.toggleFavorite,
              );
            },
          );
        },
      ),
    );
  }
}
