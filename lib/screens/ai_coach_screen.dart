import 'package:flutter/material.dart';
import '../services/ai_fitness_coach_service.dart';
import '../services/user_storage_service.dart';

// 🤖 AI Coach Screen - Chat with your AI fitness trainer
class AICoachScreen extends StatefulWidget {
  @override
  _AICoachScreenState createState() => _AICoachScreenState();
}

class _AICoachScreenState extends State<AICoachScreen> {
  
  // 🔧 Services
  final AIFitnessCoachService _aiService = AIFitnessCoachService();
  final UserStorageService _userService = UserStorageService();
  
  // 💾 Data storage
  final TextEditingController _questionController = TextEditingController();
  final List<Map<String, String>> _chatHistory = [];
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }
  
  // 👋 Add welcome message from AI
  void _addWelcomeMessage() {
    setState(() {
      _chatHistory.add({
        'sender': 'ai',
        'message': 'Hi! I\'m your AI fitness coach! 💪\n\nI can help you with:\n• Custom workout plans\n• Exercise advice\n• Nutrition tips\n• Form corrections\n• Motivation\n\nWhat would you like to know?'
      });
    });
  }
  
  // 🗣️ Send question to AI
  Future<void> _askAI() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) return;
    
    // Add user question to chat
    setState(() {
      _chatHistory.add({
        'sender': 'user',
        'message': question
      });
      _isLoading = true;
    });
    
    _questionController.clear();
    
    try {
      // 🧠 Get user profile for personalized advice
      final userProfile = await _userService.getUserProfile();
      
      // 📞 Ask AI for advice
      final aiResponse = await _aiService.getWorkoutAdvice(question, userProfile);
      
      // Add AI response to chat
      setState(() {
        _chatHistory.add({
          'sender': 'ai',
          'message': aiResponse
        });
        _isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        _chatHistory.add({
          'sender': 'ai',
          'message': 'Sorry, I\'m having trouble connecting right now. Please try again later! 🤖'
        });
        _isLoading = false;
      });
    }
  }
  
  // 🏋️ Generate AI workout plan
  Future<void> _generateWorkoutPlan() async {
    setState(() {
      _isLoading = true;
      _chatHistory.add({
        'sender': 'user',
        'message': 'Generate me a personalized workout plan'
      });
    });
    
    try {
      // Get user preferences
      final userProfile = await _userService.getUserProfile();
      
      // 🤖 Ask AI to create workout plan
      final workoutPlan = await _aiService.generateWorkoutPlan(
        fitnessGoal: userProfile['goal'] ?? 'General fitness',
        fitnessLevel: userProfile['fitnessLevel'] ?? 'beginner',
        availableEquipment: ['Bodyweight', 'Dumbbells'],
        availableMinutes: 30,
        restrictions: userProfile['restrictions'] ?? [],
      );
      
      // Format workout plan for display
      final planText = _formatWorkoutPlan(workoutPlan);
      
      setState(() {
        _chatHistory.add({
          'sender': 'ai',
          'message': planText
        });
        _isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        _chatHistory.add({
          'sender': 'ai',
          'message': 'I couldn\'t create a workout plan right now, but try some basic exercises like push-ups, squats, and planks!'
        });
        _isLoading = false;
      });
    }
  }
  
  // 📋 Format workout plan for chat display
  String _formatWorkoutPlan(Map<String, dynamic> plan) {
    String formatted = '🏋️ **${plan['workout_name']}**\n\n';
    formatted += '⏱️ Duration: ${plan['total_duration']} minutes\n';
    formatted += '📊 Level: ${plan['difficulty_level']}\n\n';
    formatted += '**Exercises:**\n';
    
    for (var exercise in plan['exercises']) {
      formatted += '• ${exercise['name']}: ${exercise['sets']} sets x ${exercise['reps']}\n';
      formatted += '  Rest: ${exercise['rest_time']}\n\n';
    }
    
    if (plan['tips'] != null) {
      formatted += '💡 **Tips:**\n';
      for (var tip in plan['tips']) {
        formatted += '• $tip\n';
      }
    }
    
    return formatted;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Fitness Coach'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.fitness_center),
            onPressed: _generateWorkoutPlan,
            tooltip: 'Generate Workout Plan',
          ),
        ],
      ),
      body: Column(
        children: [
          
          // 💬 Chat messages area
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _chatHistory.length,
              itemBuilder: (context, index) {
                final chat = _chatHistory[index];
                final isUser = chat['sender'] == 'user';
                
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: isUser 
                        ? MainAxisAlignment.end 
                        : MainAxisAlignment.start,
                    children: [
                      
                      if (!isUser) // AI avatar
                        Container(
                          width: 40,
                          height: 40,
                          margin: EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(Icons.android, color: Colors.white),
                        ),
                      
                      // Message bubble
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUser 
                                ? Colors.blue[600] 
                                : Colors.grey[800],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            chat['message']!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      
                      if (isUser) // User avatar
                        Container(
                          width: 40,
                          height: 40,
                          margin: EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // 🤖 Loading indicator
          if (_isLoading)
            Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Text('AI is thinking...'),
                ],
              ),
            ),
          
          // ⌨️ Input area
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              border: Border(top: BorderSide(color: Colors.grey[700]!)),
            ),
            child: Row(
              children: [
                
                // Quick action buttons
                IconButton(
                  onPressed: () {
                    _questionController.text = 'What exercises should I do today?';
                  },
                  icon: Icon(Icons.help_outline),
                  tooltip: 'Quick Questions',
                ),
                
                // Text input
                Expanded(
                  child: TextField(
                    controller: _questionController,
                    decoration: InputDecoration(
                      hintText: 'Ask your AI coach anything...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16, 
                        vertical: 8
                      ),
                    ),
                    onSubmitted: (_) => _askAI(),
                  ),
                ),
                
                SizedBox(width: 8),
                
                // Send button
                FloatingActionButton(
                  onPressed: _askAI,
                  child: Icon(Icons.send),
                  mini: true,
                  backgroundColor: Colors.deepPurple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }
}