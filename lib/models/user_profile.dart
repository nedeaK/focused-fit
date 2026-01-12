class UserProfile {
  final String name;
  final String goal;
  final String fitnessLevel;
  final List<String> equipment;
  final int availableTime;
  final int workoutsPerWeek;
  final List<String> injuries;

  UserProfile({
    required this.name,
    required this.goal,
    required this.fitnessLevel,
    required this.equipment,
    required this.availableTime,
    required this.workoutsPerWeek,
    this.injuries = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'goal': goal,
      'fitnessLevel': fitnessLevel,
      'equipment': equipment,
      'availableTime': availableTime,
      'workoutsPerWeek': workoutsPerWeek,
      'injuries': injuries,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      goal: json['goal'] ?? '',
      fitnessLevel: json['fitnessLevel'] ?? '',
      equipment: List<String>.from(json['equipment'] ?? []),
      availableTime: json['availableTime'] ?? 30,
      workoutsPerWeek: json['workoutsPerWeek'] ?? 3,
      injuries: List<String>.from(json['injuries'] ?? []),
    );
  }
}
