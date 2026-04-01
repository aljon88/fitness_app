# Requirements Document

## Introduction

This document specifies requirements for gathering meal plan data that aligns with user allergies, workout schedules, and fitness goals. The system will create 15 separate meal plan JSON files (one for each goal + fitness level combination) organized by goal first, then fitness level. Each meal plan contains 7 days of meals with 5 meals per day, includes allergen tags and alternatives, and aligns calorie targets and macro ratios with corresponding workout program requirements.

## Glossary

- **Meal_Plan**: A structured nutrition guide containing 7 days of meals (5 meals per day = 35 meals total)
- **Meal_Plan_File**: A JSON file containing meal plan data for a specific goal and fitness level combination
- **Goal**: User's fitness objective (weight_loss, muscle_gain, strength, flexibility, general_fitness)
- **Fitness_Level**: User's current physical capability (beginner, intermediate, advanced)
- **Allergen**: A food ingredient that causes allergic reactions (dairy, eggs, nuts, seafood, gluten)
- **Allergen_Tag**: Metadata indicating which allergens a meal contains
- **Allergen_Alternative**: A substitute ingredient or preparation method for meals containing allergens
- **Meal_Type**: Category of meal (Breakfast, Morning Snack, Lunch, Afternoon Snack, Dinner)
- **Macro**: Macronutrient (protein, carbohydrates, fats)
- **Calorie_Target**: Daily calorie goal aligned with workout program requirements
- **Macro_Ratio**: Percentage distribution of protein, carbs, and fats
- **Workout_Program**: Existing exercise plan with specific calorie and macro requirements
- **User_Profile**: Existing user data containing allergies field with allergen values
- **File_Structure**: Organization pattern matching workout programs: `assets/data/meal_plans/{goal}_{level}.json`

## Requirements

### Requirement 1: Meal Plan File Organization

**User Story:** As a developer, I want meal plan files organized by goal and fitness level, so that the system can load the correct meal plan matching the user's workout program.

#### Acceptance Criteria

1. THE System SHALL create exactly 15 Meal_Plan_Files (5 Goals × 3 Fitness_Levels)
2. THE System SHALL store Meal_Plan_Files at path `assets/data/meal_plans/{goal}_{level}.json`
3. THE System SHALL name files using the pattern `{goal}_{level}.json` where goal is one of (weight_loss, muscle_gain, strength, flexibility, general_fitness) and level is one of (beginner, intermediate, advanced)
4. FOR ALL Meal_Plan_Files, THE filename SHALL match the mealPlanId field in the JSON
5. THE System SHALL organize files by Goal first, then Fitness_Level (matching workout program organization)

### Requirement 2: Meal Plan Content Structure

**User Story:** As a user, I want each meal plan to contain a full week of meals, so that I have variety and can follow a structured nutrition plan.

#### Acceptance Criteria

1. THE Meal_Plan SHALL contain exactly 7 days of meal data
2. FOR ALL days in the Meal_Plan, THE System SHALL provide exactly 5 Meal_Types (Breakfast, Morning Snack, Lunch, Afternoon Snack, Dinner)
3. THE System SHALL provide 35 total meals per Meal_Plan_File (7 days × 5 meals)
4. FOR ALL meals, THE System SHALL include fields: name, calories, protein, carbs, fats, allergens, and alternatives
5. THE System SHALL organize meals by day number (day1 through day7)

### Requirement 3: Allergen Tagging

**User Story:** As a user with food allergies, I want each meal tagged with allergens it contains, so that I can identify safe meals quickly.

#### Acceptance Criteria

1. THE System SHALL tag meals with Allergen_Tags for these allergens: dairy, eggs, nuts, seafood, gluten
2. FOR ALL meals, THE System SHALL include an allergens array field
3. WHEN a meal contains no allergens, THE allergens array SHALL be empty
4. WHEN a meal contains one or more allergens, THE allergens array SHALL list all applicable Allergen_Tags
5. THE Allergen_Tags SHALL match the values in User_Profile allergies field (dairy, eggs, nuts, seafood, gluten)

### Requirement 4: Allergen Alternatives

**User Story:** As a user with food allergies, I want alternative ingredient suggestions for meals containing my allergens, so that I can still enjoy similar meals safely.

#### Acceptance Criteria

1. FOR ALL meals containing allergens, THE System SHALL provide Allergen_Alternatives
2. THE System SHALL structure alternatives as an object with allergen keys and alternative text values
3. FOR ALL common allergens (dairy, eggs, nuts, seafood, gluten), THE System SHALL provide specific substitution instructions
4. THE Allergen_Alternative text SHALL describe the substitute ingredient or preparation method
5. WHEN a meal contains multiple allergens, THE alternatives object SHALL include entries for each allergen

### Requirement 5: Calorie Target Alignment

**User Story:** As a user, I want meal plan calories aligned with my workout program requirements, so that my nutrition supports my fitness goals.

#### Acceptance Criteria

1. WHEN Goal is weight_loss and Fitness_Level is beginner, THE Meal_Plan SHALL target 1800-2000 daily calories
2. WHEN Goal is weight_loss and Fitness_Level is intermediate, THE Meal_Plan SHALL target 1600-1800 daily calories
3. WHEN Goal is weight_loss and Fitness_Level is advanced, THE Meal_Plan SHALL target 1500-1700 daily calories
4. WHEN Goal is muscle_gain and Fitness_Level is beginner, THE Meal_Plan SHALL target 2400-2600 daily calories
5. WHEN Goal is muscle_gain and Fitness_Level is intermediate, THE Meal_Plan SHALL target 2800-3000 daily calories
6. WHEN Goal is muscle_gain and Fitness_Level is advanced, THE Meal_Plan SHALL target 3000-3200 daily calories
7. WHEN Goal is strength and Fitness_Level is beginner, THE Meal_Plan SHALL target 2300-2500 daily calories
8. WHEN Goal is strength and Fitness_Level is intermediate, THE Meal_Plan SHALL target 2600-2800 daily calories
9. WHEN Goal is strength and Fitness_Level is advanced, THE Meal_Plan SHALL target 2800-3000 daily calories
10. WHEN Goal is flexibility and Fitness_Level is beginner, THE Meal_Plan SHALL target 2000-2200 daily calories
11. WHEN Goal is flexibility and Fitness_Level is intermediate, THE Meal_Plan SHALL target 2100-2300 daily calories
12. WHEN Goal is flexibility and Fitness_Level is advanced, THE Meal_Plan SHALL target 2200-2400 daily calories
13. WHEN Goal is general_fitness and Fitness_Level is beginner, THE Meal_Plan SHALL target 2000-2200 daily calories
14. WHEN Goal is general_fitness and Fitness_Level is intermediate, THE Meal_Plan SHALL target 2400-2600 daily calories
15. WHEN Goal is general_fitness and Fitness_Level is advanced, THE Meal_Plan SHALL target 2800-3000 daily calories

### Requirement 6: Macro Ratio Alignment

**User Story:** As a user, I want macronutrient ratios aligned with my fitness goal, so that my nutrition composition supports my training.

#### Acceptance Criteria

1. WHEN Goal is weight_loss, THE Meal_Plan SHALL provide Macro_Ratio of 25-30% protein, 40-45% carbs, 25-30% fats
2. WHEN Goal is muscle_gain, THE Meal_Plan SHALL provide Macro_Ratio of 25-30% protein, 45-50% carbs, 25-30% fats
3. WHEN Goal is strength, THE Meal_Plan SHALL provide Macro_Ratio of 25-30% protein, 45-50% carbs, 25-30% fats
4. WHEN Goal is flexibility, THE Meal_Plan SHALL provide Macro_Ratio of 20-25% protein, 45-50% carbs, 25-30% fats
5. WHEN Goal is general_fitness, THE Meal_Plan SHALL provide Macro_Ratio of 25-30% protein, 45-50% carbs, 25-30% fats
6. FOR ALL Meal_Plans, THE sum of daily meal macros SHALL match the target Macro_Ratio within 5% tolerance

### Requirement 7: Meal Calorie Distribution

**User Story:** As a user, I want calories distributed appropriately across meals throughout the day, so that I maintain steady energy levels.

#### Acceptance Criteria

1. THE Breakfast meal SHALL contain approximately 25% of daily Calorie_Target
2. THE Morning Snack meal SHALL contain approximately 10% of daily Calorie_Target
3. THE Lunch meal SHALL contain approximately 30% of daily Calorie_Target
4. THE Afternoon Snack meal SHALL contain approximately 10% of daily Calorie_Target
5. THE Dinner meal SHALL contain approximately 25% of daily Calorie_Target
6. FOR ALL days in the Meal_Plan, THE sum of meal calories SHALL equal the daily Calorie_Target within 50 calories tolerance

### Requirement 8: Meal Plan JSON Structure

**User Story:** As a developer, I want meal plan data in a consistent JSON format, so that the system can reliably parse and load meal information.

#### Acceptance Criteria

1. THE Meal_Plan_File SHALL include fields: mealPlanId, goal, fitnessLevel, dailyCalories, macros, and weeklyMealPlan
2. THE macros field SHALL include protein, carbs, and fats values in grams
3. THE weeklyMealPlan field SHALL contain day1 through day7 objects
4. FOR ALL day objects, THE System SHALL include breakfast, morningSnack, lunch, afternoonSnack, and dinner meal objects
5. FOR ALL meal objects, THE System SHALL include: name, calories, protein, carbs, fats, allergens array, and alternatives object

### Requirement 9: Goal-Specific Meal Characteristics

**User Story:** As a user, I want meals tailored to my fitness goal characteristics, so that my nutrition strategy matches my training approach.

#### Acceptance Criteria

1. WHEN Goal is weight_loss, THE Meal_Plan SHALL emphasize high protein and low carbohydrate meals
2. WHEN Goal is muscle_gain, THE Meal_Plan SHALL emphasize very high protein and moderate carbohydrate meals
3. WHEN Goal is strength, THE Meal_Plan SHALL emphasize balanced macro distribution
4. WHEN Goal is flexibility, THE Meal_Plan SHALL emphasize anti-inflammatory ingredients rich in omega-3 fatty acids
5. WHEN Goal is general_fitness, THE Meal_Plan SHALL provide balanced nutrition with meal variety

### Requirement 10: Meal Variety

**User Story:** As a user, I want different meals each day of the week, so that I don't get bored with repetitive nutrition.

#### Acceptance Criteria

1. FOR ALL 7 days in the Meal_Plan, THE breakfast meals SHALL be different
2. FOR ALL 7 days in the Meal_Plan, THE lunch meals SHALL be different
3. FOR ALL 7 days in the Meal_Plan, THE dinner meals SHALL be different
4. THE System SHALL provide at least 2 different snack options that rotate across the week
5. THE System SHALL avoid repeating the same meal name more than twice in a 7-day period

### Requirement 11: Simple Home-Cooked Recipes

**User Story:** As a user, I want meals that are simple to prepare at home, so that I can realistically follow the meal plan.

#### Acceptance Criteria

1. FOR ALL meals, THE recipes SHALL use common ingredients available at standard grocery stores
2. FOR ALL meals, THE preparation SHALL require basic cooking equipment (stove, oven, microwave, blender)
3. THE System SHALL avoid meals requiring specialized cooking techniques or equipment
4. FOR ALL meals, THE ingredient count SHALL be between 3 and 10 ingredients
5. THE System SHALL prioritize whole foods over processed ingredients

### Requirement 12: Workout Program Calorie Matching

**User Story:** As a user, I want meal plan calories to match my workout program's nutrition requirements, so that my nutrition and training are synchronized.

#### Acceptance Criteria

1. FOR ALL Meal_Plans, THE dailyCalories field SHALL match the corresponding Workout_Program nutrition.dailyCalories field
2. FOR ALL Meal_Plans, THE macros.protein field SHALL match the corresponding Workout_Program nutrition.protein field within 10g tolerance
3. FOR ALL Meal_Plans, THE macros.carbs field SHALL match the corresponding Workout_Program nutrition.carbs field within 20g tolerance
4. FOR ALL Meal_Plans, THE macros.fats field SHALL match the corresponding Workout_Program nutrition.fats field within 10g tolerance
5. THE System SHALL reference Workout_Program files at `assets/data/programs/{goal}_{level}.json` for nutrition targets

### Requirement 13: Meal Plan File Naming Convention

**User Story:** As a developer, I want consistent file naming for meal plans, so that the system can reliably locate files matching workout programs.

#### Acceptance Criteria

1. THE System SHALL name Meal_Plan_Files using the pattern `{goal}_{level}.json`
2. THE System SHALL use lowercase with underscores for multi-word goal values (weight_loss, muscle_gain, general_fitness)
3. FOR ALL Meal_Plan_Files, THE filename SHALL exactly match the corresponding Workout_Program filename
4. THE goal portion of the filename SHALL be one of: weight_loss, muscle_gain, strength, flexibility, general_fitness
5. THE level portion of the filename SHALL be one of: beginner, intermediate, advanced

### Requirement 14: Meal Nutritional Accuracy

**User Story:** As a user, I want accurate nutritional information for each meal, so that I can trust the calorie and macro data.

#### Acceptance Criteria

1. FOR ALL meals, THE System SHALL calculate calories based on the sum of ingredient calories
2. FOR ALL meals, THE protein value SHALL be accurate within 2g tolerance
3. FOR ALL meals, THE carbs value SHALL be accurate within 5g tolerance
4. FOR ALL meals, THE fats value SHALL be accurate within 2g tolerance
5. THE System SHALL use standard USDA nutritional data for ingredient calculations

### Requirement 15: Complete Meal Plan Coverage

**User Story:** As a user, I want meal plans available for all goal and fitness level combinations, so that I have nutrition guidance regardless of my profile.

#### Acceptance Criteria

1. THE System SHALL provide Meal_Plan_Files for all 15 combinations (5 Goals × 3 Fitness_Levels)
2. FOR ALL valid Goal and Fitness_Level combinations, THE System SHALL have a corresponding Meal_Plan_File
3. THE System SHALL include these Goal values: weight_loss, muscle_gain, strength, flexibility, general_fitness
4. THE System SHALL include these Fitness_Level values: beginner, intermediate, advanced
5. IF a Meal_Plan_File is missing for a valid combination, THE System SHALL log an error indicating the missing file

### Requirement 16: Allergen Alternative Clarity

**User Story:** As a user with allergies, I want clear and specific alternative ingredient instructions, so that I can easily substitute ingredients.

#### Acceptance Criteria

1. FOR ALL Allergen_Alternatives, THE text SHALL specify the exact substitute ingredient
2. THE Allergen_Alternative text SHALL use active voice and specific terminology
3. THE Allergen_Alternative text SHALL avoid vague terms like "similar ingredient" or "appropriate substitute"
4. FOR ALL dairy alternatives, THE System SHALL specify plant-based milk or yogurt types (almond, coconut, soy, oat)
5. FOR ALL nut alternatives, THE System SHALL specify seed-based substitutes (sunflower seed butter, pumpkin seeds)
6. FOR ALL egg alternatives, THE System SHALL specify substitutes appropriate for the recipe type (flax eggs, chia eggs, applesauce)
7. FOR ALL seafood alternatives, THE System SHALL specify alternative protein sources (chicken, tofu, tempeh)
8. FOR ALL gluten alternatives, THE System SHALL specify gluten-free grain options (rice, quinoa, gluten-free oats)

### Requirement 17: Meal Plan Metadata

**User Story:** As a developer, I want meal plan metadata included in each file, so that the system can validate and display meal plan information.

#### Acceptance Criteria

1. THE Meal_Plan_File SHALL include a mealPlanId field matching the filename without extension
2. THE Meal_Plan_File SHALL include a goal field matching one of the 5 supported Goal values
3. THE Meal_Plan_File SHALL include a fitnessLevel field matching one of the 3 supported Fitness_Level values
4. THE Meal_Plan_File SHALL include a dailyCalories field with the target calorie value
5. THE Meal_Plan_File SHALL include a macros object with protein, carbs, and fats fields in grams

### Requirement 18: Meal Preparation Simplicity

**User Story:** As a user with limited cooking time, I want meals that are quick to prepare, so that I can maintain the meal plan despite a busy schedule.

#### Acceptance Criteria

1. FOR ALL breakfast meals, THE preparation time SHALL be 15 minutes or less
2. FOR ALL snack meals, THE preparation time SHALL be 5 minutes or less
3. FOR ALL lunch meals, THE preparation time SHALL be 25 minutes or less
4. FOR ALL dinner meals, THE preparation time SHALL be 35 minutes or less
5. THE System SHALL prioritize meals with minimal cooking steps

### Requirement 19: Protein Source Variety

**User Story:** As a user, I want variety in protein sources across the week, so that I get diverse amino acid profiles and don't get bored.

#### Acceptance Criteria

1. FOR ALL 7-day Meal_Plans, THE System SHALL include at least 3 different protein sources
2. THE System SHALL rotate between animal proteins (chicken, fish, eggs) and plant proteins (beans, lentils, tofu)
3. FOR ALL weight_loss and muscle_gain Meal_Plans, THE System SHALL emphasize lean protein sources
4. THE System SHALL avoid using the same protein source in consecutive meals
5. FOR ALL Meal_Plans, THE System SHALL include both complete and complementary protein combinations

### Requirement 20: Carbohydrate Source Quality

**User Story:** As a user, I want high-quality carbohydrate sources, so that I maintain stable energy levels and support my training.

#### Acceptance Criteria

1. FOR ALL Meal_Plans, THE System SHALL prioritize complex carbohydrates over simple sugars
2. THE System SHALL include carbohydrate sources: oats, rice, quinoa, sweet potatoes, whole grain bread, fruits, vegetables
3. FOR ALL weight_loss Meal_Plans, THE System SHALL emphasize low glycemic index carbohydrates
4. FOR ALL muscle_gain Meal_Plans, THE System SHALL include moderate glycemic index carbohydrates for post-workout meals
5. THE System SHALL limit refined carbohydrates and added sugars to less than 10% of daily carbohydrate intake

### Requirement 21: Healthy Fat Sources

**User Story:** As a user, I want healthy fat sources in my meals, so that I support hormone production and nutrient absorption.

#### Acceptance Criteria

1. FOR ALL Meal_Plans, THE System SHALL include healthy fat sources: avocado, nuts, seeds, olive oil, fatty fish
2. THE System SHALL prioritize unsaturated fats over saturated fats
3. FOR ALL flexibility Meal_Plans, THE System SHALL emphasize omega-3 rich foods (salmon, walnuts, chia seeds, flaxseeds)
4. THE System SHALL limit saturated fat to less than 10% of total daily calories
5. THE System SHALL avoid trans fats in all meal recommendations

### Requirement 22: Vegetable and Fruit Inclusion

**User Story:** As a user, I want adequate vegetables and fruits in my meal plan, so that I get essential vitamins, minerals, and fiber.

#### Acceptance Criteria

1. FOR ALL Meal_Plans, THE System SHALL include at least 5 servings of vegetables per day
2. FOR ALL Meal_Plans, THE System SHALL include at least 2 servings of fruits per day
3. THE System SHALL distribute vegetables across lunch and dinner meals
4. THE System SHALL include fruits in breakfast and snack meals
5. FOR ALL Meal_Plans, THE System SHALL provide variety in vegetable colors (green, red, orange, purple) across the week

### Requirement 23: Hydration Recommendations

**User Story:** As a user, I want hydration guidance with my meal plan, so that I maintain proper fluid balance for training and recovery.

#### Acceptance Criteria

1. FOR ALL Meal_Plans, THE System SHALL include a daily water intake recommendation
2. WHEN Fitness_Level is beginner, THE System SHALL recommend 2-2.5 liters of water per day
3. WHEN Fitness_Level is intermediate, THE System SHALL recommend 2.5-3 liters of water per day
4. WHEN Fitness_Level is advanced, THE System SHALL recommend 3-3.5 liters of water per day
5. THE System SHALL increase water recommendations by 500ml on workout days

### Requirement 24: Meal Timing Guidance

**User Story:** As a user, I want guidance on when to eat each meal, so that I optimize nutrient timing around my workouts.

#### Acceptance Criteria

1. FOR ALL Meal_Plans, THE System SHALL provide suggested meal timing windows
2. THE System SHALL recommend breakfast within 1 hour of waking
3. THE System SHALL recommend spacing meals 2-3 hours apart
4. THE System SHALL recommend eating 1-2 hours before workouts
5. THE System SHALL recommend post-workout nutrition within 30-60 minutes after training

### Requirement 25: Portion Size Clarity

**User Story:** As a user, I want clear portion sizes for each meal, so that I can accurately follow the meal plan.

#### Acceptance Criteria

1. FOR ALL meals, THE System SHALL specify ingredient quantities with standard units (cups, tablespoons, ounces, grams)
2. THE System SHALL provide both volume and weight measurements where applicable
3. FOR ALL protein sources, THE System SHALL specify portion size in ounces or grams
4. FOR ALL carbohydrate sources, THE System SHALL specify portion size in cups or grams
5. THE System SHALL use consistent measurement units across all meals in a Meal_Plan

### Requirement 26: Budget-Friendly Ingredients

**User Story:** As a user on a budget, I want meal plans using affordable ingredients, so that I can maintain the nutrition plan without financial strain.

#### Acceptance Criteria

1. FOR ALL Meal_Plans, THE System SHALL prioritize cost-effective protein sources (chicken, eggs, beans, lentils)
2. THE System SHALL use seasonal vegetables and fruits when possible
3. THE System SHALL avoid expensive specialty ingredients or superfoods
4. FOR ALL Meal_Plans, THE estimated weekly grocery cost SHALL be reasonable for the target demographic
5. THE System SHALL suggest bulk purchasing options for frequently used ingredients

### Requirement 27: Meal Prep Efficiency

**User Story:** As a user who meal preps, I want meals that can be prepared in batches, so that I can save time during the week.

#### Acceptance Criteria

1. FOR ALL lunch and dinner meals, THE recipes SHALL be suitable for batch cooking
2. THE System SHALL indicate which meals can be refrigerated for 3-5 days
3. THE System SHALL indicate which meals can be frozen for longer storage
4. FOR ALL Meal_Plans, THE System SHALL group meals using similar ingredients to reduce waste
5. THE System SHALL provide reheating instructions for batch-prepared meals

### Requirement 28: Dietary Preference Flexibility

**User Story:** As a user with dietary preferences, I want meal plans that can accommodate vegetarian or pescatarian choices, so that I can align nutrition with my values.

#### Acceptance Criteria

1. FOR ALL meals containing meat, THE System SHALL provide vegetarian Allergen_Alternatives
2. THE System SHALL tag meals as vegetarian-friendly, pescatarian-friendly, or omnivore
3. FOR ALL Meal_Plans, THE System SHALL include at least 30% vegetarian meal options
4. THE vegetarian alternatives SHALL maintain equivalent protein content within 5g tolerance
5. THE System SHALL use complete plant protein combinations (rice + beans, hummus + pita) in vegetarian meals

### Requirement 29: Micronutrient Considerations

**User Story:** As a user, I want meals that provide essential vitamins and minerals, so that I support overall health beyond just macros.

#### Acceptance Criteria

1. FOR ALL Meal_Plans, THE System SHALL include iron-rich foods (spinach, lean meat, beans)
2. FOR ALL Meal_Plans, THE System SHALL include calcium-rich foods (dairy, leafy greens, fortified alternatives)
3. FOR ALL Meal_Plans, THE System SHALL include vitamin D sources (fatty fish, eggs, fortified foods)
4. FOR ALL Meal_Plans, THE System SHALL include vitamin C sources (citrus, berries, peppers)
5. FOR ALL Meal_Plans, THE System SHALL include magnesium sources (nuts, seeds, whole grains, leafy greens)

### Requirement 30: Meal Plan Validation

**User Story:** As a developer, I want automated validation of meal plan data, so that I can ensure data quality and consistency.

#### Acceptance Criteria

1. THE System SHALL validate that all 15 Meal_Plan_Files exist at the specified path
2. THE System SHALL validate that each Meal_Plan_File contains valid JSON structure
3. THE System SHALL validate that daily calorie totals match the dailyCalories field within 50 calories tolerance
4. THE System SHALL validate that all required fields are present in each meal object
5. THE System SHALL validate that allergen tags use only the 5 supported values (dairy, eggs, nuts, seafood, gluten)
