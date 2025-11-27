import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/item.dart';

class StorageService {
  static const _userKey = 'username';
  static const _favoritesKey = 'favorites';

  static Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, username);
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKey);
  }

  static Future<void> clearUsername() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
  static Future<List<Item>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_favoritesKey) ?? <String>[];
    return list.map((s) {
      final m = json.decode(s) as Map<String, dynamic>;
      return Item.fromJson(m, m['menu'] ?? 'restaurant');
    }).toList();
  }

  static Future<void> addFavorite(Item item) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_favoritesKey) ?? <String>[];
    final encoded = json.encode(item.toJson());
    if (!list.contains(encoded)) {
      list.add(encoded);
      await prefs.setStringList(_favoritesKey, list);
    }
  }

  static Future<void> removeFavorite(String id, String menu) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_favoritesKey) ?? <String>[];
    list.removeWhere((s) {
      final m = json.decode(s) as Map<String, dynamic>;
      final mid = m['id']?.toString() ?? '';
      final mmenu = m['menu'] ?? 'restaurant';
      return mid == id && mmenu == menu;
    });
    await prefs.setStringList(_favoritesKey, list);
  }

  static Future<bool> isFavorite(String id, String menu) async {
    final fav = await getFavorites();
    return fav.any((f) => f.id == id && f.menu == menu);
  }
}
