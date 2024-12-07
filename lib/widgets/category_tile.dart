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
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setState) => AlertDialog(
        title: const Text('Edit Category'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Category Name'),
        ),
        actions: [
          if (category
              .children.isEmpty) // Show Delete button only if no children
            TextButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Delete'),
                    content: const Text(
                        'Are you sure you want to delete this category? This action cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  try {
                    // Call the delete endpoint
                    await ref
                        .read(categoryServiceProvider)
                        .deleteCategory(category.id);

                    // Refresh the category tree
                    ref.invalidate(allCategoriesProvider);

                    // Close the dialog
                    Navigator.pop(dialogContext);

                    // Optionally show a success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Category "${category.name}" deleted successfully')),
                    );
                  } catch (e) {
                    // Handle errors
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error deleting category: $e')),
                    );
                  }
                }
              },
              child: const Text('Delete'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedName = nameController.text.trim();

              if (updatedName.isNotEmpty) {
                try {
                  // Call the update endpoint
                  await ref
                      .read(categoryServiceProvider)
                      .updateCategory(category.id, updatedName);

                  // Refresh the category tree
                  ref.invalidate(allCategoriesProvider);

                  // Close the dialog
                  Navigator.pop(context);

                  // Optionally show a success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Category "${category.name}" updated successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating category: $e')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Category name cannot be empty')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}
