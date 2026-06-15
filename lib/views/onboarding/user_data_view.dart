import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/providers.dart';
import '../../models/user_model.dart';
import '../home/home_view.dart';

class UserDataView extends ConsumerStatefulWidget {
  const UserDataView({super.key});

  @override
  ConsumerState<UserDataView> createState() => _UserDataViewState();
}

class _UserDataViewState extends ConsumerState<UserDataView> {
  final _formKey = GlobalKey<FormState>();
  
  final _ageController = TextEditingController(text: '25');
  final _heightController = TextEditingController(text: '170');
  final _weightController = TextEditingController(text: '70');
  final _goalWeightController = TextEditingController(text: '65');
  
  String _gender = 'Male';
  String _activityLevel = 'Moderate';
  String _dietaryPreference = 'None';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tell us about yourself')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Help us personalize your diet plan',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(_ageController, 'Age', Icons.calendar_today),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdown('Gender', ['Male', 'Female', 'Other'], (val) => setState(() => _gender = val!)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(_heightController, 'Height (cm)', Icons.height),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(_weightController, 'Weight (kg)', Icons.monitor_weight),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              _buildTextField(_goalWeightController, 'Goal Weight (kg)', Icons.flag),
              const SizedBox(height: 20),
              
              _buildDropdown('Activity Level', 
                ['Sedentary', 'Lightly Active', 'Moderate', 'Very Active', 'Extra Active'], 
                (val) => setState(() => _activityLevel = val!)),
              const SizedBox(height: 20),

              _buildDropdown('Dietary Preference', 
                ['None', 'Vegetarian', 'Vegan', 'Keto', 'Paleo'], 
                (val) => setState(() => _dietaryPreference = val!)),
              
              const SizedBox(height: 40),
              
              ElevatedButton(
                onPressed: _saveAndProceed,
                child: const Text('Generate My Diet Plan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildDropdown(String label, List<String> options, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: options.contains(label) ? null : options[0],
      decoration: InputDecoration(labelText: label),
      items: options.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  void _saveAndProceed() {
    if (_formKey.currentState!.validate()) {
      final currentUser = FirebaseAuth.instance.currentUser;
      
      final user = UserModel(
        id: currentUser?.uid ?? 'guest_${DateTime.now().millisecondsSinceEpoch}',
        name: currentUser?.displayName ?? 'New User',
        email: currentUser?.email ?? 'guest@example.com',
        phoneNumber: currentUser?.phoneNumber,
        profileImageUrl: currentUser?.photoURL,
        age: int.parse(_ageController.text),
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
        goalWeight: double.parse(_goalWeightController.text),
        gender: _gender,
        activityLevel: _activityLevel,
        dietaryPreference: _dietaryPreference,
      );

      // Save user to provider (now persistent in Cloud Firestore + Local DB)
      ref.read(userNotifierProvider.notifier).saveUser(user);

      // Ensure we start at the Dashboard tab
      ref.read(navigationProvider.notifier).state = 0;
      
      // Navigate to home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeView()),
      );

    }
  }
}
