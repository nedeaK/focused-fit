import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/workout.dart';
import '../services/workout_service.dart';

class AppState extends ChangeNotifier {
  UserProfile? _userProfile;
  List<Workout> _workouts = [];
  List<Workout> _completedWorkouts = [];
  bool _isLoading = false;

  final WorkoutService _workoutService = WorkoutService();

  UserProfile? get userProfile => _userProfile;
  List<Workout> get workouts => _workouts;
  List<Workout> get completedWorkouts => _completedWorkouts;
  bool get isLoading => _isLoading;

  AppState() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final profileJson = prefs.getString('userProfile');
      if (profileJson != null) {
        _userProfile = UserProfile.fromJson(json.decode(profileJson));
      }

      final workoutsJson = prefs.getString('workouts');
      if (workoutsJson != null) {
        final List<dynamic> workoutsList = json.decode(workoutsJson);
        _workouts = workoutsList.map((w) => Workout.fromJson(w)).toList();
      }

      final completedJson = prefs.getString('completedWorkouts');
      if (completedJson != null) {
        final List<dynamic> completedList = json.decode(completedJson);
        _completedWorkouts = completedList.map((w) => Workout.fromJson(w)).toList();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading from storage: $e');
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (_userProfile != null) {
        await prefs.setString('userProfile', json.encode(_userProfile!.toJson()));
      }

      await prefs.setString('workouts', json.encode(_workouts.map((w) => w.toJson()).toList()));
      await prefs.setString('completedWorkouts', json.encode(_completedWorkouts.map((w) => w.toJson()).toList()));
    } catch (e) {
      debugPrint('Error saving to storage: $e');
    }
  }

  void setUserProfile(UserProfile profile) {
    _userProfile = profile;
    _loadInitialWorkouts();
    _saveToStorage();
    notifyListeners();
  }

  void _loadInitialWorkouts() {
    if (_userProfile != null) {
      _workouts = _workoutService.getSampleWeeklyWorkouts(_userProfile!);
    }
  }

  Future<void> generateNewWorkout() async {
    if (_userProfile == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final newWorkout = await _workoutService.generateWorkout(_userProfile!);
      _workouts.insert(0, newWorkout);
      await _saveToStorage();
    } catch (e) {
      debugPrint('Error generating workout: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void completeWorkout(Workout workout) {
    _completedWorkouts.insert(0, workout);

    final index = _workouts.indexWhere((w) => w.id == workout.id);
    if (index != -1) {
      _workouts[index] = workout;
    }

    _saveToStorage();
    notifyListeners();
  }

  Workout? getTodayWorkout() {
    if (_workouts.isEmpty) return null;
    return _workouts.firstWhere(
      (w) => w.completedAt == null,
      orElse: () => _workouts.first,
    );
  }

  int getCurrentStreak() {
    if (_completedWorkouts.isEmpty) return 0;

    int streak = 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (int i = 0; i < _completedWorkouts.length; i++) {
      final workoutDate = _completedWorkouts[i].completedAt;
      if (workoutDate == null) continue;

      final date = DateTime(workoutDate.year, workoutDate.month, workoutDate.day);
      final daysDiff = today.difference(date).inDays;

      if (daysDiff == streak) {
        streak++;
      } else if (daysDiff > streak) {
        break;
      }
    }

    return streak;
  }

  int getThisWeekWorkoutCount() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);

    return _completedWorkouts.where((workout) {
      if (workout.completedAt == null) return false;
      final workoutDate = DateTime(
        workout.completedAt!.year,
        workout.completedAt!.month,
        workout.completedAt!.day,
      );
      return workoutDate.isAfter(weekStartDate.subtract(const Duration(days: 1)));
    }).length;
  }

  int getTotalMinutes() {
    return _completedWorkouts.fold(0, (sum, workout) => sum + workout.estimatedDuration);
  }

  List<bool> getWeeklyCompletion() {
    final now = DateTime.now();
    final List<bool> completion = List.filled(7, false);

    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: now.weekday - 1 - i));
      final dayDate = DateTime(day.year, day.month, day.day);

      completion[i] = _completedWorkouts.any((workout) {
        if (workout.completedAt == null) return false;
        final workoutDate = DateTime(
          workout.completedAt!.year,
          workout.completedAt!.month,
          workout.completedAt!.day,
        );
        return workoutDate == dayDate;
      });
    }

    return completion;
  }

  Future<void> clearProfile() async {
    _userProfile = null;
    _workouts = [];
    _completedWorkouts = [];

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }
}
