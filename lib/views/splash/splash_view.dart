import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/icon_5.png',
              height: 150,
              width: 150,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.restaurant,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
            ).animate().scale(duration: 800.ms).then().shake(),
            const SizedBox(height: 24),
            Text(
              'FitByte',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 2,
              ),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 16),
            Text(
              'AI-Powered Nutrition',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ).animate().fadeIn(delay: 600.ms),
          ],
        ),
      ),
    );
  }
}
