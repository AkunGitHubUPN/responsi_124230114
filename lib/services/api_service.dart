import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/item.dart';

class ApiService {
  static const _base = 'https://restaurant-api.dicoding.dev';  static Future<List<Item>> fetchList(String menu) async {
    final url = Uri.parse('$_base/list');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      if (data is Map && data['restaurants'] is List) {
        final restaurants = (data['restaurants'] as List);
        
        // Debug: Print first restaurant JSON
        if (restaurants.isNotEmpty) {
          print('\n=== DEBUG: First Restaurant JSON ===');
          print('Raw JSON: ${restaurants[0]}');
          print('Keys: ${(restaurants[0] as Map).keys.toList()}');
        }
        
        return restaurants
            .map<Item>((e) => Item.fromJson(e as Map<String, dynamic>, 'restaurants'))
            .toList();
      }
    }
    throw Exception('Failed to load restaurants');
  }

  static Future<List<Item>> searchRestaurants(String query) async {
    final url = Uri.parse('$_base/search?q=$query');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      if (data is Map && data['restaurants'] is List) {
        return (data['restaurants'] as List)
            .map<Item>((e) => Item.fromJson(e as Map<String, dynamic>, 'restaurants'))
            .toList();
      }
    }
    throw Exception('Failed to search restaurants');
  }  static Future<List<String>> fetchCategories() async {
    try {
      print('Attempting to fetch categories from /categories endpoint');
      final url = Uri.parse('$_base/categories');
      print('Fetching categories from: $url');
      final resp = await http.get(url);
      print('Categories response status: ${resp.statusCode}');
      print('Categories response body: ${resp.body}');
      
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        print('Parsed categories data: $data');
        
        if (data is Map && data['categories'] is List) {
          final categories = (data['categories'] as List)
              .map<String>((e) => e is Map ? e['name']?.toString() ?? '' : '')
              .where((e) => e.isNotEmpty)
              .toList();
          print('Categories extracted: $categories');
          return ['All', ...categories];
        }
      }
      print('Categories endpoint did not return expected structure');
    } catch (e) {
      print('Categories endpoint error: $e');
    }
    
    // Fallback: Extract categories (cities) from restaurant list
    print('\n--- Falling back to extract categories from restaurant list ---');
    try {
      print('Fetching restaurants to extract categories (cities)...');
      final restaurants = await fetchList('restaurants');
      print('Fetched ${restaurants.length} restaurants for category extraction');
      
      final categoriesSet = <String>{};
      for (var restaurant in restaurants) {
        // Extract city as category
        if (restaurant.city != null && restaurant.city!.isNotEmpty) {
          print('Restaurant "${restaurant.title}" city: ${restaurant.city}');
          categoriesSet.add(restaurant.city!);
        }
        // Also use restaurant categories if they exist
        if (restaurant.categories.isNotEmpty) {
          print('Restaurant "${restaurant.title}" categories: ${restaurant.categories}');
          categoriesSet.addAll(restaurant.categories);
        }
      }
      
      final categories = categoriesSet.toList()..sort();
      print('Final extracted categories: $categories');
      
      if (categories.isNotEmpty) {
        final result = ['All', ...categories];
        print('Returning categories: $result');
        return result;
      }
    } catch (e) {
      print('Failed to extract categories from restaurants: $e');
    }
    
    print('\nReturning default ["All"] category');
    return ['All'];
  }

  static Future<Item> fetchDetail(String id) async {
    final url = Uri.parse('https://restaurant-api.dicoding.dev/detail/$id');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      if (data is Map && data['restaurant'] is Map) {
        return Item.fromJson(data['restaurant'] as Map<String, dynamic>, 'restaurant');
      }
    }
    throw Exception('Failed to load detail');
  }
}
