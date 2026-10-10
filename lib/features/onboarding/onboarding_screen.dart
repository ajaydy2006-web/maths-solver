import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../data/providers.dart';
import '../../data/models.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  List<String> _selectedExams = [];
  String _currentLevel = 'Beginner';
  int _dailyGoalMinutes = 10;

  void _nextPage() {
    if (_currentIndex < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() async {
    final notifier = ref.read(userPreferencesNotifierProvider.notifier);
    final currentPrefsOpt = ref.read(userPreferencesNotifierProvider).value;
    
    final currentPrefs = currentPrefsOpt ?? UserPreferences();
    
    final newPrefs = UserPreferences(
      displayName: currentPrefs.displayName,
      examGoals: _selectedExams,
      currentLevel: _currentLevel,
      dailyGoalMinutes: _dailyGoalMinutes,
      hasCompletedOnboarding: true,
      wrongAnswerThreshold: currentPrefs.wrongAnswerThreshold,
      threeWrongRestartEnabled: currentPrefs.threeWrongRestartEnabled,
      soundEnabled: currentPrefs.soundEnabled,
      hapticsEnabled: currentPrefs.hapticsEnabled,
    );
    
    await notifier.updatePrefs(newPrefs);
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finishOnboarding,
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildWelcomeScreen(),
                  _buildExamGoalsScreen(),
                  _buildLevelScreen(),
                  _buildDailyGoalScreen(),
                  _buildReadyScreen(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  child: Text(_currentIndex == 4 ? "Start Practising" : "Continue"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return _buildPageWrapper(
      title: "Train Your Brain.",
      description: "Build calculation speed, accuracy, and confidence for your next exam.",
      content: const Icon(Icons.fitness_center, size: 100, color: AppColors.primaryOrange),
    );
  }

  Widget _buildExamGoalsScreen() {
    final options = ['SSC', 'Railway', 'Banking', 'State Government Exams', 'Other Competitive Exams'];
    return _buildPageWrapper(
      title: "What are you preparing for?",
      description: "Select all that apply.",
      content: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: options.map((opt) {
          final isSelected = _selectedExams.contains(opt);
          return _buildSelectionCard(
            title: opt,
            isSelected: isSelected,
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedExams.remove(opt);
                } else {
                  _selectedExams.add(opt);
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLevelScreen() {
    final options = ['Beginner', 'Intermediate', 'Advanced'];
    return _buildPageWrapper(
      title: "Where are you starting from?",
      description: "We'll tailor your starting difficulty.",
      content: Column(
        children: options.map((opt) {
          final isSelected = _currentLevel == opt;
          return _buildSelectionCard(
            title: opt,
            isSelected: isSelected,
            onTap: () {
              setState(() {
                _currentLevel = opt;
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDailyGoalScreen() {
    final options = [5, 10, 15, 20];
    return _buildPageWrapper(
      title: "How much will you practise daily?",
      description: "Consistency is key.",
      content: Column(
        children: options.map((opt) {
          final isSelected = _dailyGoalMinutes == opt;
          return _buildSelectionCard(
            title: "$opt minutes",
            isSelected: isSelected,
            onTap: () {
              setState(() {
                _dailyGoalMinutes = opt;
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReadyScreen() {
    return _buildPageWrapper(
      title: "You're Ready!",
      description: "Your journey starts today. Let's make you faster.",
      content: Card(
        color: AppColors.pastelBlue,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Level: $_currentLevel", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text("Goal: $_dailyGoalMinutes mins/day", style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageWrapper({required String title, required String description, required Widget content}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.displayLarge),
          const SizedBox(height: 16),
          Text(description, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 48),
          content,
        ],
      ),
    );
  }

  Widget _buildSelectionCard({required String title, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: isSelected ? AppColors.pastelGreen : AppColors.surfacePrimary,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? AppColors.successGreen : Colors.transparent,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
