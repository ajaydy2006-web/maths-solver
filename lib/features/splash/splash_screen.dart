import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../data/providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkInitialNavigation();
  }

  Future<void> _checkInitialNavigation() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    final prefsState = ref.read(userPreferencesNotifierProvider);
    prefsState.when(
      data: (prefs) {
        if (prefs.hasCompletedOnboarding) {
          context.go('/home');
        } else {
          context.go('/onboarding');
        }
      },
      error: (_, __) => context.go('/onboarding'),
      loading: () {
        // Wait a bit more or just go to onboarding
        context.go('/onboarding');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Minimal Vector-based Mathematical Illustration placeholder
            const Icon(Icons.calculate_rounded, size: 80, color: AppColors.primaryOrange),
            const SizedBox(height: 24),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 48,
                color: AppColors.primaryOrange,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppConstants.tagline,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
