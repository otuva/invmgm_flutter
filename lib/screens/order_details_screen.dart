import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invmgm_flutter/models/order_status.dart';
import '../models/order.dart';
import '../providers/order_provider.dart';
import '../providers/product_provider.dart';

class OrderDetailsScreen extends ConsumerWidget {
  final int orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsyncValue = ref.watch(orderByIdProvider(orderId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        centerTitle: true,
      ),
      body: orderAsyncValue.when(
        data: (order) => _buildOrderDetails(context, ref, order),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildOrderDetails(BuildContext context, WidgetRef ref, Order order) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderSummaryCard(order, context),
            const SizedBox(height: 16),
            _buildOrderItemsCard(ref, order.items),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard(Order order, BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
            Row(
              children: [
                const Icon(Icons.email, size: 20),
                const SizedBox(width: 8),
                Text(order.email),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 8),
                Text('Date: ${order.orderDate.toLocal()}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.info, size: 20),
                const SizedBox(width: 8),
                Text('Status: ${order.status.displayName}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsCard(WidgetRef ref, List<OrderItem> items) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...items.map((item) {
              final productAsyncValue =
                  ref.watch(productByIdProvider(item.productId));
              return productAsyncValue.when(
                data: (product) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Product: ${product.name}'),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Quantity: ${item.quantity}'),
                          Text(
                              'Total Price: \$${item.totalPrice.toStringAsFixed(2)}'),
                        ],
                      ),
                    ],
                  ),
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Error loading product details'),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
