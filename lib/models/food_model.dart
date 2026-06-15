class FoodModel {
  final String id;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String servingSize;

  FoodModel({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.servingSize,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'servingSize': servingSize,
    };
  }

  factory FoodModel.fromMap(Map<String, dynamic> map) {
    return FoodModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      calories: (map['calories'] ?? 0.0).toDouble(),
      protein: (map['protein'] ?? 0.0).toDouble(),
      carbs: (map['carbs'] ?? 0.0).toDouble(),
      fat: (map['fat'] ?? 0.0).toDouble(),
      servingSize: map['servingSize'] ?? '100g',
    );
  }
}
