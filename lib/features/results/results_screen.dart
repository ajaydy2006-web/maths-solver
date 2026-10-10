import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../data/database_helper.dart';
import '../../data/providers.dart';

class ResultsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> result;

  const ResultsScreen({Key? key, required this.result}) : super(key: key);

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _saveResultToDb();
  }

  Future<void> _saveResultToDb() async {
    if (_saved) return;
    _saved = true;

    try {
      final dbData = {
        'category': widget.result['category'] ?? 'Practice',
        'date': DateTime.now().toIso8601String(),
        'score': widget.result['score'] ?? 0,
        'correctAnswers': widget.result['correctAnswers'] ?? 0,
        'incorrectAnswers': widget.result['incorrectAnswers'] ?? 0,
        'totalQuestions': widget.result['totalQuestions'] ?? 0,
        'durationSeconds': widget.result['durationSeconds'] ?? 0,
      };

      await DatabaseHelper.instance.saveSessionResult(dbData);
      ref.read(statsNotifierProvider.notifier).loadStats();
    } catch (e) {
      // In-memory fallback if storage write fails
    }
  }

  @override
  Widget build(BuildContext context) {
    final correct = widget.result['correctAnswers'] as int? ?? 0;
    final total = widget.result['totalQuestions'] as int? ?? 0;
    final duration = widget.result['durationSeconds'] as int? ?? 0;
    final category = widget.result['category'] as String? ?? 'Practice';
    final accuracy = total > 0 ? ((correct / total) * 100).toStringAsFixed(1) : '0';
    final avgSpeed = total > 0 ? (duration / total).toStringAsFixed(1) : '0';

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // Trophy Badge
              Center(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: AppColors.highlightYellow.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.emoji_events, size: 70, color: AppColors.primaryOrange),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Session Complete!",
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 30),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                category,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 18,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Main Stats Card
              Card(
                color: AppColors.surfacePrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      _buildStatRow(
                        context,
                        "Total Score",
                        "${widget.result['score'] ?? 0} pts",
                        AppColors.primaryOrange,
                        Icons.military_tech,
                      ),
                      const Divider(height: 28),
                      _buildStatRow(
                        context,
                        "Correct Answers",
                        "$correct / $total",
                        AppColors.successGreen,
                        Icons.check_circle_outline,
                      ),
                      const Divider(height: 28),
                      _buildStatRow(
                        context,
                        "Accuracy",
                        "$accuracy%",
                        AppColors.pastelBlue,
                        Icons.pie_chart_outline,
                      ),
                      const Divider(height: 28),
                      _buildStatRow(
                        context,
                        "Avg Speed",
                        "$avgSpeed s/Q",
                        AppColors.darkSlate,
                        Icons.speed,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pastelPurple,
                    foregroundColor: AppColors.textPrimary,
                    elevation: 1,
                  ),
                  icon: const Icon(Icons.visibility),
                  label: const Text("Review Answers & Explanations"),
                  onPressed: () {
                    context.push('/review', extra: widget.result);
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Practice Again"),
                  onPressed: () {
                    context.pushReplacement('/config/${Uri.encodeComponent(category)}');
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 54,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: Colors.black26),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: () => context.go('/home'),
                  child: const Text("Return Home", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value, Color color, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 22, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
            ),
          ],
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
