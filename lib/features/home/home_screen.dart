import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          _buildHomeTab(context),
          _buildPracticeTab(context),
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.timer_outlined), label: 'Practice'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
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
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hey, $displayName!",
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Ready to calculate faster today?",
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentTabIndex = 3; // Switch to profile tab
                          });
                        },
                        child: CircleAvatar(
                          backgroundColor: AppColors.pastelPurple,
                          radius: 24,
                          child: Text(
                            displayName.isNotEmpty ? displayName[0].toUpperCase() : 'C',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDailyGoalCard(context, dailyGoal, todayMinutes),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Practice Categories",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        "${AppConstants.categories.length} Modules",
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildCategoryCard(
                    context,
                    category: AppConstants.categories[index],
                    color: _getCategoryColor(index),
                    icon: _getCategoryIcon(index),
                    onTap: () {
                      context.push('/config/${Uri.encodeComponent(AppConstants.categories[index])}');
                    },
                  );
                },
                childCount: AppConstants.categories.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildPracticeTab(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Text("Quick Practice", style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28)),
          const SizedBox(height: 6),
          Text("Pick any mode and train under competitive exam conditions.", style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          Card(
            color: AppColors.primaryOrange.withOpacity(0.12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: ListTile(
              leading: const Icon(Icons.flash_on, color: AppColors.primaryOrange, size: 36),
              title: const Text("Rapid 60-Second Blitz", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("Mixed questions across all competitive math areas"),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: () {
                  final config = PracticeConfiguration(
                    category: 'Mixed Practice',
                    timerSeconds: 60,
                    questionCount: 20,
                  );
                  context.push('/session', extra: config);
                },
                child: const Text("Start Blitz"),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text("All Topics", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ...AppConstants.categories.asMap().entries.map((entry) {
            final idx = entry.key;
            final cat = entry.value;
            return Card(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getCategoryColor(idx).withOpacity(0.7),
                  child: Icon(_getCategoryIcon(idx), color: AppColors.textPrimary, size: 20),
                ),
                title: Text(cat, style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
                onTap: () {
                  context.push('/config/${Uri.encodeComponent(cat)}');
                },
              ),
            );
          }).toList(),
        ],
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_fire_department, color: AppColors.primaryOrange, size: 24),
                    const SizedBox(width: 8),
                    Text("Daily Practice Goal", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
                  ],
                ),
                if (isGoalReached)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.pastelGreen, borderRadius: BorderRadius.circular(12)),
                    child: const Text("Goal Met!", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              isGoalReached ? "Target achieved! Keep pushing your record." : "Stay consistent to build razor-sharp mental arithmetic.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.backgroundCream,
              color: AppColors.primaryOrange,
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("$todayMinutes / $goalMinutes minutes today", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text("${(progress * 100).toInt()}%", style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required String category,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.textPrimary, size: 22),
              ),
              const Spacer(),
              Text(
                category,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16, height: 1.2),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(int index) {
    final colors = [
      AppColors.pastelBlue,
      AppColors.pastelGreen,
      AppColors.pastelPink,
      AppColors.pastelPurple,
      AppColors.highlightYellow,
      AppColors.pastelBlue,
      AppColors.pastelGreen,
      AppColors.pastelPink,
      AppColors.pastelPurple,
      AppColors.highlightYellow,
    ];
    return colors[index % colors.length];
  }

  IconData _getCategoryIcon(int index) {
    final icons = [
      Icons.calculate,
      Icons.shuffle,
      Icons.functions,
      Icons.format_list_numbered,
      Icons.compare_arrows,
      Icons.psychology,
      Icons.question_mark,
      Icons.extension,
      Icons.category,
      Icons.build,
    ];
    return icons[index % icons.length];
  }
}
