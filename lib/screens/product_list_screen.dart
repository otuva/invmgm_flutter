import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invmgm_flutter/models/category.dart';
import 'package:invmgm_flutter/providers/category_provider.dart';
import 'package:invmgm_flutter/widgets/category_dropdown.dart';
import 'package:invmgm_flutter/models/product.dart';
import 'package:invmgm_flutter/providers/product_provider.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsyncValue = ref.watch(allProductsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: productsAsyncValue.when(
        data: (products) => ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ListTile(
              title: Text(product.name),
              subtitle:
                  Text('Price: \$${product.price} | Stock: ${product.stock}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDeleteProduct(context, ref, product),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}

Future<void> _deleteProduct(
  BuildContext context,
  WidgetRef ref,
  Product product,
) async {
  try {
    // Save a reference to the deleted product for undo functionality
    final deletedProduct = product;

    // Delete the product
    await ref.read(productServiceProvider).deleteProduct(product.id);

    // Refresh product list
    ref.invalidate(allProductsProvider);

    // Show undo snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted "${product.name}".'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            await ref.read(productServiceProvider).createProduct(
                  name: deletedProduct.name,
                  description: deletedProduct.description,
                  price: deletedProduct.price,
                  stock: deletedProduct.stock,
                  categoryId: deletedProduct.categoryId,
                );
            ref.invalidate(allProductsProvider); // Refresh product list
          },
        ),
      ),
    );
  } catch (e) {
    // Handle errors
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error deleting product: $e')),
    );
  }
}

void _confirmDeleteProduct(
  BuildContext context,
  WidgetRef ref,
  Product product,
) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Product'),
      content: Text('Are you sure you want to delete "${product.name}"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context); // Close confirmation dialog
            await _deleteProduct(context, ref, product);
          },
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}

void _showAddProductDialog(
  BuildContext context,
  WidgetRef ref,
) {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  Category? selectedCategory;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (dialogContext, setState) => AlertDialog(
        title: const Text('Add New Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number, // Numerical keyboard
              ),
              TextField(
                controller: stockController,
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number, // Numerical keyboard
              ),
              const SizedBox(height: 16),
              Consumer(
                builder: (context, ref, child) {
                  final categoriesAsyncValue = ref.watch(allCategoriesProvider);

                  return categoriesAsyncValue.when(
                    data: (categories) => CategoryDropdown(
                      categories: categories,
                      selectedCategory: selectedCategory,
                      onSelected: (Category? newValue) {
                        setState(() {
                          selectedCategory =
                              newValue; // Update selected category
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final description = descriptionController.text.trim();
              final price = double.tryParse(priceController.text) ?? 0;
              final stock = int.tryParse(stockController.text) ?? 0;

              if (name.isEmpty ||
                  description.isEmpty ||
                  selectedCategory == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All fields are required')),
                );
                return;
              }

              try {
                await ref.read(productServiceProvider).createProduct(
                      name: name,
                      description: description,
                      price: price,
                      stock: stock,
                      categoryId: selectedCategory!.id,
                    );
                ref.invalidate(allProductsProvider); // Refresh product list
                Navigator.pop(context); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Product added successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error adding product: $e')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    ),
  );
}
