import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('Testing API endpoints...');
  
  // Test categories endpoint
  try {
    final url = Uri.parse('https://restaurant-api.dicoding.dev/categories');
    print('\nFetching: $url');
    final resp = await http.get(url);
    print('Status: ${resp.statusCode}');
    print('Body: ${resp.body}');
  } catch (e) {
    print('Error: $e');
  }
  
  // Test list endpoint
  try {
    final url = Uri.parse('https://restaurant-api.dicoding.dev/list');
    print('\nFetching: $url');
    final resp = await http.get(url);
    print('Status: ${resp.statusCode}');
    final data = json.decode(resp.body);
    print('Keys: ${(data as Map).keys}');
    if (data['restaurants'] is List) {
      final restaurants = data['restaurants'] as List;
      print('Restaurant count: ${restaurants.length}');
      if (restaurants.isNotEmpty) {
        print('First restaurant: ${restaurants[0]}');
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}
