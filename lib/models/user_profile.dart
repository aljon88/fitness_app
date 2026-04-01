class UserProfile {
  final String id;
  final String name;
  final String age; // Stored as string from onboarding
  final String gender; // male, female, other
  final String height; // in cm (stored as string from onboarding)
  final String weight; // in kg (stored as string from onboarding)
  
  // Fitness Information
  final String fitnessLevel; // beginner, intermediate, advanced
  final String primaryGoal; // Strength, Weight Loss, Muscle Gain, Flexibility, Healthy Lifestyle
  final String motivation; // Health, Passion, Family, Goals, Self-improvement
  
  // Health & Dietary
  final List<String> allergies; // dairy, eggs, nuts, seafood, gluten
  
  // Motivational
  final String selectedAdvice; // Chosen motivational advice
  
  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.fitnessLevel,
    required this.primaryGoal,
    required this.motivation,
    this.allergies = const [],
    required this.selectedAdvice,
    required this.createdAt,
    required this.updatedAt,
  });

  double? get bmi {
    try {
      final heightValue = double.parse(height);
      final weightValue = double.parse(weight);
      final heightInMeters = heightValue / 100;
      return weightValue / (heightInMeters * heightInMeters);
    } catch (e) {
      return null;
    }
  }

  String get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue == null) return 'Unknown';
    if (bmiValue < 18.5) return 'Underweight';
    if (bmiValue < 25) return 'Normal';
    if (bmiValue < 30) return 'Overweight';
    return 'Obese';
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? age,
    String? gender,
    String? height,
    String? weight,
    String? fitnessLevel,
    String? primaryGoal,
    String? motivation,
    List<String>? allergies,
    String? selectedAdvice,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      motivation: motivation ?? this.motivation,
      allergies: allergies ?? this.allergies,
      selectedAdvice: selectedAdvice ?? this.selectedAdvice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'fitnessLevel': fitnessLevel,
      'primaryGoal': primaryGoal,
      'motivation': motivation,
      'allergies': allergies,
      'selectedAdvice': selectedAdvice,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as String,
      gender: json['gender'] as String,
      height: json['height'] as String,
      weight: json['weight'] as String,
      fitnessLevel: json['fitnessLevel'] as String,
      primaryGoal: json['primaryGoal'] as String,
      motivation: json['motivation'] as String,
      allergies: List<String>.from(json['allergies'] ?? []),
      selectedAdvice: json['selectedAdvice'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
  
  // Factory to create from onboarding data
  factory UserProfile.fromOnboarding(Map<String, dynamic> onboardingData) {
    return UserProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: onboardingData['name'] as String,
      age: onboardingData['age'] as String,
      gender: onboardingData['gender'] as String,
      height: onboardingData['height'] as String,
      weight: onboardingData['weight'] as String,
      fitnessLevel: onboardingData['fitnessLevel'] as String,
      primaryGoal: onboardingData['primaryGoal'] as String,
      motivation: onboardingData['motivation'] as String,
      allergies: List<String>.from(onboardingData['allergies'] ?? []),
      selectedAdvice: onboardingData['selectedAdvice'] as String,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
