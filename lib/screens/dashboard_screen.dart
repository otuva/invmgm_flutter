import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invmgm_flutter/widgets/categories_bar_chart.dart';
import 'package:invmgm_flutter/widgets/orders_pie_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Orders by Status',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            OrdersPieChart(),
            SizedBox(height: 16),
            Text('Popular Product Categories',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 32),
            CategoriesBarChart(),
          ],
        ),
      ),
    );
  }
}
