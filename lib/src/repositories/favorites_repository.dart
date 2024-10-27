// lib/src/repositories/favorites_repository.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/stock.dart';

abstract class FavoritesRepository {
  Future<void> addFavorite(Stock stock);
  Future<void> removeFavorite(Stock stock);
  Stream<List<Stock>> getFavorites();
  Future<bool> isFavorite(String stockCode);
}

class FirebaseFavoritesRepository implements FavoritesRepository {
  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  DatabaseReference _getUserFavoritesRef() {
    if (userId == null) {
      throw Exception('User not logged in');
    }
    return FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(userId!)
        .child('favorites');
  }

  @override
  Future<void> addFavorite(Stock stock) async {
    await _getUserFavoritesRef().child(stock.srtnCd).set(stock.toJson());
  }

  @override
  Future<void> removeFavorite(Stock stock) async {
    await _getUserFavoritesRef().child(stock.srtnCd).remove();
  }

  @override
  Stream<List<Stock>> getFavorites() {
    if (userId == null) {
      return Stream.value([]);
    }

    return _getUserFavoritesRef().onValue.map((event) {
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
    if (userId == null) return false;

    final snapshot = await _getUserFavoritesRef().child(stockCode).get();
    return snapshot.exists;
  }
}
