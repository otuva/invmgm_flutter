import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';

class CategoriesBarChart extends ConsumerWidget {
  const CategoriesBarChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsyncValue = ref.watch(allCategoriesProvider);

    return categoriesAsyncValue.when(
      data: (categories) {
        // Limit to the top 4 categories
        final limitedCategories = categories.take(4).toList();
        return FutureBuilder<List<int>>(
          future: _fetchProductCounts(ref, limitedCategories),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final productCounts = snapshot.data ?? [];
            return AspectRatio(
              aspectRatio: 1.6,
              child: BarChart(
                BarChartData(
                  barTouchData: _getBarTouchData(context),
                  titlesData:
                      _getTitlesData(context, limitedCategories, productCounts),
                  borderData: _getBorderData(),
                  barGroups: _getBarGroups(context, productCounts),
                  gridData: const FlGridData(show: false),
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (productCounts.isNotEmpty
                          ? productCounts.reduce((a, b) => a > b ? a : b)
                          : 10)
                      .toDouble(),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Future<List<int>> _fetchProductCounts(
      WidgetRef ref, List<Category> categories) async {
    final List<int> productCounts = [];
    for (var category in categories) {
      final products =
          await ref.read(productsByCategoryProvider(category.id).future);
      productCounts.add(products.length);
    }
    return productCounts;
  }

  BarTouchData _getBarTouchData(BuildContext context) {
    return BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        // tooltipBgColor: Theme.of(context).colorScheme.surface,
        tooltipMargin: 8,
        getTooltipItem: (
          BarChartGroupData group,
          int groupIndex,
          BarChartRodData rod,
          int rodIndex,
        ) {
          return null;
        },
      ),
    );
  }

  FlTitlesData _getTitlesData(BuildContext context, List<Category> categories,
      List<int> productCounts) {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 50, // Increased size to fit two lines
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index >= 0 && index < categories.length) {
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 8.0,
                child: Column(
                  children: [
                    Text(
                      categories[index].name,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${productCounts[index]} products',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 10,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      leftTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
    );
  }

  FlBorderData _getBorderData() {
    return FlBorderData(show: false);
  }

  List<BarChartGroupData> _getBarGroups(
      BuildContext context, List<int> productCounts) {
    final barGradient = LinearGradient(
      colors: [
        Theme.of(context).colorScheme.primary,
        Theme.of(context).colorScheme.secondary,
      ],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );

    return List.generate(
      productCounts.length,
      (index) {
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: productCounts[index].toDouble(),
              gradient: barGradient,
            ),
          ],
          showingTooltipIndicators: [0],
        );
      },
    );
  }
}
