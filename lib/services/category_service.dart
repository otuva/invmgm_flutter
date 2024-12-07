import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:invmgm_flutter/models/category.dart';

const String baseHost = "https://192.168.122.154:7089";

class CategoryService {
  final String baseUrl = "$baseHost/api/Category";

  Future<Category?> createCategory(String name, int parentId) async {
    final url = Uri.parse('$baseUrl/CreateCategory');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'parentId': parentId}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final int newCategoryId = responseData['data']['id'];

      return getCategoryById(newCategoryId);
    } else {
      throw Exception('Failed to create category');
    }
  }

  Future<void> deleteCategory(int id) async {
    final url = Uri.parse('$baseUrl/DeleteCategory');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete category');
    }
  }

  Future<void> updateCategory(int id, String name) async {
    final url = Uri.parse('$baseUrl/UpdateCategory');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id, 'name': name}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update category');
    }
  }

  Future<Category> getCategoryById(int id) async {
    final url = Uri.parse('$baseUrl/GetById?Id=$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Category.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to fetch category');
    }
  }

  Future<List<Category>> getAllCategories() async {
    final url = Uri.parse('$baseUrl/GetAllCategories');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Category.parseCategories(response.body);
    } else {
      throw Exception('Failed to fetch categories');
    }
  }
}
