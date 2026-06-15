import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/providers.dart';
import '../../models/user_model.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileStreamProvider);
    final goals = ref.watch(nutritionGoalsProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) return const Scaffold(body: Center(child: Text('User not found')));
        
        // BMI Calculation for profile
        double bmi = user.weight / ((user.height / 100) * (user.height / 100));
        String bmiCategory;
        Color bmiColor;
        if (bmi < 18.5) {
          bmiCategory = 'Underweight';
          bmiColor = Colors.orange;
        } else if (bmi < 25) {
          bmiCategory = 'Normal';
          bmiColor = Colors.green;
        } else if (bmi < 30) {
          bmiCategory = 'Overweight';
          bmiColor = Colors.orange;
        } else {
          bmiCategory = 'Obese';
          bmiColor = Colors.red;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_note),
                onPressed: () => _showEditProfileBottomSheet(context, ref, user),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildProfileCard(context, ref, user).animate().scale(),
                const SizedBox(height: 24),
                _buildHealthSummary(context, bmi, bmiCategory, bmiColor, user).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 24),
                _buildGoalsCard(context, goals).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 24),
                _buildPersonalDetails(context, user).animate().fadeIn(delay: 600.ms),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildProfileCard(BuildContext context, WidgetRef ref, UserModel user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white.withOpacity(0.2),
                backgroundImage: user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty
                    ? FileImage(File(user.profileImageUrl!))
                    : null,
                child: (user.profileImageUrl == null || user.profileImageUrl!.isEmpty)
                    ? Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                      )
                    : null,
              ),
              InkWell(
                onTap: () => _pickProfileImage(context, ref, user),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Icon(Icons.camera_alt, color: Theme.of(context).colorScheme.primary, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            user.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            user.email,
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
          ),
          if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                user.phoneNumber!,
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickProfileImage(BuildContext context, WidgetRef ref, UserModel user) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      final updatedUser = user.copyWith(profileImageUrl: image.path);
      await ref.read(userNotifierProvider.notifier).saveUser(updatedUser);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile photo updated!')));
      }
    }
  }

  Widget _buildHealthSummary(BuildContext context, double bmi, String category, Color color, user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric('BMI', bmi.toStringAsFixed(1), color),
              _buildMetric('Weight', '${user.weight} kg', Colors.blue),
              _buildMetric('Goal', '${user.goalWeight} kg', Colors.green),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Text(
              'Status: $category',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildGoalsCard(BuildContext context, Map<String, int> goals) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recommended Daily Goals', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 20),
          _buildGoalItem(Icons.local_fire_department, 'Calories', '${goals['calories']} kcal', Colors.orange),
          _buildGoalItem(Icons.egg_alt, 'Protein', '${goals['protein']} g', Colors.blue),
          _buildGoalItem(Icons.bakery_dining, 'Carbohydrates', '${goals['carbs']} g', Colors.green),
          _buildGoalItem(Icons.opacity, 'Healthy Fats', '${goals['fat']} g', Colors.red),
        ],
      ),
    );
  }

  Widget _buildGoalItem(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPersonalDetails(BuildContext context, user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Personal Attributes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          _buildDetailRow('Gender', user.gender),
          _buildDetailRow('Age', '${user.age} years'),
          _buildDetailRow('Height', '${user.height} cm'),
          _buildDetailRow('Activity Level', user.activityLevel),
          _buildDetailRow('Diet Preference', user.dietaryPreference),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showEditProfileBottomSheet(BuildContext context, WidgetRef ref, UserModel user) {
    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phoneNumber ?? '');
    final ageController = TextEditingController(text: user.age.toString());
    final heightController = TextEditingController(text: user.height.toString());
    final weightController = TextEditingController(text: user.weight.toString());
    final goalWeightController = TextEditingController(text: user.goalWeight.toString());
    String selectedActivity = user.activityLevel;
    String selectedDiet = user.dietaryPreference;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 32, left: 24, right: 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Update Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined)),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: ageController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Age', prefixIcon: Icon(Icons.calendar_today)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: heightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Height (cm)', prefixIcon: Icon(Icons.height)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: weightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Weight (kg)', prefixIcon: Icon(Icons.scale)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: goalWeightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Goal (kg)', prefixIcon: Icon(Icons.flag_outlined)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedActivity,
                  decoration: const InputDecoration(labelText: 'Activity Level', prefixIcon: Icon(Icons.directions_run)),
                  items: ['Sedentary', 'Lightly Active', 'Moderate', 'Very Active', 'Extra Active']
                      .map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                  onChanged: (val) => setModalState(() => selectedActivity = val!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedDiet,
                  decoration: const InputDecoration(labelText: 'Dietary Preference', prefixIcon: Icon(Icons.restaurant)),
                  items: ['None', 'Vegetarian', 'Vegan', 'Keto', 'Paleo']
                      .map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (val) => setModalState(() => selectedDiet = val!),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      final updatedUser = user.copyWith(
                        name: nameController.text,
                        phoneNumber: phoneController.text,
                        age: int.tryParse(ageController.text) ?? user.age,
                        height: double.tryParse(heightController.text) ?? user.height,
                        weight: double.tryParse(weightController.text) ?? user.weight,
                        goalWeight: double.tryParse(goalWeightController.text) ?? user.goalWeight,
                        activityLevel: selectedActivity,
                        dietaryPreference: selectedDiet,
                      );
                      ref.read(userNotifierProvider.notifier).saveUser(updatedUser);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully!')));
                    },
                    child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
