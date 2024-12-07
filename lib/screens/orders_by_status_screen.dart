import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invmgm_flutter/models/order_status.dart';
import 'package:invmgm_flutter/providers/order_provider.dart';

class OrdersByStatusScreen extends ConsumerWidget {
  final OrderStatus status;

  const OrdersByStatusScreen({super.key, required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsyncValue = ref.watch(ordersByStatusProvider(status));

    return Scaffold(
      appBar: AppBar(
        title: Text('Orders: ${status.displayName}'),
      ),
      body: ordersAsyncValue.when(
        data: (orders) => orders.isEmpty
            ? const Center(child: Text('No orders found'))
            : ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return ListTile(
                    title: Text('Order #${order.id}'),
                    subtitle: Text('Email: ${order.email}'),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
