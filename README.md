# Fitness App

A comprehensive Flutter fitness app with workout plans, meal planning, and camera features for tracking exercises.

## Features

### 🔐 Authentication
- Email/password login and registration
- Google Sign-In integration
- Secure user session management

### 🏋️ Workout Plan
- 60-day beginner workout program
- Sequential day unlocking (complete Day 1 to unlock Day 2)
- Exercise demonstrations and instructions
- Progress tracking and completion status
- Workout timer and exercise guidance

### 🍽️ Meal Planning
- Personalized meal plan generation
- Multiple diet types (Balanced, Low Carb, High Protein, Vegetarian)
- Fitness goal customization (Weight Loss, Muscle Gain, Maintenance)
- 7-day meal plans with nutritional information

### 📹 Camera Integration
- Record workout videos
- Switch between front/back cameras
- Save and manage recorded workouts
- Video gallery for reviewing exercises

### 🎯 Additional Features
- Clean and intuitive UI design
- Progress tracking dashboard
- Secure logout functionality
- Responsive design for all screen sizes

## Setup Instructions

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / Xcode for mobile development
- Firebase project (for authentication)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd fitness_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication with Email/Password and Google Sign-In
   - Download configuration files:
     - `google-services.json` for Android (place in `android/app/`)
     - `GoogleService-Info.plist` for iOS (place in `ios/Runner/`)
   - Update `lib/firebase_options.dart` with your Firebase configuration

4. **Google Sign-In Setup**
   - In Firebase Console, go to Authentication > Sign-in method
   - Enable Google Sign-In provider
   - Add your app's SHA-1 fingerprint for Android

5. **Camera Permissions**
   - Permissions are already configured in `AndroidManifest.xml` and `Info.plist`
   - No additional setup required

### Running the App

```bash
# Run on connected device/emulator
flutter run

# Build for release
flutter build apk  # Android
flutter build ios  # iOS
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── models/
│   └── workout_day.dart     # Workout data models
├── providers/
│   ├── auth_provider.dart   # Authentication state management
│   └── workout_provider.dart # Workout progress management
└── screens/
    ├── login_screen.dart    # Login/registration UI
    ├── dashboard_screen.dart # Main dashboard
    ├── workout_plan_screen.dart # 60-day workout plan
    ├── workout_detail_screen.dart # Individual workout details
    ├── meal_plan_screen.dart # Meal planning interface
    └── camera_screen.dart   # Camera functionality
```

## Key Dependencies

- `firebase_core` & `firebase_auth` - Authentication
- `google_sign_in` - Google authentication
- `camera` - Camera functionality
- `provider` - State management
- `shared_preferences` - Local data storage
- `path_provider` - File system access

## Usage Guide

### First Time Setup
1. Launch the app and create an account or sign in with Google
2. Access the dashboard with four main features

### Workout Plan
1. Tap "Workout Plan" from dashboard
2. Start with Day 1 (only unlocked day initially)
3. Follow exercise instructions and demos
4. Complete all exercises to unlock the next day
5. Track your 60-day progress

### Meal Planning
1. Tap "Meal Plan" from dashboard
2. Select your fitness goal and diet preference
3. Generate a personalized 7-day meal plan
4. View detailed nutritional information

### Camera Features
1. Tap "Camera" from dashboard
2. Record workout videos for form checking
3. Switch between cameras as needed
4. Access recorded videos from the gallery

## Customization

### Adding New Exercises
Edit `workout_provider.dart` and modify the `_getExercisesForDay()` method to add custom exercises for different days.

### Meal Plan Customization
Update `meal_plan_screen.dart` and the `_getSampleMealPlan()` method to add more meal varieties and nutritional options.

### UI Theming
Modify the theme in `main.dart` to customize colors, fonts, and overall app appearance.

## Troubleshooting

### Firebase Issues
- Ensure `google-services.json` and `GoogleService-Info.plist` are properly placed
- Verify Firebase project configuration matches your app

### Camera Problems
- Check device permissions in Settings
- Ensure camera hardware is available
- Test on physical device (camera may not work in emulator)

### Build Issues
- Run `flutter clean` and `flutter pub get`
- Check Flutter and Dart SDK versions
- Verify all dependencies are compatible

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions:
- Check the troubleshooting section
- Review Flutter and Firebase documentation
- Create an issue in the repository