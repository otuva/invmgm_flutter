import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:invmgm_flutter/models/product.dart';

const String baseHost = "https://192.168.122.154:7089";

class ProductService {
  final String baseUrl = "$baseHost/api/Product";

  Future<Product> createProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required int categoryId,
  }) async {
    final url = Uri.parse('$baseUrl/Createproduct');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'categoryId': categoryId,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final int newProductId = responseData['data']['id'];
      return getProductById(newProductId);
    } else {
      throw Exception('Failed to create product: ${response.body}');
    }
  }

  Future<void> deleteProduct(int id) async {
    final url = Uri.parse('$baseUrl/DeleteProduct');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete product: ${response.body}');
    }
  }

  Future<List<Product>> getAllProducts() async {
    final url = Uri.parse('$baseUrl/GetAllProducts');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return parseProductList(response.body);
    } else {
      throw Exception('Failed to fetch products: ${response.body}');
    }
  }

  Future<Product> getProductById(int id) async {
    final url = Uri.parse('$baseUrl/GetProductById?Id=$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body)['data'];
      return Product.fromJson(responseData);
    } else {
      throw Exception('Failed to fetch product by ID: ${response.body}');
    }
  }

  Future<List<Product>> getProductsByCategoryId(int categoryId) async {
    final url =
        Uri.parse('$baseUrl/GetProductByCategoryId?CategoryId=$categoryId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return parseProductList(response.body);
    } else {
      throw Exception(
          'Failed to fetch products by category ID: ${response.body}');
    }
  }
}
