import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invmgm_flutter/screens/orders_screen.dart';
import 'package:invmgm_flutter/screens/product_list_screen.dart';
import 'screens/category_tree_screen.dart';

// ignore certs
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();

  runApp(const ProviderScope(child: InvMgmApp()));
}

class InvMgmApp extends StatelessWidget {
  const InvMgmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Category App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const OrdersScreen(),
    );
  }
}
