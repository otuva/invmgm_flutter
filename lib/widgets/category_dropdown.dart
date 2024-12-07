import 'package:flutter/material.dart';
import 'package:invmgm_flutter/models/category.dart';

class CategoryDropdown extends StatelessWidget {
  const CategoryDropdown({
    super.key,
    required this.categories,
    required this.onSelected,
    this.selectedCategory,
    this.hint = const Text('Select Category'),
  });

  final List<Category> categories;
  final Category? selectedCategory;
  final ValueChanged<Category?> onSelected;
  final Widget hint;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Category>(
      value: selectedCategory,
      isExpanded: true,
      hint: hint,
      items: [
        const DropdownMenuItem<Category>(
          value: null,
          child: Text('No category'),
        ),
        ..._buildDropdownItems(categories),
      ],
      onChanged: onSelected,
    );
  }

  /// Recursively builds dropdown menu items for a tree of categories
  List<DropdownMenuItem<Category>> _buildDropdownItems(List<Category> categories,
      {int depth = 0}) {
    return categories.expand((category) {
      final padding = ' ' * depth * 4; // Indent based on depth
      return [
        DropdownMenuItem<Category>(
          value: category,
          child: Text('$padding${category.name}'),
        ),
        if (category.children.isNotEmpty)
          ..._buildDropdownItems(category.children, depth: depth + 1),
      ];
    }).toList();
  }
}
