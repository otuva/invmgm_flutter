import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/category_provider.dart';
import '../models/category.dart';

class CategoryTreeScreen extends ConsumerWidget {
  const CategoryTreeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsyncValue = ref.watch(allCategoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Category Tree')),
      body: categoriesAsyncValue.when(
        data: (categories) => ListView(
          children: categories
              .map((category) => CategoryTile(category: category))
              .toList(),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  const CategoryTile({super.key, required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(category.name),
      trailing: category.children.isNotEmpty
          ? null
          : const SizedBox.shrink(),
      children: category.children
          .map((child) => CategoryTile(category: child))
          .toList(),
    );
  }
}
