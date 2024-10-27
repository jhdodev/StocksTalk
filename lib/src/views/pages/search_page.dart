// lib/pages/search_page.dart
import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('종목검색'),
      ),
      body: const Center(
        child: Text('종목검색 페이지'),
      ),
    );
  }
}
