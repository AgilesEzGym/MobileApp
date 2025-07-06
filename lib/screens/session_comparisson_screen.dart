import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/workoutSessionModel.dart';

class SessionComparisonScreen extends StatelessWidget {
  final List<WorkoutSession> sessions;
  final WorkoutSession selectedSession;

  const SessionComparisonScreen({
    super.key,
    required this.sessions,
    required this.selectedSession,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = [...sessions]
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    return Scaffold(
      appBar: AppBar(title: const Text("Comparar sesión")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Duración por sesión (segundos)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 280,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxY(sorted),
                  minY: 0,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final session = sorted[group.x.toInt()];
                        final duration = session.endTime
                            .difference(session.startTime)
                            .inSeconds;
                        return BarTooltipItem(
                          "${session.startTime.toLocal().toIso8601String().split('T').first}\n"
                          "$duration s",
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final index = value.toInt();
                          if (index >= sorted.length) return const SizedBox();
                          final date = sorted[index].startTime;
                          return Text(
                            "${date.day}/${date.month}",
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 10,
                        getTitlesWidget: (value, _) => Text("${value.toInt()}s",
                            style: const TextStyle(fontSize: 10)),
                      ),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(sorted.length, (index) {
                    final s = sorted[index];
                    final duration =
                        s.endTime.difference(s.startTime).inSeconds;
                    final isSelected =
                        s.startTime == selectedSession.startTime &&
                            s.reps == selectedSession.reps;

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: duration.toDouble(),
                          color:
                              isSelected ? Colors.green : Colors.orangeAccent,
                          width: isSelected ? 16 : 12,
                          borderRadius: BorderRadius.circular(4),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: _getMaxY(sorted),
                            color: Colors.grey[200],
                          ),
                        )
                      ],
                    );
                  }),
                ),
                swapAnimationDuration: const Duration(milliseconds: 500),
                swapAnimationCurve: Curves.easeOut,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getMaxY(List<WorkoutSession> sessions) {
    final max = sessions
        .map((s) => s.endTime.difference(s.startTime).inSeconds)
        .fold(0, (a, b) => a > b ? a : b);
    return (max + 10).toDouble(); // padding arriba
  }
}
