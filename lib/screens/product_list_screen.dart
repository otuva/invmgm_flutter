import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invmgm_flutter/models/category.dart';
import 'package:invmgm_flutter/providers/category_provider.dart';
import 'package:invmgm_flutter/widgets/category_dropdown.dart';
import 'package:invmgm_flutter/models/product.dart';
import 'package:invmgm_flutter/providers/product_provider.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  Category? selectedCategory; // Track the selected category for filtering

  @override
  Widget build(BuildContext context) {
    final productsAsyncValue = selectedCategory == null
        ? ref.watch(
            allProductsProvider) // Fetch all products if no category is selected
        : ref.watch(productsByCategoryProvider(
            selectedCategory!.id)); // Fetch filtered products

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: productsAsyncValue.when(
        data: (products) => products.isEmpty
            ? const Center(child: Text('No products found'))
            : ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return _buildProductCard(product, context);
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

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        Category? tempSelectedCategory = selectedCategory;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) => AlertDialog(
            title: const Text('Filter by Category'),
            content: SingleChildScrollView(
              child: Consumer(
                builder: (context, ref, child) {
                  final categoriesAsyncValue = ref.watch(allCategoriesProvider);

                  return categoriesAsyncValue.when(
                    data: (categories) => CategoryDropdown(
                      categories: categories,
                      selectedCategory: tempSelectedCategory,
                      onSelected: (Category? newValue) {
                        setDialogState(() {
                          tempSelectedCategory = newValue;
                        });
                      },
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => Text('Error: $error'),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedCategory = tempSelectedCategory;
                  });
                  Navigator.pop(dialogContext);
                },
                child: const Text('Apply'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductCard(Product product, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('Description: ${product.description}'),
            Text('Price: \$${product.price.toStringAsFixed(2)}'),
            Text('Stock: ${product.stock}'),
            Text('Category: ${product.categoryName ?? 'Unknown'}'),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDeleteProduct(context, ref, product),
              ),
            ),
          ],
        ),
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
                  selectedCategory == null ||
                  price <= 0 ||
                  stock <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('One or more fields are not valid')),
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
