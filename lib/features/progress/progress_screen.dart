import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/providers.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsState = ref.watch(statsNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: const Text("Progress & Analytics"),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: statsState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text("Error loading progress: $err")),
          data: (stats) {
            final totalSessions = stats['totalSessions'] as int? ?? 0;
            final totalQuestions = stats['totalQuestions'] as int? ?? 0;
            final avgAccuracy = (stats['averageAccuracy'] as num?)?.toDouble() ?? 0.0;
            final totalMinutes = stats['totalPracticeMinutes'] as int? ?? 0;
            final categoryBreakdown = (stats['categoryBreakdown'] as Map<String, dynamic>?) ?? {};
            final recentSessions = (stats['recentSessions'] as List<dynamic>?)?.cast<SessionRecord>() ?? [];

            if (totalSessions == 0) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () => ref.read(statsNotifierProvider.notifier).loadStats(),
              child: ListView(
                padding: const EdgeInsets.all(20.0),
                children: [
                  // Overview Headline Metrics Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          context,
                          title: "Sessions",
                          value: "$totalSessions",
                          subtitle: "completed",
                          color: AppColors.pastelBlue,
                          icon: Icons.check_circle_outline,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          context,
                          title: "Accuracy",
                          value: "${avgAccuracy.toStringAsFixed(1)}%",
                          subtitle: "overall average",
                          color: AppColors.pastelGreen,
                          icon: Icons.pie_chart,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          context,
                          title: "Questions",
                          value: "$totalQuestions",
                          subtitle: "solved",
                          color: AppColors.highlightYellow,
                          icon: Icons.calculate_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          context,
                          title: "Time",
                          value: "${totalMinutes}m",
                          subtitle: "practised",
                          color: AppColors.pastelPurple,
                          icon: Icons.timelapse,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Category Breakdown
                  Text("Category Breakdown", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Card(
                    color: AppColors.surfacePrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: categoryBreakdown.isEmpty
                          ? const Text("No category data available yet.")
                          : Column(
                              children: categoryBreakdown.entries.map((entry) {
                                final cat = entry.key;
                                final catStats = entry.value as Map<String, dynamic>;
                                final total = catStats['total'] as int? ?? 0;
                                final correct = catStats['correct'] as int? ?? 0;
                                final acc = total > 0 ? (correct / total) : 0.0;
                                final percentStr = (acc * 100).toStringAsFixed(0);

                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            cat,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                          Text(
                                            "$percentStr% ($correct/$total)",
                                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      LinearProgressIndicator(
                                        value: acc,
                                        backgroundColor: AppColors.backgroundCream,
                                        color: _getAccuracyColor(acc),
                                        minHeight: 8,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Recent Sessions
                  Text("Recent Sessions", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  ...recentSessions.map((s) => _buildSessionHistoryTile(context, s)).toList(),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.pastelBlue.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bar_chart, size: 64, color: AppColors.darkSlate),
            ),
            const SizedBox(height: 24),
            Text("No Practice Data Yet", style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 8),
            Text(
              "Complete your first practice session to see accuracy, speeds, and performance insights.",
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text("Start Practicing Now"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      color: AppColors.surfacePrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: color.withOpacity(0.35), shape: BoxShape.circle),
                  child: Icon(icon, size: 16, color: AppColors.darkSlate),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionHistoryTile(BuildContext context, SessionRecord session) {
    final acc = session.accuracy.toStringAsFixed(0);
    final dateDisplay = session.date.length >= 10 ? session.date.substring(0, 10) : session.date;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(session.category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text("$dateDisplay • ${session.durationSeconds}s duration", style: const TextStyle(fontSize: 12)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("${session.score} pts", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryOrange)),
            Text("$acc% Acc (${session.correctAnswers}/${session.totalQuestions})",
                style: TextStyle(fontSize: 11, color: session.accuracy >= 70 ? AppColors.successGreen : AppColors.errorRed)),
          ],
        ),
      ),
    );
  }

  Color _getAccuracyColor(double acc) {
    if (acc >= 0.8) return AppColors.successGreen;
    if (acc >= 0.5) return AppColors.primaryOrange;
    return AppColors.errorRed;
  }
}
