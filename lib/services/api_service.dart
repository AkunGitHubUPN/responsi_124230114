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

  // Fetch restaurants with categories by fetching detail for each
  static Future<List<Item>> fetchListWithCategories(String menu) async {
    print('Fetching restaurants with categories...');
    final baseList = await fetchList(menu);
    print('Fetched ${baseList.length} restaurants, now fetching details for categories...');
    
    final updatedList = <Item>[];
    
    for (int i = 0; i < baseList.length; i++) {
      try {
        final item = baseList[i];
        final detail = await fetchDetail(item.id);
        updatedList.add(detail);
        print('  ✓ ${detail.title} - categories: ${detail.categories}');
      } catch (e) {
        // If detail fetch fails, use base item
        updatedList.add(baseList[i]);
        print('  ✗ Failed to fetch detail for ${baseList[i].title}');
      }
    }
    
    print('Completed fetching all details. Total: ${updatedList.length}');
    return updatedList;
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
    
    // Fallback: Fetch detail for each restaurant to extract categories
    print('\n--- Falling back to fetch detail for category extraction ---');
    try {
      print('Fetching restaurants list...');
      final restaurants = await fetchList('restaurants');
      print('Fetched ${restaurants.length} restaurants');
      
      final categoriesSet = <String>{};
      
      // For first 10 restaurants, fetch detail to get categories
      for (int i = 0; i < restaurants.length && i < 10; i++) {
        try {
          print('Fetching detail for: ${restaurants[i].title}');
          final detail = await fetchDetail(restaurants[i].id);
          if (detail.categories.isNotEmpty) {
            print('  Categories: ${detail.categories}');
            categoriesSet.addAll(detail.categories);
          }
        } catch (e) {
          print('  Error fetching detail: $e');
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
      print('Failed to extract categories from detail: $e');
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
