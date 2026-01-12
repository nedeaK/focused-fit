import 'exercise.dart';

class Workout {
  final String id;
  final String name;
  final String description;
  final List<Exercise> exercises;
  final int estimatedDuration;
  final int estimatedCalories;
  final String difficulty;
  final DateTime? completedAt;

  Workout({
    required this.id,
    required this.name,
    required this.description,
    required this.exercises,
    required this.estimatedDuration,
    required this.estimatedCalories,
    required this.difficulty,
    this.completedAt,
  });

  Workout copyWith({
    String? id,
    String? name,
    String? description,
    List<Exercise>? exercises,
    int? estimatedDuration,
    int? estimatedCalories,
    String? difficulty,
    DateTime? completedAt,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      estimatedCalories: estimatedCalories ?? this.estimatedCalories,
      difficulty: difficulty ?? this.difficulty,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'estimatedDuration': estimatedDuration,
      'estimatedCalories': estimatedCalories,
      'difficulty': difficulty,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      exercises: (json['exercises'] as List? ?? [])
          .map((e) => Exercise.fromJson(e))
          .toList(),
      estimatedDuration: json['estimatedDuration'] ?? 30,
      estimatedCalories: json['estimatedCalories'] ?? 200,
      difficulty: json['difficulty'] ?? 'Intermediate',
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }
}
