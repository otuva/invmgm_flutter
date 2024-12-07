import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  OrderStatus? selectedStatus; // Track the selected status for filtering

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
                    _filterOrdersByStatus(orders, selectedStatus);
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

  List<Order> _filterOrdersByStatus(List<Order> orders, OrderStatus? status) {
    if (status == null) return orders; // No filter applied
    return orders.where((order) => order.status == status).toList();
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
                selected: selectedStatus == status,
                onSelected: (bool isSelected) {
                  setState(() {
                    selectedStatus = isSelected ? status : null;
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
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.edit, color: Colors.orange),
                onPressed: () {
                  _showChangeStatusDialog(context, ref, order);
                },
              ),
            ),
          ],
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
    final productController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: productController,
              decoration: const InputDecoration(labelText: 'Product Details'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Add order logic
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showChangeStatusDialog(
      BuildContext context, WidgetRef ref, Order order) {
    OrderStatus? newStatus = order.status;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Change Order Status'),
        content: DropdownButton<OrderStatus>(
          value: newStatus,
          onChanged: (OrderStatus? status) {
            if (status != null) {
              newStatus = status;
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
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newStatus != null && newStatus != order.status) {
                await ref
                    .read(orderServiceProvider)
                    .changeOrderStatus(order.id, newStatus!);
                ref.invalidate(allOrdersProvider); // Refresh orders
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
