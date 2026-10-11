import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/splash/splash_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/home/home_screen.dart';
import '../features/practice/arithmetic_operations_screen.dart';
import '../features/practice/configuration_screen.dart';
import '../features/practice/session_screen.dart';
import '../features/practice/mental_session_screen.dart';
import '../features/results/results_screen.dart';
import '../features/results/review_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/profile/profile_screen.dart';
import '../data/models.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/operations/arithmetic',
        builder: (context, state) => const ArithmeticOperationsScreen(),
      ),
      GoRoute(
        path: '/config/:category',
        builder: (context, state) {
          final category = state.pathParameters['category']!;
          final operation = state.uri.queryParameters['operation'];
          return ConfigurationScreen(
            category: category,
            initialOperation: operation,
          );
        },
      ),
      GoRoute(
        path: '/session',
        builder: (context, state) {
          final config = state.extra as PracticeConfiguration;
          return SessionScreen(config: config);
        },
      ),
      GoRoute(
        path: '/mental-session',
        builder: (context, state) {
          final config = state.extra as PracticeConfiguration;
          return MentalSessionScreen(config: config);
        },
      ),
      GoRoute(
        path: '/results',
        builder: (context, state) {
          final result = state.extra as Map<String, dynamic>;
          return ResultsScreen(result: result);
        },
      ),
      GoRoute(
        path: '/review',
        builder: (context, state) {
          final result = state.extra as Map<String, dynamic>;
          return ReviewScreen(result: result);
        },
      ),
      GoRoute(
        path: '/progress',
        builder: (context, state) => const ProgressScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});
