import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/category_tree_screen.dart';

void main() {
  runApp(const ProviderScope(child: InvMgmApp()));
}

class InvMgmApp extends StatelessWidget {
  const InvMgmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Category App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CategoryTreeScreen(),
    );
  }
}
