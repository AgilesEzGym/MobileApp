class WorkoutSession {
  final String exerciseId;
  final String exercise;
  final int reps;
  final DateTime startTime;
  final DateTime endTime;
  final String user;

  WorkoutSession({
    required this.exerciseId,
    required this.exercise,
    required this.reps,
    required this.startTime,
    required this.endTime,
    required this.user,
  });

  Map<String, dynamic> toJson() {
    final duration = endTime.difference(startTime);
    final weekdayIndex = startTime.weekday % 7; // 1 = Monday...7 = Sunday
    final dayOfWeek = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ][weekdayIndex];

    return {
      "exerciseId": exerciseId,
      "exercise": exercise,
      "reps": reps,
      "duration_seconds": duration.inSeconds,
      "duration_formatted":
          "${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}",
      "start_time": startTime.toIso8601String(),
      "end_time": endTime.toIso8601String(),
      "date_only": startTime.toIso8601String().split("T").first,
      "hour_only":
          "${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}",
      "day_of_week": dayOfWeek,
      "weekday_index": weekdayIndex,
      "user": user,
    };
  }

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      exerciseId: json["exerciseId"] ?? '',
      exercise: json["exercise"] ?? '',
      reps: json["reps"] ?? 0,
      startTime: DateTime.parse(json["start_time"]),
      endTime: DateTime.parse(json["end_time"]),
      user: json["user"] ?? '',
    );
  }
}
