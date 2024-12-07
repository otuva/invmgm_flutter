import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:invmgm_flutter/config/api_configuration.dart';
import '../models/order.dart';
import '../models/order_status.dart';

const String baseHost = ApiConfiguration.baseHost;

class OrderService {
  final String baseUrl = "$baseHost/api/Order";

  Future<Order> createOrder(String email, List<OrderItem> items) async {
    final url = Uri.parse('$baseUrl/CreateOrder');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'items': items.map((item) => item.toJson()).toList(),
      }),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 && responseData['isSuccess']) {
      final orderId = responseData['data']['orderId'];
      return getOrderById(orderId); // Fetch and return the created order
    } else {
      throw ErrorDescription(responseData['message'] ?? 'Failed to create order');
    }
  }

  Future<Order> getOrderById(int id) async {
    final url = Uri.parse('$baseUrl/GetOrderById?Id=$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body)['data'];
      return Order.fromJson(responseData);
    } else {
      throw ErrorDescription('Failed to fetch order: ${response.body}');
    }
  }

  Future<void> changeOrderStatus(int orderId, OrderStatus status) async {
    final url = Uri.parse('$baseUrl/ChangeStatus');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'orderId': orderId, 'orderStatus': status.toInt()}),
    );

    if (response.statusCode != 200) {
      throw ErrorDescription('Failed to change status: ${response.body}');
    }
  }

  Future<List<Order>> getAllOrders() async {
    final url = Uri.parse('$baseUrl/GetAllOrders');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return parseOrders(response.body);
    } else {
      throw ErrorDescription('Failed to fetch orders: ${response.body}');
    }
  }

  Future<List<Order>> getOrdersByStatus(OrderStatus status) async {
    final url =
        Uri.parse('$baseUrl/GetOrdersByStatus?Status=${status.toInt()}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return parseOrders(response.body);
    } else {
      throw ErrorDescription('Failed to fetch orders by status: ${response.body}');
    }
  }
}
