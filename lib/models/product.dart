import 'dart:convert';

class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final int categoryId;
  final String? categoryName;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.categoryId,
    this.categoryName,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      stock: json['stock'],
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'categoryId': categoryId,
    };
  }
}

List<Product> parseProductList(String responseBody) {
  final parsed = jsonDecode(responseBody)['data'] as List;
  return parsed.map((json) => Product.fromJson(json)).toList();
}
