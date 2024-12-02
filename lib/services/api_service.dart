import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://opentdb.com';

  // Fetch categories from the API
  static Future<List<Map<String, String>>> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api_category.php'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List categories = data['trivia_categories'];

        return categories.map((category) {
  return {
    'id': category['id'].toString(),
    'name': category['name'] as String,
  };
}).toList();
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }
}