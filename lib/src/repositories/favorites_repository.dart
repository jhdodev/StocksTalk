// lib/repositories/favorites_repository.dart
import 'package:firebase_database/firebase_database.dart';
import '../models/stock.dart';

abstract class FavoritesRepository {
  Future<void> addFavorite(Stock stock);
  Future<void> removeFavorite(Stock stock);
  Stream<List<Stock>> getFavorites();
  Future<bool> isFavorite(String stockCode);
}

class FirebaseFavoritesRepository implements FavoritesRepository {
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref().child('favorites');

  @override
  Future<void> addFavorite(Stock stock) async {
    await _database.child(stock.srtnCd).set(stock.toJson());
  }

  @override
  Future<void> removeFavorite(Stock stock) async {
    await _database.child(stock.srtnCd).remove();
  }

  @override
  Stream<List<Stock>> getFavorites() {
    return _database.onValue.map((event) {
      final dataSnapshot = event.snapshot;
      if (!dataSnapshot.exists || dataSnapshot.value == null) {
        return [];
      }

      try {
        final Map<dynamic, dynamic> data = dataSnapshot.value as Map;
        return data.values
            .map((value) =>
                Stock.fromJson(Map<String, dynamic>.from(value as Map)))
            .toList();
      } catch (e) {
        print('Error parsing favorites data: $e');
        return [];
      }
    });
  }

  @override
  Future<bool> isFavorite(String stockCode) async {
    final snapshot = await _database.child(stockCode).get();
    return snapshot.exists;
  }
}
