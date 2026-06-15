import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme/app_theme.dart';
import 'views/auth/auth_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/providers.dart';
import 'services/notification_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );

  // Non-blocking Firebase Init
  Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((_) {
    container.read(firebaseInitializedProvider.notifier).state = true;
    NotificationService.instance.initialize().catchError((e) => debugPrint('FCM Init Error: $e'));
    debugPrint('Firebase initialized successfully');
  }).catchError((e) {
    debugPrint('Firebase initialization failed: $e');
  });
  
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const FitByteApp(),
    ),
  );
}

class FitByteApp extends ConsumerWidget {
  const FitByteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp(
      title: 'FitByte',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const AuthWrapper(),
    );
  }
}
