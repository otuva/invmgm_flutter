import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_status.dart';
import '../providers/order_provider.dart';
import '../widgets/indicator.dart';

class OrdersPieChart extends ConsumerStatefulWidget {
  const OrdersPieChart({super.key});

  @override
  ConsumerState<OrdersPieChart> createState() => OrdersPieChartState();
}

class OrdersPieChartState extends ConsumerState<OrdersPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final ordersAsyncValue = ref.watch(allOrdersProvider);

        return ordersAsyncValue.when(
          data: (orders) {
            // Count orders by status
            final orderStatusCounts = OrderStatus.values.map((status) {
              return orders.where((order) => order.status == status).length;
            }).toList();

            return AspectRatio(
              aspectRatio: 1.3,
              child: Row(
                children: <Widget>[
                  const SizedBox(
                    height: 18,
                  ),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback:
                                (FlTouchEvent event, pieTouchResponse) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    pieTouchResponse == null ||
                                    pieTouchResponse.touchedSection == null) {
                                  touchedIndex = -1;
                                  return;
                                }
                                touchedIndex = pieTouchResponse
                                    .touchedSection!.touchedSectionIndex;
                              });
                            },
                          ),
                          borderData: FlBorderData(
                            show: false,
                          ),
                          sectionsSpace: 0,
                          centerSpaceRadius: 40,
                          sections: showingSections(context, orderStatusCounts),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(OrderStatus.values.length, (index) {
                      final color = Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.5 + (index % 5) * 0.1);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Indicator(
                          color: color,
                          text: OrderStatus.values[index].displayName,
                          isSquare: true,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(
                    width: 28,
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        );
      },
    );
  }

  List<PieChartSectionData> showingSections(
      BuildContext context, List<int> orderStatusCounts) {
    return List.generate(OrderStatus.values.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      final color = Theme.of(context)
          .colorScheme
          .primary
          .withOpacity(0.60 + (i % 5) * 0.1);
      final textColor = Theme.of(context).colorScheme.onPrimary;

      return PieChartSectionData(
        color: color,
        value: orderStatusCounts[i].toDouble(),
        title: '${orderStatusCounts[i]}',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: textColor,
          shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      );
    });
  }
}
