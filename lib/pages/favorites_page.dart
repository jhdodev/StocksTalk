// lib/pages/favorites_page.dart
import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('관심종목'),
      ),
      body: const Center(
        child: Text('관심종목 페이지'),
      ),
    );
  }
}
