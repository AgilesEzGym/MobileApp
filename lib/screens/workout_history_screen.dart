import 'dart:convert';
import 'package:ezgym/screens/session_comparisson_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workoutSessionModel.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  Map<String, List<WorkoutSession>> groupedSessions = {};

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyString = prefs.getString('history');
    final List<dynamic> rawList =
        historyString != null ? jsonDecode(historyString) : [];

    final List<WorkoutSession> sessions =
        rawList.map((e) => WorkoutSession.fromJson(e)).toList();

    final Map<String, List<WorkoutSession>> grouped = {};
    for (final session in sessions) {
      grouped.putIfAbsent(session.exerciseId, () => []).add(session);
    }

    setState(() {
      groupedSessions = grouped;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Ejercicios')),
      body: ListView.builder(
        itemCount: groupedSessions.length,
        itemBuilder: (context, index) {
          final exerciseId = groupedSessions.keys.elementAt(index);
          final sessions = groupedSessions[exerciseId]!;
          final totalReps = sessions.fold(0, (sum, s) => sum + s.reps);

          return ListTile(
            title: Text(sessions.first.exercise),
            subtitle: Text('${sessions.length} sesiones, $totalReps reps'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExerciseDetailScreen(
                    exerciseName: sessions.first.exercise,
                    sessions: sessions,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Pantalla 2: Lista de sesiones por ejercicio con gráficos
class ExerciseDetailScreen extends StatelessWidget {
  final String exerciseName;
  final List<WorkoutSession> sessions;

  const ExerciseDetailScreen({
    super.key,
    required this.exerciseName,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    final sortedSessions = [...sessions]
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    return Scaffold(
      appBar: AppBar(title: Text(exerciseName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📊 Duración total por día',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(height: 220, child: BarChart(_buildDurationByDayChart())),
            const SizedBox(height: 24),
            const Text('⏱ Duración por sesión',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: List.generate(
                    sortedSessions.length,
                    (index) {
                      final session = sortedSessions[index];
                      final duration =
                          session.endTime.difference(session.startTime);

                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: duration.inSeconds.toDouble(),
                            color: Colors.orange,
                            width: 16,
                            borderRadius: BorderRadius.circular(4),
                          )
                        ],
                      );
                    },
                  ),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final session = sortedSessions[groupIndex];
                        final dur =
                            session.endTime.difference(session.startTime);
                        final min = dur.inMinutes.toString().padLeft(2, '0');
                        final sec =
                            (dur.inSeconds % 60).toString().padLeft(2, '0');
                        return BarTooltipItem(
                          '⏱ $min:$sec min',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(show: false),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('📋 Lista de sesiones',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedSessions.length,
              itemBuilder: (context, index) {
                final session = sortedSessions[index];
                final duration = session.endTime.difference(session.startTime);
                return ListTile(
                  title: Text('${session.reps} reps'),
                  subtitle: Text(
                    '${session.startTime.toLocal().toString().split(".").first}\nDuración: ${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                  ),
                  trailing: const Icon(Icons.bar_chart),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SessionComparisonScreen(
                          sessions: sessions,
                          selectedSession: session,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 📊 Duración total acumulada por día de la semana
  BarChartData _buildDurationByDayChart() {
    final Map<int, int> durationByDay = {};
    for (final s in sessions) {
      final weekday = s.startTime.weekday % 7;
      final seconds = s.endTime.difference(s.startTime).inSeconds;
      durationByDay[weekday] = (durationByDay[weekday] ?? 0) + seconds;
    }

    final dayLabels = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];

    return BarChartData(
      barGroups: List.generate(7, (i) {
        final dur = durationByDay[i] ?? 0;
        return BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: dur.toDouble(),
              color: Colors.cyan,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            )
          ],
        );
      }),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, _) => Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(dayLabels[value.toInt() % 7],
                  style: TextStyle(fontSize: 12)),
            ),
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, _) {
              final totalSeconds = value.toInt();
              final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
              final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
              return Text('$minutes:$seconds',
                  style: const TextStyle(fontSize: 10));
            },
            reservedSize: 28,
          ),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(show: false),
      borderData: FlBorderData(show: false),
    );
  }
}
