import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../services/ai_service.dart';
import '../services/user_service.dart';
import '../models/meal_model.dart';
import '../models/user_model.dart';
import '../models/workout_model.dart';
import '../utils/nutrition_calculator.dart';
import '../repositories/database_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 0. Startup Providers
final firebaseInitializedProvider = StateProvider<bool>((ref) => Firebase.apps.isNotEmpty);

// 1. Core Providers
final databaseRepositoryProvider = Provider<DatabaseRepository>((ref) => DatabaseRepository());
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());

// 2. Auth Providers
final authRepositoryProvider = Provider<BaseAuthRepository>((ref) {
  final isInitialized = ref.watch(firebaseInitializedProvider);
  if (isInitialized) {
    return AuthRepository();
  }
  return MockAuthRepository();
});

final authStateProvider = StreamProvider<User?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges;
});

// 3. User & Profile Providers
final userServiceProvider = Provider<UserService>((ref) => UserService());

final userProfileStreamProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider).value;
  if (authState == null) return Stream.value(null);
  return ref.watch(userServiceProvider).streamUserData(authState.uid);
});

// Helper to get user data synchronously where needed
final userProvider = Provider<UserModel?>((ref) {
  return ref.watch(userProfileStreamProvider).value;
});

final userNotifierProvider = StateNotifierProvider<UserNotifier, UserModel?>((ref) {
  final dbRepo = ref.watch(databaseRepositoryProvider);
  return UserNotifier(dbRepo);
});

class UserNotifier extends StateNotifier<UserModel?> {
  final DatabaseRepository _dbRepo;
  UserNotifier(this._dbRepo) : super(null);
  Future<void> saveUser(UserModel user) async => await _dbRepo.saveUser(user);
  Future<void> clearUser() async => await _dbRepo.deleteUser();
}

// 4. App State Providers
final navigationProvider = StateProvider<int>((ref) => 0);
final aiServiceProvider = Provider<AIService>((ref) => AIService());

// 5. Settings Providers
final themeModeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeNotifier(prefs);
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;
  ThemeNotifier(this._prefs) : super(ThemeMode.system) {
    _loadTheme();
  }
  void _loadTheme() {
    final theme = _prefs.getString('theme_mode');
    if (theme == 'light') state = ThemeMode.light;
    if (theme == 'dark') state = ThemeMode.dark;
  }
  void toggleTheme(bool isDark) {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
    _prefs.setString('theme_mode', isDark ? 'dark' : 'light');
  }
}

// 6. Feature Providers (Nutrition/Workout)
final nutritionGoalsProvider = Provider<Map<String, int>>((ref) {
  final user = ref.watch(userProvider);
  if (user == null) return {'calories': 2000, 'protein': 150, 'carbs': 200, 'fat': 70};
  return NutritionCalculator.calculateDailyGoals(user);
});

final mealsProvider = StateNotifierProvider<MealsNotifier, List<Meal>>((ref) {
  final dbRepo = ref.watch(databaseRepositoryProvider);
  return MealsNotifier(dbRepo);
});

class MealsNotifier extends StateNotifier<List<Meal>> {
  final DatabaseRepository _dbRepo;
  MealsNotifier(this._dbRepo) : super([]) { _loadMeals(); }
  Future<void> _loadMeals() async => state = await _dbRepo.getMeals();
  Future<void> addMeal(Meal meal) async { await _dbRepo.insertMeal(meal); _loadMeals(); }
  Future<void> deleteMeal(String id) async { await _dbRepo.deleteMeal(id); _loadMeals(); }
}

final workoutProvider = StateNotifierProvider<WorkoutNotifier, List<Workout>>((ref) {
  final dbRepo = ref.watch(databaseRepositoryProvider);
  return WorkoutNotifier(dbRepo);
});

class WorkoutNotifier extends StateNotifier<List<Workout>> {
  final DatabaseRepository _dbRepo;
  WorkoutNotifier(this._dbRepo) : super([]) { _loadWorkouts(); }
  Future<void> _loadWorkouts() async => state = await _dbRepo.getWorkouts();
  Future<void> addWorkout(Workout w) async { await _dbRepo.insertWorkout(w); _loadWorkouts(); }
}

// 7. Computed Providers
final caloriesEatenProvider = Provider<int>((ref) => ref.watch(mealsProvider).fold(0, (sum, m) => sum + m.calories));
final caloriesBurnedTodayProvider = Provider<int>((ref) {
  final today = DateTime.now();
  return ref.watch(workoutProvider).where((w) => w.date.day == today.day).fold(0, (sum, w) => sum + w.caloriesBurned);
});
final caloriesGoalProvider = Provider<int>((ref) => ref.watch(nutritionGoalsProvider)['calories'] ?? 2000);
final proteinGoalProvider = Provider<double>((ref) => (ref.watch(nutritionGoalsProvider)['protein'] ?? 150).toDouble());
final carbsGoalProvider = Provider<double>((ref) => (ref.watch(nutritionGoalsProvider)['carbs'] ?? 200).toDouble());
final fatGoalProvider = Provider<double>((ref) => (ref.watch(nutritionGoalsProvider)['fat'] ?? 70).toDouble());

final proteinEatenProvider = Provider<double>((ref) => ref.watch(mealsProvider).fold(0.0, (sum, m) => sum + m.protein));
final carbsEatenProvider = Provider<double>((ref) => ref.watch(mealsProvider).fold(0.0, (sum, m) => sum + m.carbs));
final fatEatenProvider = Provider<double>((ref) => ref.watch(mealsProvider).fold(0.0, (sum, m) => sum + m.fat));

final languageProvider = StateProvider<String>((ref) => 'English');
final waterIntakeProvider = StateProvider<int>((ref) => 0);
final dailyWaterGoalProvider = StateProvider<int>((ref) => 2500);
final notificationsEnabledProvider = StateProvider<bool>((ref) => true);

final aiInsightProvider = FutureProvider<String>((ref) async {
  final user = ref.watch(userProvider);
  if (user == null) return "Complete your profile to get personalized insights!";
  final prompt = "Macros: P:${ref.watch(proteinEatenProvider).toInt()}g, C:${ref.watch(carbsEatenProvider).toInt()}g, F:${ref.watch(fatEatenProvider).toInt()}g. Give a 1-sentence tip.";
  return ref.read(aiServiceProvider).getDietRecommendation(prompt);
});

final dietPlanProvider = StateNotifierProvider<DietPlanNotifier, List<dynamic>>((ref) => DietPlanNotifier(ref));
class DietPlanNotifier extends StateNotifier<List<dynamic>> {
  final Ref _ref;
  DietPlanNotifier(this._ref) : super([]);
  Future<void> generatePlan() async {
    final user = _ref.read(userProvider);
    if (user == null) return;
    final userProfile = "Age: ${user.age}, Weight: ${user.weight}kg, Goal: ${user.goalWeight}kg";
    state = await _ref.read(aiServiceProvider).getStructuredDietPlan(userProfile);
  }
}
