import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/meal_model.dart';
import '../models/workout_model.dart';
import '../services/database_service.dart';
import 'package:flutter/material.dart';

class DatabaseRepository {
  final DatabaseService _dbService = DatabaseService.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // --- User Profile DAO ---
  Future<void> saveUser(UserModel user) async {
    // 1. Save Locally
    final db = await _dbService.database;
    await db.insert(
      'user_profile',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // 2. Save to Cloud (Firestore)
    try {
      await _firestore.collection('users').doc(user.id).set(user.toMap());
    } catch (e) {
      debugPrint('Firestore Save Error (Check if initialized): $e');
    }
  }

  Future<UserModel?> getUser() async {
    // 1. Check Local DB first
    final db = await _dbService.database;
    final maps = await db.query('user_profile');
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }

    // 2. If not local, try fetching from Cloud (Firestore)
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final doc = await _firestore.collection('users').doc(currentUser.uid).get();
        if (doc.exists && doc.data() != null) {
          final user = UserModel.fromMap(doc.data()!);
          // Save to local for next time
          await db.insert('user_profile', user.toMap());
          return user;
        }
      }
    } catch (e) {
      debugPrint('Firestore Fetch Error (Check if initialized): $e');
    }
    return null;
  }

  Future<void> deleteUser() async {
    final db = await _dbService.database;
    await db.delete('user_profile');
    await db.delete('calorie_logs');
    await db.delete('workouts');
  }

  // --- Calorie Logs DAO ---
  Future<void> insertMeal(Meal meal) async {
    final db = await _dbService.database;
    await db.insert('calorie_logs', {
      'title': meal.title,
      'subtitle': meal.subtitle,
      'calories': meal.calories,
      'protein': meal.protein,
      'carbs': meal.carbs,
      'fat': meal.fat,
      'icon': meal.icon.codePoint.toString(),
      'date': meal.time.toIso8601String(),
    });
  }

  Future<List<Meal>> getMeals() async {
    final db = await _dbService.database;
    final result = await db.query('calorie_logs', orderBy: 'date DESC');
    return result.map((json) {
      final codePointStr = json['icon'] as String;
      final codePoint = int.tryParse(codePointStr) ?? 58713; // Default to restaurant icon
      final iconData = IconData(codePoint, fontFamily: 'MaterialIcons'); // ignore: non_const_argument_for_const_parameter
      return Meal(
        id: json['id'].toString(),
        title: json['title'] as String,
        subtitle: json['subtitle'] as String,
        calories: json['calories'] as int,
        protein: (json['protein'] ?? 0.0) as double,
        carbs: (json['carbs'] ?? 0.0) as double,
        fat: (json['fat'] ?? 0.0) as double,
        icon: iconData,
        time: DateTime.parse(json['date'] as String),
      );
    }).toList();
  }

  Future<void> deleteMeal(String id) async {
    final db = await _dbService.database;
    await db.delete('calorie_logs', where: 'id = ?', whereArgs: [id]);
  }

  // --- Workout DAO ---
  Future<void> insertWorkout(Workout workout) async {
    final db = await _dbService.database;
    await db.insert('workouts', workout.toMap());
  }

  Future<List<Workout>> getWorkouts() async {
    final db = await _dbService.database;
    final result = await db.query('workouts', orderBy: 'date DESC');
    return result.map((json) => Workout.fromMap(json)).toList();
  }
}
