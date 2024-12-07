import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invmgm_flutter/models/product.dart';
import 'package:invmgm_flutter/services/product_service.dart';

final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});

final allProductsProvider = FutureProvider<List<Product>>((ref) async {
  final service = ref.watch(productServiceProvider);
  return service.getAllProducts();
});

final productByIdProvider =
    FutureProvider.family<Product, int>((ref, id) async {
  final service = ref.watch(productServiceProvider);
  return service.getProductById(id);
});

final productsByCategoryProvider =
    FutureProvider.family<List<Product>, int>((ref, categoryId) async {
  final service = ref.watch(productServiceProvider);
  return service.getProductsByCategoryId(categoryId);
});
