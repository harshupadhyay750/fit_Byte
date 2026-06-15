import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../services/user_service.dart';
import '../home/home_view.dart';

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final credential = await ref.read(authRepositoryProvider).signUp(
              _emailController.text.trim(),
              _passwordController.text,
            );
            
        if (credential != null && credential.user != null) {
          // Auto-save to Firestore using the static or provider method
          await UserService.saveUserData(
            id: credential.user!.uid,
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            age: int.tryParse(_ageController.text) ?? 25,
            weight: double.tryParse(_weightController.text) ?? 70.0,
            height: double.tryParse(_heightController.text) ?? 170.0,
          );
          
          if (mounted) {
            ref.read(navigationProvider.notifier).state = 0;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeView()),
              (route) => false,
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration failed: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start your journey to a healthier you.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                const SizedBox(height: 32),
                _buildTextField(_nameController, 'Full Name', Icons.person_outline),
                const SizedBox(height: 16),
                _buildTextField(_emailController, 'Email', Icons.email_outlined),
                const SizedBox(height: 16),
                _buildTextField(_passwordController, 'Password', Icons.lock_outline, isPassword: true),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_ageController, 'Age', Icons.calendar_today, isNumber: true)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(_weightController, 'Weight (kg)', Icons.monitor_weight_outlined, isNumber: true)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(_heightController, 'Height (cm)', Icons.height, isNumber: true),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Register'),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false, bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: isPassword ? IconButton(
          icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        ) : null,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
    );
  }
}
