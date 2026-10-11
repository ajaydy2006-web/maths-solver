import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router.dart';
import 'core/theme.dart';
import 'core/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: CalcupApp()));
}

class CalcupApp extends ConsumerWidget {
  const CalcupApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return _MobileResponsiveWrapper(child: child ?? const SizedBox());
      },
    );
  }
}

class _MobileResponsiveWrapper extends StatelessWidget {
  final Widget child;

  const _MobileResponsiveWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isDesktopWidth = screenWidth > 520;

    if (!isDesktopWidth) {
      return child;
    }

    final frameWidth = 420.0;
    final frameHeight = screenHeight > 940 ? 890.0 : (screenHeight - 32.0).clamp(500.0, 890.0);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Container(
          width: frameWidth,
          height: frameHeight,
          margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(
              color: const Color(0xFF334155),
              width: 3.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 40,
                spreadRadius: 6,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.15),
                blurRadius: 80,
                spreadRadius: 10,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32.5),
            child: MediaQuery(
              data: mediaQuery.copyWith(
                size: Size(frameWidth, frameHeight),
                padding: const EdgeInsets.only(top: 24, bottom: 16),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
