import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invmgm_flutter/widgets/category_tile.dart';
import 'package:invmgm_flutter/providers/category_provider.dart';

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
