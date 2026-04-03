import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/real_time_calendar_service.dart';
import '../services/workout_program_loader.dart';
import '../services/navigation_service.dart';
import '../services/exercise_demo_loader.dart';
import '../services/workout_history_service.dart';
import '../models/navigation_state.dart';
import '../models/workout_history.dart';
import '../widgets/navigation_widgets.dart';
import '../widgets/ai_coach_character.dart';
import 'workout_session_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CalendarScreen extends StatefulWidget {
  final Map<String, dynamic> userProfile;

  const CalendarScreen({Key? key, required this.userProfile}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final RealTimeCalendarService _calendarService = RealTimeCalendarService();
  final WorkoutProgramLoader _programLoader = WorkoutProgramLoader();
  final WorkoutHistoryService _historyService = WorkoutHistoryService();
  final ExerciseDemoLoader _demoLoader = ExerciseDemoLoader();
  
  List<Map<String, dynamic>> _calendarDays = [];
  Map<String, dynamic>? _programData;
  bool _isLoading = true;
  DateTime? _startDate;
  int _todayProgramDay = 0;

  @override
  void initState() {
    super.initState();
    _loadCalendar();
  }

  Future<void> _loadCalendar() async {
    try {
      // Safely get user profile data with defaults
      String primaryGoal = (widget.userProfile['primaryGoal'] as String?) ?? 'Healthy Lifestyle';
      String fitnessLevel = (widget.userProfile['fitnessLevel'] as String?) ?? 'beginner';
      
      print('📅 Loading calendar for: $primaryGoal - $fitnessLevel');

      // Load program data
      _programData = await _programLoader.loadProgram(primaryGoal, fitnessLevel);
      
      // Auto-complete rest days
      await _calendarService.autoCompleteRestDays(primaryGoal, fitnessLevel);
      
      // Generate calendar
      _calendarDays = await _calendarService.generateProgramCalendar(primaryGoal, fitnessLevel);
      _startDate = await _calendarService.getStartDate();
      _todayProgramDay = await _calendarService.getTodayProgramDay();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading calendar: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0D0E21), Color(0xFF1A1B3A), Color(0xFF2D3561)],
            ),
          ),
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D0E21), Color(0xFF1A1B3A), Color(0xFF2D3561)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              NavigationHeader(
                title: _programData?['programName'] ?? 'Workout Calendar',
                subtitle: 'Your personalized gym schedule',
              ),
              
              // AI Coach
              AICoachCharacter(
                message: _getCoachMessage(),
                mood: AICoachMood.motivating,
              ),
              
              // Calendar
              Expanded(
                child: _buildCalendarView(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MainNavigationBar(currentScreen: NavigationScreen.workoutProgram),
      floatingActionButton: WorkoutCameraFAB(),
    );
  }

  Widget _buildCalendarView() {
    // Group by weeks
    List<List<Map<String, dynamic>>> weeks = [];
    List<Map<String, dynamic>> currentWeek = [];
    
    for (var day in _calendarDays) {
      currentWeek.add(day);
      if (currentWeek.length == 7) {
        weeks.add(List.from(currentWeek));
        currentWeek.clear();
      }
    }
    if (currentWeek.isNotEmpty) {
      weeks.add(currentWeek);
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: weeks.length,
      itemBuilder: (context, weekIndex) {
        return _buildWeekCard(weeks[weekIndex], weekIndex + 1);
      },
    );
  }

  Widget _buildWeekCard(List<Map<String, dynamic>> week, int weekNumber) {
    bool hasToday = week.any((day) => day['isToday']);
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasToday ? Color(0xFF6C5CE7).withOpacity(0.1) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasToday ? Color(0xFF6C5CE7) : Colors.white.withOpacity(0.1),
          width: hasToday ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Week header
          Row(
            children: [
              Text(
                'Week $weekNumber',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (hasToday) ...[
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFF6C5CE7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'THIS WEEK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              Spacer(),
              Text(
                '${DateFormat('MMM d').format(week.first['date'])} - ${DateFormat('MMM d').format(week.last['date'])}',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          
          // Days in week
          ...week.map((day) => _buildDayRow(day)).toList(),
        ],
      ),
    );
  }

  Widget _buildDayRow(Map<String, dynamic> day) {
    bool isRestDay = day['isRestDay'];
    bool isCompleted = day['isCompleted'];
    bool isToday = day['isToday'];
    bool isPast = day['isPast'];
    bool isFuture = day['isFuture'];
    
    DateTime date = day['date'];
    String dayName = day['dayOfWeek'];
    String workoutName = day['workoutName'];
    int duration = day['duration'];
    int programDay = day['programDay'];

    Color bgColor = isToday 
        ? Color(0xFF6C5CE7)
        : isRestDay 
            ? Colors.green.withOpacity(0.2)
            : Colors.white.withOpacity(0.05);
    
    Color textColor = isToday ? Colors.white : Colors.white70;
    Color iconColor = isCompleted 
        ? Colors.green 
        : isRestDay 
            ? Colors.green 
            : isToday 
                ? Colors.white 
                : Color(0xFF6C5CE7);

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: isToday ? Border.all(color: Colors.white, width: 2) : null,
      ),
      child: InkWell(
        onTap: () => _handleDayTap(day),
        child: Row(
          children: [
            // Date circle
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isCompleted 
                    ? Colors.green 
                    : isRestDay 
                        ? Colors.green.withOpacity(0.3)
                        : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName.substring(0, 3).toUpperCase(),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            
            // Workout info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Day $programDay',
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isToday) ...[
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'TODAY',
                            style: TextStyle(
                              color: Color(0xFF6C5CE7),
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    workoutName,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (!isRestDay) ...[
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.timer_outlined, color: textColor.withOpacity(0.6), size: 14),
                        SizedBox(width: 4),
                        Text(
                          '$duration min',
                          style: TextStyle(
                            color: textColor.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 12),
                        Icon(Icons.local_fire_department_outlined, color: textColor.withOpacity(0.6), size: 14),
                        SizedBox(width: 4),
                        Text(
                          '${day['calories']} cal',
                          style: TextStyle(
                            color: textColor.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            // Status icon
            Icon(
              isCompleted 
                  ? Icons.check_circle 
                  : isRestDay 
                      ? Icons.hotel_rounded 
                      : isToday 
                          ? Icons.play_circle_filled 
                          : isFuture 
                              ? Icons.lock_outline 
                              : Icons.circle_outlined,
              color: iconColor,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  void _handleDayTap(Map<String, dynamic> day) {
    if (day['isFuture']) {
      _showMessage('This workout will unlock on ${DateFormat('MMM d').format(day['date'])}', Colors.orange);
      return;
    }
    
    if (day['isRestDay']) {
      _showMessage('Rest day - recovery is essential for progress!', Colors.green);
      return;
    }
    
    if (day['isCompleted']) {
      _showMessage('Already completed! Great work!', Colors.green);
      return;
    }
    
    // Start workout
    _startWorkout(day);
  }

  void _startWorkout(Map<String, dynamic> day) async {
    try {
      // Initialize exercise demo loader
      await ExerciseDemoLoader().initialize();
      
      // Safely get user profile data with defaults
      String primaryGoal = (widget.userProfile['primaryGoal'] as String?) ?? 'Healthy Lifestyle';
      String fitnessLevel = (widget.userProfile['fitnessLevel'] as String?) ?? 'beginner';
      
      print('🏋️ Starting workout for: $primaryGoal - $fitnessLevel');
      
      // Load program
      Map<String, dynamic> program = await _programLoader.loadProgram(primaryGoal, fitnessLevel);
      print('📋 Program loaded: ${program['programName']}');
      print('📋 Program has ${program['phases'].length} phases');
      
      // Get the current phase based on program day
      int programDay = day['programDay'];
      int phaseIndex = _getPhaseIndex(programDay);
      
      print('📅 Program day: $programDay, Phase index: $phaseIndex');
      
      if (phaseIndex >= program['phases'].length) {
        _showMessage('Program phase not found', Colors.red);
        return;
      }
      
      Map<String, dynamic> phase = program['phases'][phaseIndex];
      print('📋 Phase: ${phase['phaseName']}');
      print('📋 Phase has workouts: ${phase['workouts'] != null}');
      
      // Get day of week (lowercase)
      String dayOfWeek = (day['dayOfWeek'] as String?)?.toLowerCase() ?? 'monday';
      print('📅 Day of week: $dayOfWeek');
      
      // Get workout for this day
      dynamic workoutsData = phase['workouts'];
      if (workoutsData == null) {
        print('❌ No workouts data in phase');
        _showMessage('Workout not found for this day', Colors.red);
        return;
      }
      
      // Convert to proper Map type
      Map<String, dynamic> workouts = Map<String, dynamic>.from(workoutsData as Map);
      print('📋 Available workout days: ${workouts.keys.toList()}');
      
      if (!workouts.containsKey(dayOfWeek)) {
        print('❌ Day $dayOfWeek not found in workouts');
        _showMessage('Workout not found for this day', Colors.red);
        return;
      }
      
      Map<String, dynamic> workout = Map<String, dynamic>.from(workouts[dayOfWeek] as Map);
      print('✅ Found workout: ${workout['name']}');
      
      // Get program exercises
      List<dynamic> programExercises = workout['exercises'] ?? [];
      print('📋 Workout has ${programExercises.length} exercises');
      
      // Preload exercise demo data with goal and level
      await ExerciseDemoLoader().preloadWorkoutExercises(primaryGoal, fitnessLevel, programExercises);
      
      // Merge exercise data with demo data
      List<Map<String, dynamic>> mergedExercises = ExerciseDemoLoader().mergeWorkoutExercises(primaryGoal, fitnessLevel, programExercises);
      
      // Update workout with merged exercises and calendar data
      workout['exercises'] = mergedExercises;
      workout['day'] = programDay;  // Add program day number
      workout['duration'] = workout['duration'] ?? day['duration'] ?? 25;  // Ensure duration exists
      
      print('✅ Loaded workout: ${workout['name']} with ${mergedExercises.length} exercises');
      
      // Navigate to new workout session controller
      if (!mounted) return;
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WorkoutSessionController(
            exercises: workout['exercises'] ?? [],
            onWorkoutCompleted: () async {
              // Save to workout history (SINGLE source of truth)
              await _saveWorkoutToHistory(workout, programDay);
              
              // Reload calendar (will read from workout history)
              await _loadCalendar();
              
              // Navigate back to calendar
              Navigator.pop(context);
            },
          ),
        ),
      );
    } catch (e, stackTrace) {
      print('❌ Error starting workout: $e');
      print('Stack trace: $stackTrace');
      _showMessage('Error loading workout: $e', Colors.red);
    }
  }
  
  int _getPhaseIndex(int programDay) {
    // Phase 1: Days 1-28 (Weeks 1-4)
    // Phase 2: Days 29-63 (Weeks 5-9)
    // Phase 3: Days 64-90 (Weeks 10-13)
    if (programDay <= 28) return 0;
    if (programDay <= 63) return 1;
    return 2;
  }

  String _getCoachMessage() {
    if (_calendarDays.isEmpty) return 'Loading your schedule...';
    
    int completed = _calendarDays.where((d) => d['isCompleted']).length;
    int total = _calendarDays.length;
    double progress = completed / total;
    
    if (progress == 0) {
      return 'Welcome to your personalized gym schedule! Your journey starts today! 🚀';
    } else if (progress >= 0.75) {
      return 'Incredible! You\'re in the final stretch - finish strong! 💪';
    } else if (progress >= 0.5) {
      return 'Halfway there! Your consistency is paying off! 🔥';
    } else if (progress >= 0.25) {
      return 'Great momentum! Keep following your schedule! ⭐';
    } else {
      return 'Building your routine! Stick to the schedule for best results! 💯';
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _saveWorkoutToHistory(Map<String, dynamic> workout, int programDay) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Calculate workout stats
      final exercises = workout['exercises'] as List<dynamic>? ?? [];
      int totalReps = 0;
      int totalSets = 0;
      
      List<ExerciseResult> exerciseResults = [];
      
      for (var exercise in exercises) {
        final exerciseMap = exercise as Map<String, dynamic>;
        final reps = exerciseMap['reps'] as int? ?? 0;
        final sets = exerciseMap['sets'] as int? ?? 1;
        
        totalReps += reps * sets;
        totalSets += sets;
        
        // Create exercise result
        exerciseResults.add(ExerciseResult(
          exerciseId: exerciseMap['exerciseId'] ?? '',
          exerciseName: exerciseMap['name'] ?? 'Unknown Exercise',
          targetReps: reps,
          actualReps: reps, // Assume completed
          targetSets: sets,
          completedSets: sets, // Assume completed
          completed: true,
          setResults: List.generate(sets, (index) => SetResult(
            setNumber: index + 1,
            reps: reps,
            completedAt: DateTime.now(),
          )),
        ));
      }

      // Create workout history entry
      final workoutHistory = WorkoutHistory(
        id: '${user.uid}_${programDay}_${DateTime.now().millisecondsSinceEpoch}',
        userId: user.uid,
        workoutId: 'day_$programDay',
        workoutTitle: workout['name'] ?? 'Workout Day $programDay',
        dayNumber: programDay,
        completedAt: DateTime.now(),
        durationMinutes: workout['duration'] ?? 30,
        exercises: exerciseResults,
        totalReps: totalReps,
        totalSets: totalSets,
        caloriesBurned: workout['calories'] ?? 200,
        difficulty: widget.userProfile['fitnessLevel'] ?? 'intermediate',
      );

      // Save to workout history
      await _historyService.saveWorkout(workoutHistory);
      
      print('✅ Workout saved to history: Day $programDay');
    } catch (e) {
      print('❌ Error saving workout to history: $e');
    }
  }
}
