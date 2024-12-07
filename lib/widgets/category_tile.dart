import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invmgm_flutter/models/category.dart';
import 'package:invmgm_flutter/providers/category_provider.dart';

class CategoryTile extends ConsumerWidget {
  const CategoryTile({super.key, required this.category});

  final Category category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ExpansionTile(
      title: Text(category.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () => _showEditCategoryDialog(context, ref, category),
          ),
          if (category.children.isNotEmpty) const Icon(Icons.arrow_drop_down),
        ],
      ),
      children: category.children
          .map((child) => CategoryTile(category: child))
          .toList(),
    );
  }
}

void _showEditCategoryDialog(
    BuildContext context, WidgetRef ref, Category category) {
  final nameController = TextEditingController(text: category.name);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Edit Category'),
      content: TextField(
        controller: nameController,
        decoration: const InputDecoration(labelText: 'Category Name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final updatedName = nameController.text.trim();

            if (updatedName.isNotEmpty) {
              await ref
                  .read(categoryServiceProvider)
                  .updateCategory(category.id, updatedName);
              ref.invalidate(
                  allCategoriesProvider); // Refresh the category tree
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}
