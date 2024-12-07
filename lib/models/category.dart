import 'dart:convert';

class Category {
  final int id;
  final String name;
  final int parentId;
  final String? parentName;
  List<Category> children;

  Category({
    required this.id,
    required this.name,
    required this.parentId,
    this.parentName,
    this.children = const [],
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      parentId: json['parentId'],
      parentName: json['parentName'],
      children: [],
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

  static List<Category> buildTree(List<Category> categories) {
    final Map<int, List<Category>> groupedByParent = {};

    for (final category in categories) {
      groupedByParent.putIfAbsent(category.parentId, () => []).add(category);
    }

    void attachChildren(Category parent) {
      parent.children = groupedByParent[parent.id] ?? [];
      for (final child in parent.children) {
        attachChildren(child);
      }
    }

    final List<Category> rootCategories = groupedByParent[0] ?? [];
    for (final rootCategory in rootCategories) {
      attachChildren(rootCategory);
    }

    return rootCategories;
  }
}
