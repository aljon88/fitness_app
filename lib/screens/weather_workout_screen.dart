import 'package:flutter/material.dart';
import '../services/weather_api_service.dart';

// 🌤️ Screen that shows weather and workout suggestions
class WeatherWorkoutScreen extends StatefulWidget {
  @override
  _WeatherWorkoutScreenState createState() => _WeatherWorkoutScreenState();
}

class _WeatherWorkoutScreenState extends State<WeatherWorkoutScreen> {
  
  // 🔧 Tools we need
  final WeatherApiService _weatherService = WeatherApiService();
  
  // 📊 Data storage
  Map<String, dynamic>? weatherData;
  bool isLoading = false;
  String errorMessage = '';
  
  // 🎬 When screen starts
  @override
  void initState() {
    super.initState();
    _getWeatherData(); // Get weather immediately
  }
  
  // 📞 Call the API to get weather
  Future<void> _getWeatherData() async {
    setState(() {
      isLoading = true; // Show loading spinner
      errorMessage = '';
    });
    
    try {
      // 🌐 Call the weather API (like calling restaurant)
      final data = await _weatherService.getWeather('London');
      
      setState(() {
        weatherData = data; // Save the weather data
        isLoading = false;  // Hide loading spinner
      });
      
    } catch (e) {
      setState(() {
        errorMessage = 'Could not get weather: $e';
        isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather & Workouts'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            
            // 🔄 Show loading spinner while calling API
            if (isLoading)
              Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Getting weather data...'),
                ],
              ),
            
            // ❌ Show error if API call failed
            if (errorMessage.isNotEmpty)
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red[800]),
                ),
              ),
            
            // ✅ Show weather data from API
            if (weatherData != null) ...[
              
              // 🌡️ Temperature display
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[400]!, Colors.blue[600]!],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Text(
                      '${weatherData!['temperature'].round()}°C',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      weatherData!['description'],
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 20),
              
              // 💡 Workout suggestion from API
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: weatherData!['isGoodForOutdoor'] 
                      ? Colors.green[100] 
                      : Colors.orange[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Icon(
                      weatherData!['isGoodForOutdoor'] 
                          ? Icons.wb_sunny 
                          : Icons.home,
                      size: 40,
                      color: weatherData!['isGoodForOutdoor'] 
                          ? Colors.green 
                          : Colors.orange,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Workout Suggestion:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      weatherData!['suggestion'],
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 20),
              
              // 🔄 Refresh button to call API again
              ElevatedButton(
                onPressed: _getWeatherData,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 5),
                    Text('Refresh Weather'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}