import 'dart:convert';
import 'package:http/http.dart' as http;

// 🌤️ Weather API Service - Gets weather from internet
class WeatherApiService {
  
  // This is the restaurant's phone number (API URL)
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  static const String apiKey = 'your_api_key_here'; // Like your customer ID
  
  // 📞 Call the weather restaurant to get today's weather
  Future<Map<String, dynamic>> getWeather(String cityName) async {
    try {
      // 🔗 Build the phone call (API URL)
      final url = '$baseUrl?q=$cityName&appid=$apiKey&units=metric';
      
      print('📞 Calling weather API: $url');
      
      // 📱 Make the phone call (HTTP request)
      final response = await http.get(Uri.parse(url));
      
      // 🎉 Did they answer the phone?
      if (response.statusCode == 200) {
        // ✅ Yes! They gave us the weather data
        final weatherData = json.decode(response.body);
        
        // 📦 Package the data nicely
        return {
          'temperature': weatherData['main']['temp'],
          'description': weatherData['weather'][0]['description'],
          'isGoodForOutdoor': _isGoodForOutdoorWorkout(weatherData['main']['temp']),
          'suggestion': _getWorkoutSuggestion(weatherData['main']['temp']),
        };
        
      } else {
        // ❌ Phone call failed
        throw Exception('Weather service is busy, try again later');
      }
      
    } catch (e) {
      // 🚫 No internet or API is down
      print('❌ Weather API Error: $e');
      return {
        'temperature': 25.0,
        'description': 'Unknown',
        'isGoodForOutdoor': true,
        'suggestion': 'Indoor workout recommended',
      };
    }
  }
  
  // 🤔 Decide if weather is good for outdoor workout
  bool _isGoodForOutdoorWorkout(double temperature) {
    return temperature >= 15 && temperature <= 30; // 15-30°C is good
  }
  
  // 💡 Give workout suggestion based on weather
  String _getWorkoutSuggestion(double temperature) {
    if (temperature < 10) {
      return 'Too cold! Try indoor HIIT workout';
    } else if (temperature > 35) {
      return 'Too hot! Stay inside with air conditioning';
    } else {
      return 'Perfect weather for outdoor running!';
    }
  }
}