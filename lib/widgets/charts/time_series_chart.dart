import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';

// Usamos um ConsumerWidget, a forma do Riverpod de criar widgets que ouvem providers.
class TimeSeriesChart extends ConsumerWidget {
  const TimeSeriesChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeSeriesAsync = ref.watch(timeSeriesProvider);
    final theme = Theme.of(context);

    return timeSeriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error ${error.toString()}')),
      data: (data) {
        if (data.isEmpty) {
          return const Center(
            child: Text('Nenhum dado disponível para este período.'),
          );
        }

        final spots = data.map((point) {
          return FlSpot(
            point.time.millisecondsSinceEpoch.toDouble(),
            point.close,
          );
        }).toList();

        return LineChart(
          LineChartData(
            // Estilo da linha do gráfico
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: theme.colorScheme.primary,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: const FlDotData(
                  show: false,
                ), // Esconde os pontos na linha
                belowBarData: BarAreaData(
                  show: true,
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
            ],
            // Títulos e grades do gráfico
            titlesData: const FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 40),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(
              show: true,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: theme.dividerColor.withValues(alpha: 0.1),
                  strokeWidth: 1,
                );
              },
              drawVerticalLine: false,
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.1),
              ),
            ),
          ),
        );
      },
    );
  }
}
