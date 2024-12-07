import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invmgm_flutter/models/order.dart';
import 'package:invmgm_flutter/models/order_status.dart';
import 'package:invmgm_flutter/providers/order_provider.dart';
import 'package:invmgm_flutter/screens/order_details_screen.dart';

class OrdersByStatusScreen extends ConsumerWidget {
  final OrderStatus status;

  const OrdersByStatusScreen({super.key, required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsyncValue = ref.watch(ordersByStatusProvider(status));

    return Scaffold(
      appBar: AppBar(
        title: Text('Orders: ${status.displayName}'),
        centerTitle: true,
      ),
      body: ordersAsyncValue.when(
        data: (orders) => orders.isEmpty
            ? const Center(child: Text('No orders found'))
            : ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return _buildOrderCard(context, order);
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
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
              Text('Status: ${order.status.displayName}'),
            ],
          ),
        ),
      ),
    );
  }
}
