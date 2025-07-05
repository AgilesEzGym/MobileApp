import 'dart:convert';
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

// Pantalla 2: Lista de sesiones por ejercicio
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
    return Scaffold(
      appBar: AppBar(title: Text(exerciseName)),
      body: ListView.builder(
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          final session = sessions[index];
          final duration = session.endTime.difference(session.startTime);

          return ListTile(
            title: Text('${session.reps} reps'),
            subtitle: Text(
              '${session.startTime.toLocal().toString().split(".").first}\nDuracion: ${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
            ),
          );
        },
      ),
    );
  }
}
