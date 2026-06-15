import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  static Future<void> saveUserData({
    required String id,
    required String name,
    required String email,
    required int age,
    required double weight,
    double height = 170.0,
    String goal = 'Maintain',
  }) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(id).set({
        'id': id,
        'name': name,
        'email': email,
        'age': age,
        'weight': weight,
        'height': height,
        'goal': goal,
        'isPremium': false,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('UserService Save Error: $e');
    }
  }

  Future<UserModel?> fetchUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
    } catch (e) {
      debugPrint('UserService Fetch Error: $e');
    }
    return null;
  }

  Stream<UserModel?> streamUserData(String uid) {
    try {
      return _firestore
          .collection('users')
          .doc(uid)
          .snapshots()
          .map((doc) => doc.exists ? UserModel.fromMap(doc.data()!) : null);
    } catch (e) {
      debugPrint('UserService Stream Error: $e');
      return Stream.value(null);
    }
  }
}
