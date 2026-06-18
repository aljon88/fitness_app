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
  final List<String> physicalRestrictions; // knee_issues, back_problems, heart_conditions, etc.
  
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
    this.physicalRestrictions = const [],
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
    List<String>? physicalRestrictions,
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
      physicalRestrictions: physicalRestrictions ?? this.physicalRestrictions,
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
      'physicalRestrictions': physicalRestrictions,
      'selectedAdvice': selectedAdvice,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name']?.toString() ?? 'User',
      age: json['age']?.toString() ?? '25',
      gender: json['gender']?.toString() ?? 'prefer_not_to_say',
      height: json['height']?.toString() ?? '170',
      weight: json['weight']?.toString() ?? '65',
      fitnessLevel: json['fitnessLevel']?.toString() ?? 'beginner',
      primaryGoal: json['primaryGoal']?.toString() ?? 'Healthy Lifestyle',
      motivation: json['motivation']?.toString() ?? 'Stay Fit',
      allergies: List<String>.from(json['allergies'] ?? []),
      physicalRestrictions: List<String>.from(json['physicalRestrictions'] ?? []),
      selectedAdvice: json['selectedAdvice']?.toString() ?? 'Start small, dream big!',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : DateTime.now(),
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
      physicalRestrictions: List<String>.from(onboardingData['physicalRestrictions'] ?? []),
      selectedAdvice: onboardingData['selectedAdvice'] as String,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
