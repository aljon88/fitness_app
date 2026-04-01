# Requirements Document

## Introduction

This document specifies requirements for a comprehensive goal-based workout system for a fitness app. The system will provide 15 distinct workout programs (3 fitness levels × 5 goals), implement a flexible calendar system that adjusts to user behavior, align meal plans with workout goals, and provide exercise demonstrations with proper form guidance. The system replaces the current fitness-level-only approach with a goal-driven methodology that adapts to real-world usage patterns.

## Glossary

- **Workout_Program**: A structured exercise plan spanning multiple days with specific exercises, sets, reps, and rest periods
- **Fitness_Level**: User's current physical capability from profile (beginner, intermediate, or advanced)
- **Primary_Goal**: User's desired fitness outcome from profile (Strength, Weight Loss, Muscle Gain, Flexibility, or Healthy Lifestyle)
- **Program_Day**: A sequential day number in the workout program (Day 1, Day 2, etc.)
- **Calendar_Day**: An actual calendar date (Monday, Tuesday, etc.)
- **Rest_Day**: A scheduled day without workout exercises for recovery
- **Workout_Split**: The organization of exercises targeting specific muscle groups on specific days
- **Sequential_Unlocking**: A system where users must complete previous workouts before accessing new ones
- **Flexible_Schedule**: A calendar system that adjusts workout dates when users miss scheduled sessions
- **Exercise_Demo**: An animated GIF showing proper exercise form
- **Target_Muscle**: The primary muscle group worked by an exercise
- **Meal_Plan**: A nutrition guide aligned with workout goals and user allergies
- **Macro**: Macronutrient (protein, carbohydrates, fats)
- **Allergen**: A food ingredient that causes allergic reactions (stored in profile `allergies` field)
- **Round_Trip_Property**: A property where parsing then printing produces equivalent output
- **Program_Loader**: Service that loads workout program data from JSON files
- **Calendar_Service**: Service that manages workout scheduling and rest day logic
- **User_Profile**: Existing user profile data collected during onboarding (contains fitnessLevel, primaryGoal, allergies, etc.)

## Requirements

### Requirement 1: Workout Program Selection

**User Story:** As a user, I want the app to select a workout program based on both my fitness level and my goal, so that I receive training optimized for my specific needs.

#### Acceptance Criteria

1. WHEN a user profile contains `fitnessLevel` and `primaryGoal`, THE Program_Loader SHALL load the corresponding Workout_Program JSON file
2. THE System SHALL support exactly 15 Workout_Programs (3 Fitness_Levels × 5 Primary_Goals)
3. FOR ALL valid `fitnessLevel` and `primaryGoal` combinations, THE Program_Loader SHALL return a valid Workout_Program
4. IF a Workout_Program file does not exist for the combination, THEN THE System SHALL return an error message indicating the missing program
5. THE System SHALL store Workout_Program files at path `assets/data/programs/{level}/{level}_{goal}.json`
6. THE System SHALL map `primaryGoal` values from profile: "Strength" → strength, "Weight Loss" → weight_loss, "Muscle Gain" → muscle_gain, "Flexibility" → flexibility, "Healthy Lifestyle" → general_fitness

### Requirement 2: Fitness Level Program Duration

**User Story:** As a user, I want program duration appropriate to my fitness level, so that I can progress safely without overtraining.

#### Acceptance Criteria

1. WHEN Fitness_Level is Beginner, THE Workout_Program SHALL have a duration of 90 days
2. WHEN Fitness_Level is Intermediate, THE Workout_Program SHALL have a duration of 60 days
3. WHEN Fitness_Level is Advanced, THE Workout_Program SHALL have a duration of 30 days
4. FOR ALL Workout_Programs, THE duration SHALL match the Fitness_Level specification

### Requirement 3: Workout Frequency by Fitness Level

**User Story:** As a user, I want workout frequency matched to my fitness level, so that I have adequate recovery time.

#### Acceptance Criteria

1. WHEN Fitness_Level is Beginner, THE Workout_Program SHALL schedule 4 workouts per week
2. WHEN Fitness_Level is Intermediate, THE Workout_Program SHALL schedule 5 workouts per week
3. WHEN Fitness_Level is Advanced, THE Workout_Program SHALL schedule 6 workouts per week
4. FOR ALL Fitness_Levels, THE total workout count SHALL equal (weeks × workouts_per_week)

### Requirement 4: Rest Day Scheduling

**User Story:** As a user, I want rest days scheduled based on my fitness level, so that my body has time to recover.

#### Acceptance Criteria

1. WHEN Fitness_Level is Beginner, THE Calendar_Service SHALL schedule Rest_Days on Tuesday, Thursday, and Sunday
2. WHEN Fitness_Level is Intermediate, THE Calendar_Service SHALL schedule Rest_Days on Wednesday and Sunday
3. WHEN Fitness_Level is Advanced, THE Calendar_Service SHALL schedule Rest_Days on Sunday only
4. FOR ALL Rest_Days, THE Calendar_Service SHALL auto-complete them when the Calendar_Day arrives
5. THE System SHALL NOT require user action to complete Rest_Days

### Requirement 5: Goal-Based Workout Splits

**User Story:** As a user, I want workout exercises organized by my goal, so that my training targets my desired outcome.

#### Acceptance Criteria

1. WHEN `primaryGoal` is "Weight Loss", THE Workout_Program SHALL emphasize cardio exercises (HIIT, full body circuits, burpees, jumping jacks, mountain climbers)
2. WHEN `primaryGoal` is "Muscle Gain", THE Workout_Program SHALL use strength splits (Chest/Triceps, Back/Biceps, Legs, Shoulders/Abs)
3. WHEN `primaryGoal` is "Strength", THE Workout_Program SHALL use power-focused splits (Push, Pull, Legs)
4. WHEN `primaryGoal` is "Flexibility", THE Workout_Program SHALL emphasize mobility and stretching exercises
5. WHEN `primaryGoal` is "Healthy Lifestyle", THE Workout_Program SHALL provide balanced exercise variety (mapped to general_fitness program)
6. FOR ALL Workout_Programs, THE exercises SHALL use bodyweight only (no equipment except wall space)

### Requirement 6: Flexible Calendar System

**User Story:** As a user, I want the workout schedule to adjust when I miss workouts, so that I can stay on track despite life interruptions.

#### Acceptance Criteria

1. WHEN a user starts a Workout_Program, THE Calendar_Service SHALL record the start date
2. WHEN the current Calendar_Day advances, THE Calendar_Service SHALL calculate the current Program_Day
3. WHEN a user misses a workout on a Calendar_Day, THE System SHALL show the same Program_Day on the next Calendar_Day
4. FOR ALL Program_Days, THE System SHALL maintain sequential order regardless of Calendar_Days
5. THE System SHALL NOT skip Program_Days when Calendar_Days advance

### Requirement 7: Sequential Workout Unlocking

**User Story:** As a user, I want to complete workouts in order, so that I progress safely through the program.

#### Acceptance Criteria

1. THE System SHALL unlock Program_Day 1 immediately when a Workout_Program starts
2. WHEN a user completes Program_Day N, THE System SHALL unlock Program_Day N+1
3. WHEN a user has not completed Program_Day N, THE System SHALL keep Program_Day N+1 locked
4. FOR ALL Program_Days greater than 1, THE System SHALL require completion of the previous Program_Day
5. WHEN a user attempts to access a locked Program_Day, THE System SHALL display a message indicating completion of the previous day is required

### Requirement 8: Workout Program Data Structure

**User Story:** As a developer, I want workout programs stored in a consistent JSON format, so that the system can reliably load and parse program data.

#### Acceptance Criteria

1. THE Workout_Program JSON SHALL include fields: programId, name, fitnessLevel, goal, duration, workoutsPerWeek, restDays, and phases
2. THE Workout_Program JSON SHALL organize exercises into phases with weekly schedules
3. FOR ALL exercises in the JSON, THE System SHALL include: id, name, targetMuscle, sets, reps, rest, demo, and instructions
4. THE System SHALL validate JSON structure when loading Workout_Programs
5. IF JSON structure is invalid, THEN THE System SHALL return a descriptive error message

### Requirement 9: Exercise Demonstration Library

**User Story:** As a user, I want to see animated demonstrations of exercises, so that I can perform them with proper form.

#### Acceptance Criteria

1. THE System SHALL provide Exercise_Demo GIFs for each unique exercise
2. THE System SHALL store Exercise_Demo files at path `assets/data/exercises/demos/*.gif`
3. WHEN a user views an exercise, THE System SHALL display the corresponding Exercise_Demo
4. FOR ALL exercises, THE System SHALL show Target_Muscle information
5. THE System SHALL maintain an exercise library with 50 to 100 unique exercises

### Requirement 10: Goal-Aligned Meal Plans

**User Story:** As a user, I want meal recommendations aligned with my workout goal, so that my nutrition supports my training.

#### Acceptance Criteria

1. WHEN `primaryGoal` is "Weight Loss", THE Meal_Plan SHALL provide meals with 300-400 calories, high protein, and low carbohydrates
2. WHEN `primaryGoal` is "Muscle Gain", THE Meal_Plan SHALL provide meals with 500-600 calories, very high protein, and moderate carbohydrates
3. WHEN `primaryGoal` is "Strength", THE Meal_Plan SHALL provide meals with 400-500 calories and balanced Macros
4. WHEN `primaryGoal` is "Flexibility", THE Meal_Plan SHALL provide anti-inflammatory meals rich in omega-3 fatty acids
5. WHEN `primaryGoal` is "Healthy Lifestyle", THE Meal_Plan SHALL provide balanced nutrition with variety
6. THE System SHALL store 40 to 50 recipes in `assets/data/meals/recipes.json`

### Requirement 11: Workout Day vs Rest Day Meal Adjustment

**User Story:** As a user, I want different meal recommendations on workout days versus rest days, so that my calorie intake matches my activity level.

#### Acceptance Criteria

1. WHEN the current Program_Day is a workout day, THE Meal_Plan SHALL increase calories by 200-300 above baseline
2. WHEN the current Program_Day is a Rest_Day, THE Meal_Plan SHALL use baseline calorie amounts
3. WHEN the current Program_Day is a workout day, THE Meal_Plan SHALL increase carbohydrate portions
4. WHEN the current Program_Day is a Rest_Day, THE Meal_Plan SHALL reduce carbohydrate portions
5. FOR ALL workout days, THE Meal_Plan SHALL include post-workout protein recommendations

### Requirement 12: Allergen Filtering

**User Story:** As a user with food allergies, I want meals filtered to exclude my allergens, so that I can safely follow the meal plan.

#### Acceptance Criteria

1. THE System SHALL support filtering for these Allergens: dairy, eggs, nuts, seafood, gluten (matching profile `allergies` field values)
2. WHEN a user profile contains `allergies` list, THE Meal_Plan SHALL exclude recipes containing those Allergens
3. FOR ALL recipes, THE System SHALL tag ingredients with applicable Allergen information
4. WHEN no recipes match the Allergen filters, THE System SHALL display a message indicating insufficient recipe options
5. THE System SHALL allow users to select multiple Allergens simultaneously during onboarding

### Requirement 13: Recipe Data Structure

**User Story:** As a developer, I want recipes stored in a consistent JSON format, so that the system can reliably filter and display meal information.

#### Acceptance Criteria

1. THE recipe JSON SHALL include fields: name, ingredients, instructions, nutrition (calories, protein, carbs, fats, fiber), prepTime, cookTime, goalTags, and allergenTags
2. THE System SHALL validate recipe JSON structure when loading recipes
3. FOR ALL recipes, THE nutrition field SHALL contain measurable values for calories, protein, carbohydrates, and fats
4. IF recipe JSON structure is invalid, THEN THE System SHALL return a descriptive error message
5. THE System SHALL parse recipe JSON and print it back to equivalent JSON (round-trip property)

### Requirement 14: Exercise Library Data Structure

**User Story:** As a developer, I want exercises stored in a centralized library, so that multiple programs can reference the same exercise data.

#### Acceptance Criteria

1. THE System SHALL maintain an exercise library at `assets/data/exercises/exercise_library.json`
2. THE exercise library JSON SHALL include fields: id, name, description, instructions, category, difficulty, duration, reps, sets, restTime, targetMuscles, equipment, tips, commonMistakes, and caloriesBurned
3. FOR ALL exercises, THE System SHALL assign a unique id
4. WHEN a Workout_Program references an exercise, THE System SHALL use the exercise id
5. THE System SHALL parse exercise library JSON and print it back to equivalent JSON (round-trip property)

### Requirement 15: Program Progress Tracking

**User Story:** As a user, I want to see my progress through the program, so that I stay motivated and understand how far I've come.

#### Acceptance Criteria

1. THE System SHALL display the current Program_Day and total program duration
2. THE System SHALL calculate and display the percentage of completed Program_Days
3. THE System SHALL display the count of completed workout days (excluding Rest_Days)
4. WHEN a user completes a Program_Day, THE System SHALL update the progress display immediately
5. THE System SHALL persist progress data so it survives app restarts

### Requirement 16: Program Start Date Persistence

**User Story:** As a user, I want my program start date remembered, so that the calendar system works correctly across app sessions.

#### Acceptance Criteria

1. WHEN a user starts a Workout_Program, THE Calendar_Service SHALL save the start date to persistent storage
2. WHEN the app restarts, THE Calendar_Service SHALL load the saved start date
3. THE Calendar_Service SHALL calculate Program_Day based on the difference between current date and start date
4. IF no start date exists, THE Calendar_Service SHALL return a default value indicating no active program
5. THE System SHALL store the start date in ISO 8601 format

### Requirement 17: Completed Days Persistence

**User Story:** As a user, I want my completed workouts remembered, so that I don't lose progress when I close the app.

#### Acceptance Criteria

1. WHEN a user completes a Program_Day, THE System SHALL save the Program_Day number to persistent storage
2. WHEN the app restarts, THE System SHALL load all completed Program_Day numbers
3. THE System SHALL store completed days as a JSON array of integers
4. FOR ALL Program_Days, THE System SHALL check completion status against the persisted list
5. THE System SHALL parse completed days JSON and print it back to equivalent JSON (round-trip property)

### Requirement 18: Program Reset Functionality

**User Story:** As a user, I want to reset my program, so that I can start over if needed.

#### Acceptance Criteria

1. WHEN a user requests a program reset, THE System SHALL clear the saved start date
2. WHEN a user requests a program reset, THE System SHALL clear all completed Program_Day records
3. WHEN a user requests a program reset, THE System SHALL unlock only Program_Day 1
4. WHEN a user requests a program reset, THE System SHALL reset progress display to 0%
5. THE System SHALL require user confirmation before executing a reset

### Requirement 19: Exercise Target Muscle Visualization

**User Story:** As a user, I want to see which muscles an exercise targets, so that I understand what my workout is training.

#### Acceptance Criteria

1. WHEN a user views an exercise, THE System SHALL display the Target_Muscle list
2. THE System SHALL categorize muscles as Primary, Secondary, or Stabilizer
3. FOR ALL exercises, THE System SHALL show at least one Primary Target_Muscle
4. THE System SHALL display Target_Muscle information alongside the Exercise_Demo
5. THE System SHALL use consistent muscle naming across all exercises

### Requirement 20: Workout Completion Validation

**User Story:** As a user, I want confirmation when I complete a workout, so that I know my progress was recorded.

#### Acceptance Criteria

1. WHEN a user completes all exercises in a Program_Day, THE System SHALL display a completion confirmation dialog
2. THE completion dialog SHALL show the completed Program_Day number
3. THE completion dialog SHALL indicate if the next Program_Day is unlocked
4. WHEN a user completes the final Program_Day, THE System SHALL display a program completion message
5. THE System SHALL not allow marking a Program_Day as complete without user action

### Requirement 21: Bodyweight Cardio Exercise Inclusion

**User Story:** As a user following a weight loss program, I want cardio exercises that don't require equipment, so that I can do high-intensity training at home.

#### Acceptance Criteria

1. THE System SHALL include bodyweight cardio exercises: burpees, jumping jacks, mountain climbers, high knees, and butt kicks
2. WHEN Fitness_Goal is Weight Loss, THE Workout_Program SHALL include at least 50% cardio exercises
3. FOR ALL cardio exercises, THE System SHALL specify duration or rep count
4. THE System SHALL categorize cardio exercises separately from strength exercises
5. THE System SHALL provide Exercise_Demos for all cardio exercises

### Requirement 22: Program File Naming Convention

**User Story:** As a developer, I want consistent file naming for workout programs, so that the Program_Loader can reliably locate files.

#### Acceptance Criteria

1. THE System SHALL name program files using the pattern `{level}_{goal}.json`
2. THE System SHALL use lowercase with underscores for multi-word values (e.g., `muscle_gain`, `weight_loss`)
3. FOR ALL program files, THE filename SHALL match the programId field in the JSON
4. THE System SHALL organize program files in subdirectories by Fitness_Level
5. IF a program file does not follow the naming convention, THE Program_Loader SHALL log a warning

### Requirement 23: Exercise Instruction Clarity

**User Story:** As a user, I want clear step-by-step instructions for exercises, so that I can perform them correctly without confusion.

#### Acceptance Criteria

1. FOR ALL exercises, THE System SHALL provide instructions as an ordered list of steps
2. THE instructions SHALL use active voice and specific terminology
3. THE instructions SHALL include 3 to 7 steps per exercise
4. THE System SHALL avoid vague terms like "quickly" or "adequately" in instructions
5. THE System SHALL provide tips for proper form alongside instructions

### Requirement 24: Common Mistake Warnings

**User Story:** As a user, I want to know common mistakes for exercises, so that I can avoid injury and maximize effectiveness.

#### Acceptance Criteria

1. FOR ALL exercises, THE System SHALL list 2 to 5 common mistakes
2. THE System SHALL display common mistakes alongside exercise instructions
3. THE common mistakes SHALL describe specific incorrect movements or positions
4. THE System SHALL use clear, non-technical language for common mistakes
5. THE System SHALL prioritize safety-related mistakes over performance mistakes

### Requirement 25: Workout Duration Estimation

**User Story:** As a user, I want to know how long a workout will take, so that I can plan my schedule accordingly.

#### Acceptance Criteria

1. FOR ALL Program_Days with workouts, THE System SHALL calculate estimated duration
2. THE duration calculation SHALL include exercise time, rest periods, and transitions
3. THE System SHALL display estimated duration in minutes before the workout starts
4. WHEN Fitness_Level is Beginner, THE estimated duration SHALL be 20-30 minutes
5. WHEN Fitness_Level is Intermediate, THE estimated duration SHALL be 30-40 minutes
6. WHEN Fitness_Level is Advanced, THE estimated duration SHALL be 40-50 minutes

### Requirement 26: Progressive Difficulty Phases

**User Story:** As a user, I want workout difficulty to increase gradually, so that I build strength safely without plateauing.

#### Acceptance Criteria

1. FOR ALL Workout_Programs, THE System SHALL organize workouts into 3 to 4 progressive phases
2. THE System SHALL increase exercise difficulty, reps, or sets with each phase
3. WHEN a user enters a new phase, THE System SHALL display a notification about the difficulty increase
4. FOR ALL phases, THE System SHALL maintain the same Workout_Split pattern
5. THE final phase SHALL represent peak difficulty for the Fitness_Level

### Requirement 27: User Profile Context Integration

**User Story:** As a user, I want the system to use my profile information automatically, so that I don't have to re-enter my fitness level and goals.

#### Acceptance Criteria

1. WHEN a user has a saved profile, THE System SHALL load `fitnessLevel` and `primaryGoal` from the existing user profile
2. THE System SHALL use profile data to select the appropriate Workout_Program based on `fitnessLevel` (beginner/intermediate/advanced) and `primaryGoal` (Strength/Weight Loss/Muscle Gain/Flexibility/Healthy Lifestyle)
3. THE System SHALL use profile `allergies` field to filter Meal_Plans
4. THE System SHALL NOT prompt users to complete profile if profile already exists from onboarding
5. THE System SHALL update the active Workout_Program when profile `fitnessLevel` or `primaryGoal` changes

### Requirement 28: Multi-Program Support

**User Story:** As a user who completes a program, I want to start a new program with different goals, so that I can continue progressing.

#### Acceptance Criteria

1. WHEN a user completes a Workout_Program, THE System SHALL offer to start a new program
2. THE System SHALL allow users to change `primaryGoal` in their profile without changing `fitnessLevel`
3. WHEN a user starts a new Workout_Program, THE System SHALL reset progress tracking for the new program
4. THE System SHALL maintain historical data about completed programs
5. THE System SHALL prevent running multiple Workout_Programs simultaneously

### Requirement 29: Exercise Equipment Specification

**User Story:** As a user, I want to know what equipment is needed for exercises, so that I can prepare my workout space.

#### Acceptance Criteria

1. FOR ALL exercises, THE System SHALL specify required equipment
2. WHEN equipment is "None", THE System SHALL indicate the exercise is purely bodyweight
3. WHEN equipment is "Wall", THE System SHALL indicate wall space is required
4. THE System SHALL filter exercises by available equipment in user profile
5. FOR ALL Workout_Programs in this system, THE equipment SHALL be limited to bodyweight and wall space

### Requirement 30: Calorie Burn Estimation

**User Story:** As a user, I want to know approximately how many calories I burn per exercise, so that I can track my energy expenditure.

#### Acceptance Criteria

1. FOR ALL exercises, THE System SHALL provide an estimated calorie burn value
2. THE calorie burn SHALL be calculated per set or per minute depending on exercise type
3. THE System SHALL sum calorie burn for all exercises in a Program_Day
4. THE System SHALL display total estimated calorie burn before starting a workout
5. THE calorie estimates SHALL be based on average values for the exercise type and intensity
