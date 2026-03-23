import 'package:flutter/material.dart';
import '../models/workout_day.dart';

class WorkoutProvider extends ChangeNotifier {
  List<WorkoutDay> _workoutDays = [];
  int _currentDay = 1;
  bool _isLoading = false;

  List<WorkoutDay> get workoutDays => _workoutDays;
  int get currentDay => _currentDay;
  bool get isLoading => _isLoading;

  WorkoutProvider() {
    _initializeWorkoutPlan();
  }

  void _initializeWorkoutPlan() {
    _workoutDays = List.generate(60, (index) {
      return WorkoutDay(
        day: index + 1,
        title: 'Day ${index + 1} Workout',
        exercises: _getExercisesForDay(index + 1),
        isCompleted: false,
        isUnlocked: index == 0, // Only day 1 is unlocked initially
      );
    });
  }

  List<Exercise> _getExercisesForDay(int day) {
    // Sample exercises - you can expand this based on your workout plan
    if (day <= 20) {
      return [
        Exercise(name: 'Push-ups', sets: 3, reps: 10, duration: null),
        Exercise(name: 'Squats', sets: 3, reps: 15, duration: null),
        Exercise(name: 'Plank', sets: 1, reps: null, duration: 30),
      ];
    } else if (day <= 40) {
      return [
        Exercise(name: 'Push-ups', sets: 3, reps: 15, duration: null),
        Exercise(name: 'Squats', sets: 3, reps: 20, duration: null),
        Exercise(name: 'Plank', sets: 2, reps: null, duration: 45),
        Exercise(name: 'Lunges', sets: 3, reps: 10, duration: null),
      ];
    } else {
      return [
        Exercise(name: 'Push-ups', sets: 4, reps: 20, duration: null),
        Exercise(name: 'Squats', sets: 4, reps: 25, duration: null),
        Exercise(name: 'Plank', sets: 3, reps: null, duration: 60),
        Exercise(name: 'Lunges', sets: 3, reps: 15, duration: null),
        Exercise(name: 'Burpees', sets: 3, reps: 8, duration: null),
      ];
    }
  }

  Future<void> completeDay(int day) async {
    if (day <= _workoutDays.length) {
      _workoutDays[day - 1].isCompleted = true;
      
      // Unlock next day
      if (day < _workoutDays.length) {
        _workoutDays[day].isUnlocked = true;
      }
      
      _currentDay = day + 1;
      notifyListeners();
    }
  }

  void resetProgress() async {
    _currentDay = 1;
    for (var day in _workoutDays) {
      day.isCompleted = false;
      day.isUnlocked = false;
    }
    _workoutDays[0].isUnlocked = true; // Unlock day 1
    
    notifyListeners();
  }
}