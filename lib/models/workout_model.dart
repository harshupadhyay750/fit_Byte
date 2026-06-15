class Workout {
  final int? id;
  final String title;
  final int duration; // in minutes
  final int caloriesBurned;
  final DateTime date;

  Workout({
    this.id,
    required this.title,
    required this.duration,
    required this.caloriesBurned,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'duration': duration,
      'caloriesBurned': caloriesBurned,
      'date': date.toIso8601String(),
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'],
      title: map['title'],
      duration: map['duration'],
      caloriesBurned: map['caloriesBurned'],
      date: DateTime.parse(map['date']),
    );
  }
}
