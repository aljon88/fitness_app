import 'package:flutter/material.dart';
// import 'package:confetti/confetti.dart'; // REMOVED - not needed
import '../models/workout_history.dart';

class WorkoutSummaryScreen extends StatefulWidget {
  final WorkoutHistory workoutHistory;

  const WorkoutSummaryScreen({
    Key? key,
    required this.workoutHistory,
  }) : super(key: key);

  @override
  State<WorkoutSummaryScreen> createState() => _WorkoutSummaryScreenState();
}

class _WorkoutSummaryScreenState extends State<WorkoutSummaryScreen> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    
    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D0E21),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    SizedBox(height: 40),
                    
                    // Celebration icon
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF6C5CE7), Color(0xFF8B7FE8)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF6C5CE7).withOpacity(0.5),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.celebration_rounded,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    
                    // Title
                    Text(
                      'Workout Complete!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Amazing effort! You crushed it! 💪',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40),
                    
                    // Stats cards
                    _buildStatCard(
                      icon: Icons.timer,
                      label: 'Duration',
                      value: '${widget.workoutHistory.durationMinutes} min',
                      color: Colors.blue,
                    ),
                    SizedBox(height: 16),
                    
                    _buildStatCard(
                      icon: Icons.fitness_center,
                      label: 'Total Reps',
                      value: '${widget.workoutHistory.totalReps}',
                      color: Color(0xFF6C5CE7),
                    ),
                    SizedBox(height: 16),
                    
                    _buildStatCard(
                      icon: Icons.layers,
                      label: 'Total Sets',
                      value: '${widget.workoutHistory.totalSets}',
                      color: Colors.green,
                    ),
                    SizedBox(height: 16),
                    
                    _buildStatCard(
                      icon: Icons.local_fire_department,
                      label: 'Calories Burned',
                      value: '${widget.workoutHistory.caloriesBurned} kcal',
                      color: Colors.orange,
                    ),
                    SizedBox(height: 32),
                    
                    // Exercise breakdown
                    _buildExerciseBreakdown(),
                  ],
                ),
              ),
            ),
            
            // Done button
            _buildDoneButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF1A1B3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseBreakdown() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF1A1B3A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.checklist, color: Color(0xFF6C5CE7), size: 20),
              SizedBox(width: 8),
              Text(
                'Exercise Breakdown',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...widget.workoutHistory.exercises.map((exercise) {
            return Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    exercise.completed ? Icons.check_circle : Icons.cancel,
                    color: exercise.completed ? Colors.green : Colors.red,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.exerciseName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '${exercise.completedSets} sets • ${exercise.actualReps} reps',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDoneButton() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Color(0xFF0D0E21),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF6C5CE7),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            'Done',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
