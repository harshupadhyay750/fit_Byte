import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/providers.dart';
import '../../models/user_model.dart';
import '../auth/login_view.dart';
import '../bmi/bmi_calculator_view.dart';
import 'profile_view.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final themeMode = ref.watch(themeModeProvider);
    final language = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildProfileHeader(
            user?.name ?? 'User', 
            user?.email ?? 'No email',
            context,
            ref,
            user
          ).animate().fadeIn().slideY(begin: -0.1),
          const SizedBox(height: 24),
          
          _buildSectionHeader('Health Tools'),
          _buildSettingsTile(
            Icons.calculate_outlined, 
            'BMI Calculator', 
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BMICalculatorView())),
            color: Colors.orange,
          ),
          _buildSettingsTile(
            Icons.history_outlined, 
            'Progress History', 
            () => _showMockProgress(context),
            color: Colors.purple,
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Preferences'),
          _buildSettingsTile(
            Icons.dark_mode_outlined, 
            'Dark Mode', 
            () {}, 
            trailing: Switch(
              value: themeMode == ThemeMode.dark, 
              onChanged: (v) => ref.read(themeModeProvider.notifier).toggleTheme(v),
            ),
          ),
          _buildSettingsTile(
            Icons.language_outlined, 
            'Language', 
            () => _showLanguageDialog(context, ref), 
            trailing: Text(language, style: const TextStyle(color: Colors.grey)),
          ),
          _buildSettingsTile(
            Icons.notifications_active_outlined, 
            'Water Reminders', 
            () {}, 
            trailing: Switch(
              value: ref.watch(notificationsEnabledProvider), 
              onChanged: (v) => ref.read(notificationsEnabledProvider.notifier).state = v,
            ),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Account'),
          _buildSettingsTile(
            Icons.person_outline, 
            'Detailed Profile', 
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileView())),
            color: Colors.blue,
          ),
          _buildSettingsTile(Icons.help_outline, 'Help & Support', () {}),
          
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: () async {
                await ref.read(authRepositoryProvider).signOut();
                await ref.read(userNotifierProvider.notifier).clearUser();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginView()),
                    (route) => false,
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Logout'),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(String name, String email, BuildContext context, WidgetRef ref, UserModel? user) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              backgroundImage: user?.profileImageUrl != null && user!.profileImageUrl!.isNotEmpty
                  ? FileImage(File(user.profileImageUrl!))
                  : null,
              child: (user?.profileImageUrl == null || user!.profileImageUrl!.isEmpty)
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'U',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                    )
                  : null,
            ),
            InkWell(
              onTap: () async {
                if (user != null) {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    final updatedUser = user.copyWith(profileImageUrl: image.path);
                    await ref.read(userNotifierProvider.notifier).saveUser(updatedUser);
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(email, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, VoidCallback onTap, {Widget? trailing, Color? color}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (color ?? Colors.blue).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color ?? Colors.blue, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English', 'Hindi', 'Spanish', 'French'].map((lang) => ListTile(
            title: Text(lang),
            onTap: () {
              ref.read(languageProvider.notifier).state = lang;
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showMockProgress(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('Your 7-Day Consistency', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (i) => Column(
                children: [
                  Container(height: 60, width: 20, color: i < 5 ? Colors.green : Colors.grey[300]),
                  const SizedBox(height: 8),
                  Text('Day ${i+1}', style: const TextStyle(fontSize: 10)),
                ],
              )),
            ),
            const Spacer(),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ],
        ),
      ),
    );
  }
}
