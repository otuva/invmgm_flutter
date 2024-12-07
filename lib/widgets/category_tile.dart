import 'package:flutter/material.dart';
import 'package:invmgm_flutter/models/category.dart';

class CategoryTile extends StatelessWidget {
  const CategoryTile({super.key, required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(category.name),
      trailing: category.children.isNotEmpty ? null : const SizedBox.shrink(),
      children: category.children
          .map(
            (child) => CategoryTile(category: child),
          )
          .toList(),
    );
  }
}
