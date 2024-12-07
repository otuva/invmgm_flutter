import 'dart:convert';

import 'order_status.dart';

class OrderItem {
  final int productId;
  final int quantity;
  final double totalPrice;

  OrderItem({
    required this.productId,
    required this.quantity,
    required this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'],
      quantity: json['quantity'],
      totalPrice: json['totalPrice'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'quantity': quantity,
      };
}

class Order {
  final int id;
  final String email;
  final OrderStatus status;
  final DateTime orderDate;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.email,
    required this.status,
    required this.orderDate,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      email: json['email'],
      status: OrderStatusExtension.fromInt(json['status']),
      orderDate: DateTime.parse(json['orderDate']),
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
    );
  }
}

List<Order> parseOrders(String responseBody) {
  final parsed = jsonDecode(responseBody)['data'] as List;
  return parsed.map((json) => Order.fromJson(json)).toList();
}
