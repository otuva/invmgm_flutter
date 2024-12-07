import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../providers/order_provider.dart';

class OrderListScreen extends ConsumerWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsyncValue = ref.watch(allOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: ordersAsyncValue.when(
        data: (orders) => ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return ListTile(
              title: Text('Order #${order.id} - ${order.email}'),
              subtitle: Text(
                '${order.status.displayName} | ${order.orderDate.toLocal()}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _showChangeStatusDialog(context, ref, order);
                },
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
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
