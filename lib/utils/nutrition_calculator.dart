import '../models/user_model.dart';

class NutritionCalculator {
  static Map<String, int> calculateDailyGoals(UserModel user) {
    // Harris-Benedict Equation for BMR
    double bmr;
    if (user.gender.toLowerCase() == 'male') {
      bmr = 88.362 + (13.397 * user.weight) + (4.799 * user.height) - (5.677 * user.age);
    } else {
      bmr = 447.593 + (9.247 * user.weight) + (3.098 * user.height) - (4.330 * user.age);
    }

    // Activity Multiplier
    double multiplier;
    switch (user.activityLevel) {
      case 'Sedentary': multiplier = 1.2; break;
      case 'Lightly Active': multiplier = 1.375; break;
      case 'Moderate': multiplier = 1.55; break;
      case 'Very Active': multiplier = 1.725; break;
      case 'Extra Active': multiplier = 1.9; break;
      default: multiplier = 1.2;
    }

    double tdee = bmr * multiplier;

    // Adjust based on goal weight
    int calories;
    if (user.goalWeight < user.weight) {
      calories = (tdee - 500).toInt(); // Weight loss deficit
    } else if (user.goalWeight > user.weight) {
      calories = (tdee + 300).toInt(); // Muscle gain surplus
    } else {
      calories = tdee.toInt(); // Maintenance
    }

    // Macros distribution (e.g., 30% Protein, 40% Carbs, 30% Fat)
    int protein = (calories * 0.3 / 4).toInt();
    int carbs = (calories * 0.4 / 4).toInt();
    int fat = (calories * 0.3 / 9).toInt();

    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }
}
