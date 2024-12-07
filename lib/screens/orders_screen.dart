import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invmgm_flutter/models/product.dart';
import 'package:invmgm_flutter/providers/product_provider.dart';
import 'package:invmgm_flutter/screens/order_details_screen.dart';
import 'package:invmgm_flutter/screens/orders_by_status_screen.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../providers/order_provider.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  Set<OrderStatus> selectedStatuses =
      {}; // Track selected statuses for filtering

  @override
  Widget build(BuildContext context) {
    // Fetch all orders once
    final ordersAsyncValue = ref.watch(allOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildStatusFilterChips(context), // Status filter chips
          Expanded(
            child: ordersAsyncValue.when(
              data: (orders) {
                final filteredOrders =
                    _filterOrdersByStatuses(orders, selectedStatuses);
                return filteredOrders.isEmpty
                    ? const Center(child: Text('No orders found'))
                    : ListView.builder(
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];
                          return _buildOrderCard(context, order);
                        },
                      );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _showAddOrderDialog(context, ref), // Add new order dialog
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Order> _filterOrdersByStatuses(
      List<Order> orders, Set<OrderStatus> statuses) {
    if (statuses.isEmpty) return orders; // No filter applied
    return orders.where((order) => statuses.contains(order.status)).toList();
  }

  Widget _buildStatusFilterChips(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: OrderStatus.values.map((status) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: FilterChip(
                label: Text(status.displayName),
                selected: selectedStatuses.contains(status),
                onSelected: (bool isSelected) {
                  setState(() {
                    if (isSelected) {
                      selectedStatuses.add(status);
                    } else {
                      selectedStatuses.remove(status);
                    }
                  });
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsScreen(orderId: order.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order #${order.id}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text('Email: ${order.email}'),
              Text('Date: ${order.orderDate.toLocal()}'),
              GestureDetector(
                onTap: () => _navigateToStatusScreen(context, order.status),
                child: Text(
                  'Status: ${order.status.displayName}',
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _showChangeStatusDialog(context, ref, order);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToStatusScreen(BuildContext context, OrderStatus status) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrdersByStatusScreen(status: status),
      ),
    );
  }

  void _showAddOrderDialog(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final quantityController = TextEditingController();
    Product? selectedProduct;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Order'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Email Input Field
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter customer email',
                    errorText:
                        null, // Will be set dynamically if email is invalid
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    // Dynamically validate email format
                    setState(() {
                      // final isValid = _isValidEmail(value);
                      emailController.text = value;
                      emailController.selection = TextSelection.fromPosition(
                        TextPosition(offset: emailController.text.length),
                      );
                    });
                  },
                ),
                const SizedBox(height: 8),
                // Quantity Input Field
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    hintText: 'Enter quantity',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                // Product Dropdown
                Consumer(
                  builder: (context, ref, child) {
                    final productsAsyncValue = ref.watch(allProductsProvider);

                    return productsAsyncValue.when(
                      data: (products) => DropdownButton<Product>(
                        value: selectedProduct,
                        isExpanded: true,
                        hint: const Text('Select Product'),
                        items: products.map((product) {
                          return DropdownMenuItem<Product>(
                            value: product,
                            child: Text(product.name),
                          );
                        }).toList(),
                        onChanged: (Product? newValue) {
                          setState(() {
                            selectedProduct = newValue;
                          });
                        },
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) => Text('Error: $error'),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext), // Close dialog
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                final quantity = int.tryParse(quantityController.text) ?? 0;

                if (!_isValidEmail(email)) {
                  // Show error for invalid email
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid email')),
                  );
                  return;
                }

                if (quantity <= 0) {
                  // Show error for invalid quantity
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please enter a valid quantity')),
                  );
                  return;
                }

                if (selectedProduct == null) {
                  // Show error for no product selected
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a product')),
                  );
                  return;
                }

                try {
                  // Create a new order
                  final orderItems = [
                    OrderItem(
                      productId: selectedProduct!.id,
                      quantity: quantity,
                      totalPrice: selectedProduct!.price * quantity,
                    )
                  ];
                  await ref
                      .read(orderServiceProvider)
                      .createOrder(email, orderItems);

                  ref.invalidate(allOrdersProvider); // Refresh orders

                  Navigator.pop(dialogContext); // Close dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Order added successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error creating order: $e')),
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

// Email Validation Helper
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  void _showChangeStatusDialog(
      BuildContext context, WidgetRef ref, Order order) {
    OrderStatus? newStatus = order.status; // Initialize with current status

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Change Order Status'),
          content: DropdownButton<OrderStatus>(
            value: newStatus, // Reflect current status
            onChanged: (OrderStatus? status) {
              if (status != null) {
                setState(() {
                  newStatus = status; // Update new status locally in the dialog
                });
              }
            },
            items: OrderStatus.values.map((status) {
              return DropdownMenuItem<OrderStatus>(
                value: status,
                child: Text(status.displayName),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext), // Close dialog
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (newStatus != null && newStatus != order.status) {
                  // Call the service to change the status
                  await ref
                      .read(orderServiceProvider)
                      .changeOrderStatus(order.id, newStatus!);

                  // Refresh the orders
                  ref.invalidate(allOrdersProvider);

                  // Close the dialog and show a success message
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Order #${order.id} status updated to ${newStatus?.displayName}'),
                    ),
                  );
                } else {
                  Navigator.pop(dialogContext); // Close without changes
                }
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}
