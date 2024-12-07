import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invmgm_flutter/models/category.dart';
import 'package:invmgm_flutter/widgets/category_dropdown.dart';
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}

void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
  final nameController = TextEditingController();
  Category? selectedParent; // Track the selected parent category

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (dialogContext, setState) => AlertDialog(
        title: const Text('Add New Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Category Name'),
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, child) {
                final categoriesAsyncValue = ref.watch(allCategoriesProvider);

                return categoriesAsyncValue.when(
                  data: (categories) => CategoryDropdown(
                    categories: categories,
                    selectedCategory: selectedParent,
                    onSelected: (Category? newValue) {
                      setState(() {
                        selectedParent = newValue; // Update selected category
                      });
                    },
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) =>
                      Text('Error loading categories: $error'),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => onPressedAddCategory(
              context: context,
              ref: ref,
              name: nameController.text.trim(),
              parentId: selectedParent?.id,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    ),
  );
}

Future<void> onPressedAddCategory({
  required BuildContext context,
  required WidgetRef ref,
  required String name,
  int? parentId,
}) async {
  if (name.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Category name cannot be empty')),
    );
    return;
  }

  // Call the service to create a new category
  await ref.read(categoryServiceProvider).createCategory(name, parentId ?? 0);

  // Refresh the category tree
  ref.invalidate(allCategoriesProvider);

  // Close the dialog
  Navigator.pop(context);

  // Show success message
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Category added successfully')),
  );
}
