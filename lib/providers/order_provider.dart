import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../services/order_service.dart';

final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService();
});

final allOrdersProvider = FutureProvider<List<Order>>((ref) async {
  final service = ref.watch(orderServiceProvider);
  return service.getAllOrders();
});

final ordersByStatusProvider =
    FutureProvider.family<List<Order>, OrderStatus>((ref, status) async {
  final service = ref.watch(orderServiceProvider);
  return service.getOrdersByStatus(status);
});

final orderByIdProvider = FutureProvider.family<Order, int>((ref, id) async {
  final service = ref.watch(orderServiceProvider);
  return service.getOrderById(id);
});
