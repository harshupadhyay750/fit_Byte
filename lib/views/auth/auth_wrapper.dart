import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../home/home_view.dart';
import 'login_view.dart';
import '../onboarding/user_data_view.dart';
import '../splash/splash_view.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Check Auth State
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (firebaseUser) {
        if (firebaseUser == null) {
          debugPrint('AuthWrapper: User is null, showing LoginView');
          return const LoginView();
        }

        // 2. Check Profile State
        final profileAsync = ref.watch(userProfileStreamProvider);
        
        return profileAsync.when(
          data: (profile) {
            if (profile != null) {
              debugPrint('AuthWrapper: Profile found, showing HomeView');
              Future.microtask(() => ref.read(navigationProvider.notifier).state = 0);
              return const HomeView();
            } else {
              debugPrint('AuthWrapper: No profile found, showing UserDataView');
              return const UserDataView();
            }
          },
          loading: () {
            debugPrint('AuthWrapper: Profile loading...');
            return const SplashView();
          },
          error: (e, stack) {
            debugPrint('AuthWrapper: Profile error: $e');
            return const UserDataView();
          },
        );
      },
      loading: () {
        debugPrint('AuthWrapper: Auth state loading...');
        return const SplashView();
      },
      error: (e, stack) {
        debugPrint('AuthWrapper: Auth error: $e');
        return const LoginView();
      },
    );
  }
}
