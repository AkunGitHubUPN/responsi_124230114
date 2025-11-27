import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/item.dart';

class ApiService {
  static const _base = 'https://api.spaceflightnewsapi.net/v4';

  static Future<List<Item>> fetchList(String menu) async {
    final url = Uri.parse('$_base/$menu/');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      if (data is List) {
        return data.map<Item>((e) => Item.fromJson(e as Map<String, dynamic>, menu)).toList();
      }
      // sometimes API returns object with 'results'
      if (data is Map && data['results'] is List) {
        return (data['results'] as List).map<Item>((e) => Item.fromJson(e as Map<String, dynamic>, menu)).toList();
      }
    }
    throw Exception('Failed to load $menu');
  }

  static Future<Item> fetchDetail(String menu, int id) async {
    final url = Uri.parse('$_base/$menu/$id/');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body) as Map<String, dynamic>;
      return Item.fromJson(data, menu);
    }
    throw Exception('Failed to load detail');
  }
}
