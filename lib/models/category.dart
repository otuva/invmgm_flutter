import 'dart:convert';

class Category {
  final int id;
  final String name;
  final int parentId;
  final String? parentName;

  Category({
    required this.id,
    required this.name,
    required this.parentId,
    this.parentName,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      parentId: json['parentId'],
      parentName: json['parentName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parentId': parentId,
    };
  }

  static List<Category> parseCategories(String responseBody) {
    final parsed = json.decode(responseBody)['data'] as List;
    return parsed.map((json) => Category.fromJson(json)).toList();
  }
}
