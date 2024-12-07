import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';

final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService();
});

final allCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final service = ref.watch(categoryServiceProvider);
  return service.getAllCategories();
});

final categoryByIdProvider = FutureProvider.family<Category, int>((ref, id) async {
  final service = ref.watch(categoryServiceProvider);
  return service.getCategoryById(id);
});
