class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? profileImageUrl;
  final int age;
  final double height;
  final double weight;
  final double goalWeight;
  final String gender;
  final String activityLevel;
  final String dietaryPreference;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.profileImageUrl,
    this.age = 25,
    this.height = 170,
    this.weight = 70,
    this.goalWeight = 65,
    this.gender = 'Other',
    this.activityLevel = 'Moderate',
    this.dietaryPreference = 'None',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'age': age,
      'height': height,
      'weight': weight,
      'goalWeight': goalWeight,
      'gender': gender,
      'activityLevel': activityLevel,
      'dietaryPreference': dietaryPreference,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'],
      profileImageUrl: map['profileImageUrl'],
      age: map['age'] ?? 25,
      height: (map['height'] ?? 170.0).toDouble(),
      weight: (map['weight'] ?? 70.0).toDouble(),
      goalWeight: (map['goalWeight'] ?? 65.0).toDouble(),
      gender: map['gender'] ?? 'Other',
      activityLevel: map['activityLevel'] ?? 'Moderate',
      dietaryPreference: map['dietaryPreference'] ?? 'None',
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
    int? age,
    double? height,
    double? weight,
    double? goalWeight,
    String? gender,
    String? activityLevel,
    String? dietaryPreference,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      goalWeight: goalWeight ?? this.goalWeight,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
    );
  }
}
