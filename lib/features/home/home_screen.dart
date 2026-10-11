import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../data/providers.dart';
import '../progress/progress_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentTabIndex = 0;
  bool _isNavigating = false;

  void _onCategoryTapped(String category) {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);
    HapticFeedback.selectionClick();

    if (category == 'Arithmetic' || category == 'Basic Arithmetic') {
      context.push('/operations/arithmetic').then((_) {
        if (mounted) setState(() => _isNavigating = false);
      });
    } else {
      context.push('/config/${Uri.encodeComponent(category)}').then((_) {
        if (mounted) setState(() => _isNavigating = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          _buildHomeTab(context),
          const ProgressScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surfacePrimary,
        selectedItemColor: AppColors.primaryOrange,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    final prefsState = ref.watch(userPreferencesNotifierProvider);
    final statsState = ref.watch(statsNotifierProvider);

    final displayName = prefsState.value?.displayName ?? 'Calculator';
    final dailyGoal = prefsState.value?.dailyGoalMinutes ?? 10;
    final todayMinutes = statsState.value?['todayPracticeMinutes'] as int? ?? 0;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 360;
          final crossAxisCount = isNarrow ? 1 : 2;
          final childAspectRatio = isNarrow ? 2.3 : 0.88;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header User Profile Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Hey, $displayName!",
                                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 26),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Ready to calculate faster today?",
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _currentTabIndex = 2; // Switch to profile tab
                              });
                            },
                            child: CircleAvatar(
                              backgroundColor: AppColors.pastelPurple,
                              radius: 22,
                              child: Text(
                                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'C',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 17),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Daily Goal Card
                      _buildDailyGoalCard(context, dailyGoal, todayMinutes),
                      const SizedBox(height: 24),

                      // Section Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Practice Categories",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryOrange.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "${AppConstants.categories.length} Modules",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryOrange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),

              // Categories Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: childAspectRatio,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final categoryKey = AppConstants.categories[index];
                      final metadata = AppConstants.categoryDetails[categoryKey] ??
                          CategoryMetadata(
                            title: categoryKey,
                            description: 'Mental calculation drill',
                            icon: Icons.calculate_rounded,
                            color: AppColors.pastelBlue,
                          );

                      return _buildCategoryCard(
                        context,
                        metadata: metadata,
                        categoryKey: categoryKey,
                        onTap: () => _onCategoryTapped(categoryKey),
                      );
                    },
                    childCount: AppConstants.categories.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDailyGoalCard(BuildContext context, int goalMinutes, int todayMinutes) {
    final progress = goalMinutes > 0 ? (todayMinutes / goalMinutes).clamp(0.0, 1.0) : 0.0;
    final isGoalReached = todayMinutes >= goalMinutes;

    return Card(
      color: AppColors.surfacePrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_fire_department_rounded, color: AppColors.primaryOrange, size: 24),
                    const SizedBox(width: 8),
                    Text("Daily Practice Goal", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 17)),
                  ],
                ),
                if (isGoalReached)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.pastelGreen, borderRadius: BorderRadius.circular(12)),
                    child: const Text("Goal Met!", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isGoalReached ? "Target achieved! Keep pushing your streak." : "Stay consistent to build rapid mental calculation reflexes.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 14),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.backgroundCream,
              color: AppColors.primaryOrange,
              minHeight: 10,
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("$todayMinutes / $goalMinutes minutes today", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text("${(progress * 100).toInt()}%", style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required CategoryMetadata metadata,
    required String categoryKey,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        splashColor: metadata.color.withOpacity(0.3),
        highlightColor: metadata.color.withOpacity(0.15),
        child: Container(
          decoration: BoxDecoration(
            color: metadata.color.withOpacity(0.32),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: metadata.color.withOpacity(0.7),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Native Icon Circle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(metadata.icon, color: AppColors.textPrimary, size: 22),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: AppColors.textPrimary.withOpacity(0.5),
                  ),
                ],
              ),
              const Spacer(),
              // Title
              Text(
                metadata.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 16,
                      height: 1.2,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Short Description
              Text(
                metadata.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimary.withOpacity(0.75),
                      fontSize: 11.5,
                      height: 1.25,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
