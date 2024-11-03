// lib/views/pages/search_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/search_view_model.dart';
import '../../view_models/favorites_view_model.dart';
import '../widgets/stock_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedMarket = '전체';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('종목검색'),
      ),
      body: Column(
        children: [
          // 검색 필터 영역
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 검색창
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '종목명을 입력하세요',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context.read<SearchViewModel>().searchStocks();
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSubmitted: (value) {
                    context.read<SearchViewModel>().searchStocks(
                          keyword: value,
                          marketType:
                              _selectedMarket == '전체' ? null : _selectedMarket,
                        );
                  },
                ),
                const SizedBox(height: 8),

                // 시장 구분 필터
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final market in ['전체', 'KOSPI', 'KOSDAQ', 'KONEX'])
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(market),
                            selected: _selectedMarket == market,
                            onSelected: (selected) {
                              setState(() {
                                _selectedMarket = market;
                              });
                              // 필터 변경 시 즉시 검색
                              context.read<SearchViewModel>().searchStocks(
                                    keyword: _searchController.text,
                                    marketType: market == '전체' ? null : market,
                                  );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 검색 결과 영역
          Expanded(
            child: Consumer2<SearchViewModel, FavoritesViewModel>(
              builder: (context, searchViewModel, favoritesViewModel, child) {
                if (searchViewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (searchViewModel.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '오류가 발생했습니다\n${searchViewModel.error}',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => searchViewModel.searchStocks(
                            keyword: _searchController.text,
                            marketType: _selectedMarket == '전체'
                                ? null
                                : _selectedMarket,
                          ),
                          child: const Text('다시 시도'),
                        ),
                      ],
                    ),
                  );
                }

                if (searchViewModel.searchResults.isEmpty) {
                  return const Center(
                    child: Text('검색 결과가 없습니다'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: searchViewModel.searchResults.length,
                  itemBuilder: (context, index) {
                    final stock = searchViewModel.searchResults[index];
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
          ),
        ],
      ),
    );
  }
}
