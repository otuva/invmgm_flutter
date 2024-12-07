import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../services/category_service.dart';

final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService();
});

final allCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final service = ref.watch(categoryServiceProvider);
  final categories = await service.getAllCategories();

  // Use the static method to build the tree
  return Category.buildTree(categories);
});

final categoryByIdProvider =
    FutureProvider.family<Category, int>((ref, id) async {
  final service = ref.watch(categoryServiceProvider);
  return service.getCategoryById(id);
});
