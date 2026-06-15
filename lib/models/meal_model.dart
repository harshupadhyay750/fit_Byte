import 'package:flutter/material.dart';

class Meal {
  final String id;
  final String title;
  final String subtitle;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final IconData icon;
  final DateTime time;

  Meal({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.calories,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    required this.icon,
    required this.time,
  });
}
