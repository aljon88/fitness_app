import 'dart:convert';
import 'package:http/http.dart' as http;

// 🤖 AI Fitness Coach - Your Smart Personal Trainer
class AIFitnessCoachService {
  
  // 🔑 Your AI API Key (like your gym membership card)
  static const String _apiKey = 'your-openai-api-key-here';
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  
  // 💬 Ask AI for workout advice
  Future<String> getWorkoutAdvice(String userQuestion, Map<String, dynamic> userProfile) async {
    
    // 📋 Build user context for AI
    final userContext = _buildUserContext(userProfile);
    
    // 🧠 Create AI prompt with user info
    final prompt = '''
You are a professional fitness coach. Help this user:

User Profile:
$userContext

User Question: $userQuestion

Provide helpful, safe, and personalized fitness advice. Keep it under 200 words.
Always remind users to consult doctors for health concerns.
''';
    
    try {
      // 📞 Call OpenAI API
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': 'gpt-3.5-turbo',  // AI model to use
          'messages': [
            {
              'role': 'system',
              'content': 'You are an expert fitness coach who gives safe, personalized advice.'
            },
            {
              'role': 'user', 
              'content': prompt
            }
          ],
          'max_tokens': 300,
          'temperature': 0.7,  // How creative the AI should be
        }),
      );
      
      if (response.statusCode == 200) {
        // ✅ AI responded successfully
        final data = json.decode(response.body);
        final aiResponse = data['choices'][0]['message']['content'];
        
        return aiResponse.trim();
        
      } else {
        throw Exception('AI service unavailable: ${response.statusCode}');
      }
      
    } catch (e) {
      print('❌ AI Error: $e');
      return _getFallbackResponse(userQuestion);
    }
  }
  
  // 🏋️ Generate personalized workout plan with AI
  Future<Map<String, dynamic>> generateWorkoutPlan({
    required String fitnessGoal,
    required String fitnessLevel, 
    required List<String> availableEquipment,
    required int availableMinutes,
    required List<String> restrictions,
  }) async {
    
    final prompt = '''
Create a personalized workout plan:

Goal: $fitnessGoal
Fitness Level: $fitnessLevel  
Equipment Available: ${availableEquipment.join(', ')}
Time Available: $availableMinutes minutes
Restrictions: ${restrictions.join(', ')}

Return a JSON workout plan with:
- workout_name
- exercises (array with name, sets, reps, rest_time)
- total_duration
- difficulty_level
- tips
''';
    
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a fitness expert. Return only valid JSON format for workout plans.'
            },
            {
              'role': 'user',
              'content': prompt
            }
          ],
          'max_tokens': 500,
          'temperature': 0.3,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final aiResponse = data['choices'][0]['message']['content'];
        
        // 📄 Parse AI's JSON response
        try {
          return json.decode(aiResponse);
        } catch (e) {
          return _getDefaultWorkoutPlan(fitnessLevel);
        }
      } else {
        return _getDefaultWorkoutPlan(fitnessLevel);
      }
      
    } catch (e) {
      print('❌ Workout generation error: $e');
      return _getDefaultWorkoutPlan(fitnessLevel);
    }
  }
  
  // 📊 AI analyzes user's progress and gives insights
  Future<String> analyzeProgress(List<Map<String, dynamic>> workoutHistory) async {
    
    // 📈 Build progress summary for AI
    final progressSummary = workoutHistory.take(10).map((workout) {
      return 'Date: ${workout['date']}, Duration: ${workout['duration']}min, Calories: ${workout['calories']}';
    }).join('\n');
    
    final prompt = '''
Analyze this user's workout progress and provide insights:

Recent Workouts:
$progressSummary

Provide:
1. Progress summary
2. What they're doing well  
3. Areas for improvement
4. Motivation message

Keep it encouraging and under 150 words.
''';
    
    try {
      final response = await _callAI(prompt);
      return response;
    } catch (e) {
      return 'Great job staying consistent! Keep up the good work and remember that progress takes time. 💪';
    }
  }
  
  // 🔧 Helper: Call AI with prompt
  Future<String> _callAI(String prompt) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: json.encode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
        'max_tokens': 250,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['choices'][0]['message']['content'].trim();
    } else {
      throw Exception('AI call failed');
    }
  }
  
  // 👤 Build user profile context for AI
  String _buildUserContext(Map<String, dynamic> profile) {
    return '''
- Age: ${profile['age'] ?? 'Not specified'}
- Goal: ${profile['goal'] ?? 'General fitness'}
- Level: ${profile['fitnessLevel'] ?? 'Beginner'}
- Restrictions: ${profile['restrictions'] ?? 'None'}
- Preferred Duration: ${profile['workoutDuration'] ?? '30'} minutes
''';
  }
  
  // 🛡️ Fallback response when AI is unavailable
  String _getFallbackResponse(String question) {
    if (question.toLowerCase().contains('workout')) {
      return 'I recommend starting with bodyweight exercises like push-ups, squats, and planks. Always warm up first!';
    } else if (question.toLowerCase().contains('diet') || question.toLowerCase().contains('nutrition')) {
      return 'Focus on whole foods, stay hydrated, and eat protein after workouts. Consult a nutritionist for personalized advice.';
    } else {
      return 'I\'m having trouble connecting right now, but keep up the great work with your fitness journey! 💪';
    }
  }
  
  // 📋 Default workout when AI fails
  Map<String, dynamic> _getDefaultWorkoutPlan(String level) {
    return {
      'workout_name': 'Basic ${level} Workout',
      'exercises': [
        {'name': 'Push-ups', 'sets': 3, 'reps': level == 'beginner' ? 8 : 12, 'rest_time': '60s'},
        {'name': 'Squats', 'sets': 3, 'reps': level == 'beginner' ? 10 : 15, 'rest_time': '60s'},
        {'name': 'Plank', 'sets': 3, 'reps': '30s hold', 'rest_time': '60s'},
      ],
      'total_duration': 20,
      'difficulty_level': level,
      'tips': ['Focus on proper form', 'Breathe steadily', 'Stay hydrated']
    };
  }
}