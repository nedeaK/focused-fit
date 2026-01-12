class Exercise {
  final String name;
  final String description;
  final int sets;
  final int reps;
  final int restSeconds;
  final String muscleGroup;
  final String equipment;

  Exercise({
    required this.name,
    required this.description,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    required this.muscleGroup,
    required this.equipment,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'sets': sets,
      'reps': reps,
      'restSeconds': restSeconds,
      'muscleGroup': muscleGroup,
      'equipment': equipment,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      sets: json['sets'] ?? 3,
      reps: json['reps'] ?? 10,
      restSeconds: json['restSeconds'] ?? 60,
      muscleGroup: json['muscleGroup'] ?? '',
      equipment: json['equipment'] ?? 'Bodyweight',
    );
  }
}
