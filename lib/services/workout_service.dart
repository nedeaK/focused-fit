import '../models/workout.dart';
import '../models/exercise.dart';
import '../models/user_profile.dart';

class WorkoutService {
  // In a real app, this would call an AI API like OpenAI or Claude
  // For now, we'll generate workouts based on user preferences using templates

  Future<Workout> generateWorkout(UserProfile profile) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    final exercises = _generateExercises(profile);
    final estimatedDuration = profile.availableTime;
    final estimatedCalories = _calculateCalories(profile.availableTime, profile.fitnessLevel);

    return Workout(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _generateWorkoutName(profile.goal),
      description: _generateDescription(profile),
      exercises: exercises,
      estimatedDuration: estimatedDuration,
      estimatedCalories: estimatedCalories,
      difficulty: profile.fitnessLevel,
    );
  }

  List<Exercise> _generateExercises(UserProfile profile) {
    final hasEquipment = profile.equipment.isNotEmpty &&
                         !profile.equipment.contains('Bodyweight Only');

    List<Exercise> exercises = [];

    switch (profile.goal) {
      case 'Build Muscle':
        exercises = _getMuscleBuilding(profile, hasEquipment);
        break;
      case 'Lose Weight':
        exercises = _getWeightLoss(profile, hasEquipment);
        break;
      case 'Improve Endurance':
        exercises = _getEndurance(profile, hasEquipment);
        break;
      case 'Increase Strength':
        exercises = _getStrength(profile, hasEquipment);
        break;
      default:
        exercises = _getGeneralFitness(profile, hasEquipment);
    }

    return exercises.take(_getExerciseCount(profile.availableTime)).toList();
  }

  int _getExerciseCount(int minutes) {
    if (minutes <= 20) return 4;
    if (minutes <= 30) return 6;
    if (minutes <= 45) return 8;
    return 10;
  }

  List<Exercise> _getMuscleBuilding(UserProfile profile, bool hasEquipment) {
    if (hasEquipment && profile.equipment.contains('Dumbbells')) {
      return [
        Exercise(
          name: 'Dumbbell Bench Press',
          description: 'Lie on bench, press dumbbells up from chest level',
          sets: 4,
          reps: 10,
          restSeconds: 90,
          muscleGroup: 'Chest',
          equipment: 'Dumbbells',
        ),
        Exercise(
          name: 'Bent Over Rows',
          description: 'Bend at hips, pull dumbbells to ribcage',
          sets: 4,
          reps: 10,
          restSeconds: 90,
          muscleGroup: 'Back',
          equipment: 'Dumbbells',
        ),
        Exercise(
          name: 'Shoulder Press',
          description: 'Press dumbbells overhead from shoulder height',
          sets: 3,
          reps: 12,
          restSeconds: 60,
          muscleGroup: 'Shoulders',
          equipment: 'Dumbbells',
        ),
        Exercise(
          name: 'Dumbbell Curls',
          description: 'Curl dumbbells up while keeping elbows stationary',
          sets: 3,
          reps: 12,
          restSeconds: 60,
          muscleGroup: 'Biceps',
          equipment: 'Dumbbells',
        ),
        Exercise(
          name: 'Tricep Extensions',
          description: 'Extend dumbbell overhead, lower behind head',
          sets: 3,
          reps: 12,
          restSeconds: 60,
          muscleGroup: 'Triceps',
          equipment: 'Dumbbells',
        ),
        Exercise(
          name: 'Goblet Squats',
          description: 'Hold dumbbell at chest, squat down keeping chest up',
          sets: 4,
          reps: 15,
          restSeconds: 90,
          muscleGroup: 'Legs',
          equipment: 'Dumbbells',
        ),
      ];
    } else {
      return [
        Exercise(
          name: 'Push-ups',
          description: 'Lower chest to ground, push back up',
          sets: 4,
          reps: 15,
          restSeconds: 60,
          muscleGroup: 'Chest',
          equipment: 'Bodyweight',
        ),
        Exercise(
          name: 'Pike Push-ups',
          description: 'Hips high, lower head toward ground',
          sets: 3,
          reps: 12,
          restSeconds: 60,
          muscleGroup: 'Shoulders',
          equipment: 'Bodyweight',
        ),
        Exercise(
          name: 'Bodyweight Squats',
          description: 'Squat down keeping chest up, drive through heels',
          sets: 4,
          reps: 20,
          restSeconds: 60,
          muscleGroup: 'Legs',
          equipment: 'Bodyweight',
        ),
        Exercise(
          name: 'Diamond Push-ups',
          description: 'Hands close together forming diamond, lower chest down',
          sets: 3,
          reps: 10,
          restSeconds: 60,
          muscleGroup: 'Triceps',
          equipment: 'Bodyweight',
        ),
        Exercise(
          name: 'Plank',
          description: 'Hold straight body position on forearms',
          sets: 3,
          reps: 60,
          restSeconds: 45,
          muscleGroup: 'Core',
          equipment: 'Bodyweight',
        ),
      ];
    }
  }

  List<Exercise> _getWeightLoss(UserProfile profile, bool hasEquipment) {
    return [
      Exercise(
        name: 'Burpees',
        description: 'Drop down, push-up, jump up explosively',
        sets: 4,
        reps: 15,
        restSeconds: 45,
        muscleGroup: 'Full Body',
        equipment: 'Bodyweight',
      ),
      Exercise(
        name: 'Mountain Climbers',
        description: 'Plank position, drive knees to chest alternating',
        sets: 4,
        reps: 20,
        restSeconds: 30,
        muscleGroup: 'Core/Cardio',
        equipment: 'Bodyweight',
      ),
      Exercise(
        name: 'Jump Squats',
        description: 'Squat down, explode up into jump',
        sets: 4,
        reps: 15,
        restSeconds: 45,
        muscleGroup: 'Legs',
        equipment: 'Bodyweight',
      ),
      Exercise(
        name: 'High Knees',
        description: 'Run in place bringing knees to chest height',
        sets: 4,
        reps: 30,
        restSeconds: 30,
        muscleGroup: 'Cardio',
        equipment: 'Bodyweight',
      ),
      Exercise(
        name: 'Plank Jacks',
        description: 'Plank position, jump feet out and in',
        sets: 3,
        reps: 20,
        restSeconds: 30,
        muscleGroup: 'Core',
        equipment: 'Bodyweight',
      ),
      Exercise(
        name: 'Jumping Jacks',
        description: 'Jump feet out while raising arms overhead',
        sets: 3,
        reps: 30,
        restSeconds: 30,
        muscleGroup: 'Cardio',
        equipment: 'Bodyweight',
      ),
    ];
  }

  List<Exercise> _getEndurance(UserProfile profile, bool hasEquipment) {
    return [
      Exercise(
        name: 'Jump Rope',
        description: 'Continuous jumping with rope or simulated',
        sets: 5,
        reps: 60,
        restSeconds: 30,
        muscleGroup: 'Cardio',
        equipment: hasEquipment ? 'Jump Rope' : 'Bodyweight',
      ),
      Exercise(
        name: 'High Knees',
        description: 'Run in place with knees high',
        sets: 4,
        reps: 45,
        restSeconds: 30,
        muscleGroup: 'Cardio',
        equipment: 'Bodyweight',
      ),
      Exercise(
        name: 'Butt Kickers',
        description: 'Run in place kicking heels to glutes',
        sets: 4,
        reps: 45,
        restSeconds: 30,
        muscleGroup: 'Cardio',
        equipment: 'Bodyweight',
      ),
      Exercise(
        name: 'Mountain Climbers',
        description: 'Fast alternating knee drives from plank',
        sets: 4,
        reps: 30,
        restSeconds: 30,
        muscleGroup: 'Core/Cardio',
        equipment: 'Bodyweight',
      ),
      Exercise(
        name: 'Lateral Shuffles',
        description: 'Side-to-side shuffling movement',
        sets: 4,
        reps: 20,
        restSeconds: 30,
        muscleGroup: 'Legs/Cardio',
        equipment: 'Bodyweight',
      ),
    ];
  }

  List<Exercise> _getStrength(UserProfile profile, bool hasEquipment) {
    if (hasEquipment && profile.equipment.contains('Dumbbells')) {
      return [
        Exercise(
          name: 'Dumbbell Deadlift',
          description: 'Hinge at hips, lower dumbbells to shins, drive up',
          sets: 5,
          reps: 6,
          restSeconds: 120,
          muscleGroup: 'Back/Legs',
          equipment: 'Dumbbells',
        ),
        Exercise(
          name: 'Heavy Goblet Squat',
          description: 'Hold heavy dumbbell, deep squat',
          sets: 5,
          reps: 6,
          restSeconds: 120,
          muscleGroup: 'Legs',
          equipment: 'Dumbbells',
        ),
        Exercise(
          name: 'Single Leg Romanian Deadlift',
          description: 'Balance on one leg, hinge forward with dumbbell',
          sets: 4,
          reps: 8,
          restSeconds: 90,
          muscleGroup: 'Legs/Back',
          equipment: 'Dumbbells',
        ),
      ];
    } else {
      return [
        Exercise(
          name: 'Pistol Squats',
          description: 'Single leg squat, other leg extended forward',
          sets: 4,
          reps: 8,
          restSeconds: 90,
          muscleGroup: 'Legs',
          equipment: 'Bodyweight',
        ),
        Exercise(
          name: 'Decline Push-ups',
          description: 'Feet elevated, perform push-ups',
          sets: 4,
          reps: 12,
          restSeconds: 90,
          muscleGroup: 'Chest',
          equipment: 'Bodyweight',
        ),
        Exercise(
          name: 'Nordic Curls',
          description: 'Kneel, slowly lower torso forward',
          sets: 3,
          reps: 6,
          restSeconds: 120,
          muscleGroup: 'Hamstrings',
          equipment: 'Bodyweight',
        ),
      ];
    }
  }

  List<Exercise> _getGeneralFitness(UserProfile profile, bool hasEquipment) {
    return [
      Exercise(
        name: 'Push-ups',
        description: 'Standard push-up form, chest to ground',
        sets: 3,
        reps: 15,
        restSeconds: 60,
        muscleGroup: 'Chest',
        equipment: 'Bodyweight',
      ),
      Exercise(
        name: 'Bodyweight Squats',
        description: 'Squat to parallel, drive up through heels',
        sets: 3,
        reps: 20,
        restSeconds: 60,
        muscleGroup: 'Legs',
        equipment: 'Bodyweight',
      ),
      Exercise(
        name: 'Plank',
        description: 'Hold straight body on forearms',
        sets: 3,
        reps: 45,
        restSeconds: 45,
        muscleGroup: 'Core',
        equipment: 'Bodyweight',
      ),
      Exercise(
        name: 'Lunges',
        description: 'Step forward, lower back knee toward ground',
        sets: 3,
        reps: 12,
        restSeconds: 60,
        muscleGroup: 'Legs',
        equipment: 'Bodyweight',
      ),
      Exercise(
        name: 'Glute Bridges',
        description: 'Lie on back, drive hips up squeezing glutes',
        sets: 3,
        reps: 15,
        restSeconds: 45,
        muscleGroup: 'Glutes',
        equipment: 'Bodyweight',
      ),
      Exercise(
        name: 'Jumping Jacks',
        description: 'Full body cardio movement',
        sets: 3,
        reps: 30,
        restSeconds: 30,
        muscleGroup: 'Cardio',
        equipment: 'Bodyweight',
      ),
    ];
  }

  String _generateWorkoutName(String goal) {
    switch (goal) {
      case 'Build Muscle':
        return 'Muscle Building Session';
      case 'Lose Weight':
        return 'Fat Burning Circuit';
      case 'Improve Endurance':
        return 'Endurance Training';
      case 'Increase Strength':
        return 'Strength Power Workout';
      default:
        return 'Full Body Workout';
    }
  }

  String _generateDescription(UserProfile profile) {
    return 'A personalized ${profile.fitnessLevel.toLowerCase()} workout designed for ${profile.goal.toLowerCase()}, optimized for your available equipment and ${profile.availableTime} minute time frame.';
  }

  int _calculateCalories(int minutes, String level) {
    final baseCalories = minutes * 5;
    switch (level) {
      case 'Beginner':
        return (baseCalories * 0.8).round();
      case 'Advanced':
        return (baseCalories * 1.2).round();
      default:
        return baseCalories;
    }
  }

  // Get sample workouts for the week
  List<Workout> getSampleWeeklyWorkouts(UserProfile profile) {
    return [
      Workout(
        id: '1',
        name: 'Upper Body Strength',
        description: 'Focus on chest, back, and arms',
        exercises: _getMuscleBuilding(profile, profile.equipment.isNotEmpty).take(6).toList(),
        estimatedDuration: 45,
        estimatedCalories: 320,
        difficulty: 'Intermediate',
        completedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Workout(
        id: '2',
        name: 'Cardio Burn',
        description: 'High intensity cardio workout',
        exercises: _getWeightLoss(profile, false).take(6).toList(),
        estimatedDuration: 30,
        estimatedCalories: 280,
        difficulty: 'Intermediate',
        completedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Workout(
        id: '3',
        name: 'Lower Body Power',
        description: 'Leg focused strength training',
        exercises: _getStrength(profile, profile.equipment.isNotEmpty).take(5).toList(),
        estimatedDuration: 40,
        estimatedCalories: 300,
        difficulty: 'Intermediate',
      ),
    ];
  }
}
