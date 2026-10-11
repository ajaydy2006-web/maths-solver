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
    } catch (_) {}
  }

  String _formatDuration(int seconds) {
    final m = (seconds / 60).floor();
    final s = seconds % 60;
    if (m > 0 && s > 0) {
      return '$m min $s sec';
    } else if (m > 0) {
      return '$m min${m > 1 ? 's' : ''}';
    } else {
      return '$s sec';
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
    final score = widget.result['score'] ?? 0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/home');
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundCream,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => context.go('/home'),
          ),
          title: const Text(
            "Session Summary",
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxHeight < 620;
              final isNarrow = constraints.maxWidth < 360;
              final trophySize = isCompact ? 56.0 : 80.0;
              final iconSize = isCompact ? 32.0 : 48.0;
              final hPadding = isNarrow ? 14.0 : 20.0;
              final titleFontSize = isCompact ? 22.0 : 28.0;
              final buttonHeight = isCompact ? 44.0 : 50.0;
              final buttonFontSize = isCompact ? 13.5 : 15.0;
              final statTileFontSize = isCompact ? 18.0 : 24.0;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: hPadding,
                  vertical: isCompact ? 6.0 : 14.0,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - (isCompact ? 12.0 : 28.0),
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Badge Header
                        Center(
                          child: Container(
                            width: trophySize,
                            height: trophySize,
                            decoration: BoxDecoration(
                              color: AppColors.highlightYellow.withOpacity(0.35),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.highlightYellow.withOpacity(0.4),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.emoji_events_rounded,
                                size: iconSize,
                                color: AppColors.primaryOrange,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isCompact ? 6 : 12),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "Session Complete!",
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontSize: titleFontSize,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "$category • ${_formatDuration(duration)} practice",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: isCompact ? 10 : 16),

                        // Accuracy Progress Bar
                        if (total > 0) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              height: 8,
                              child: Row(
                                children: [
                                  if (correct > 0)
                                    Expanded(
                                      flex: correct,
                                      child: Container(color: AppColors.successGreen),
                                    ),
                                  if (total - correct > 0)
                                    Expanded(
                                      flex: total - correct,
                                      child: Container(color: AppColors.errorRed.withOpacity(0.7)),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: isCompact ? 10 : 16),
                        ],

                        // Responsive 2x2 Stats Grid (Adapts cleanly to all screen sizes)
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatTile(
                                context,
                                title: "Total Score",
                                value: "$score pts",
                                subtitle: "Points earned",
                                color: AppColors.primaryOrange,
                                icon: Icons.military_tech_rounded,
                                isCompact: isCompact,
                                valueFontSize: statTileFontSize,
                              ),
                            ),
                            SizedBox(width: isNarrow ? 8 : 12),
                            Expanded(
                              child: _buildStatTile(
                                context,
                                title: "Accuracy",
                                value: "$accuracy%",
                                subtitle: "Success rate",
                                color: AppColors.successGreen,
                                icon: Icons.pie_chart_outline_rounded,
                                isCompact: isCompact,
                                valueFontSize: statTileFontSize,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isNarrow ? 8 : 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatTile(
                                context,
                                title: "Correct Answers",
                                value: "$correct / $total",
                                subtitle: "Questions solved",
                                color: AppColors.pastelBlue,
                                icon: Icons.check_circle_outline_rounded,
                                isCompact: isCompact,
                                valueFontSize: statTileFontSize,
                              ),
                            ),
                            SizedBox(width: isNarrow ? 8 : 12),
                            Expanded(
                              child: _buildStatTile(
                                context,
                                title: "Avg Speed",
                                value: "$avgSpeed s",
                                subtitle: "Per question",
                                color: AppColors.pastelPurple,
                                icon: Icons.speed_rounded,
                                isCompact: isCompact,
                                valueFontSize: statTileFontSize,
                              ),
                            ),
                          ],
                        ),

                        // Spacer pushes buttons to the bottom when space allows
                        const Spacer(),
                        SizedBox(height: isCompact ? 14 : 24),

                        // Primary Action: Back to Home
                        SizedBox(
                          height: buttonHeight,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryOrange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              elevation: 2,
                            ),
                            icon: const Icon(Icons.home_rounded, size: 20),
                            label: Text(
                              "Back to Home",
                              style: TextStyle(fontSize: buttonFontSize, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () => context.go('/home'),
                          ),
                        ),
                        SizedBox(height: isCompact ? 6 : 10),

                        // Secondary Action: Review Answers
                        SizedBox(
                          height: buttonHeight,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.pastelPurple.withOpacity(0.6),
                              foregroundColor: AppColors.textPrimary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                            icon: const Icon(Icons.visibility_rounded, size: 18),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "Review Answers & Explanations",
                                style: TextStyle(fontSize: buttonFontSize - 0.5, fontWeight: FontWeight.w600),
                              ),
                            ),
                            onPressed: () {
                              context.push('/review', extra: widget.result);
                            },
                          ),
                        ),
                        SizedBox(height: isCompact ? 6 : 10),

                        // Tertiary Action: Practice Again
                        SizedBox(
                          height: buttonHeight - 2,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              side: const BorderSide(color: Colors.black26),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                            icon: const Icon(Icons.replay_rounded, size: 18),
                            label: Text(
                              "Practice Again",
                              style: TextStyle(fontSize: buttonFontSize - 0.5, fontWeight: FontWeight.w600),
                            ),
                            onPressed: () {
                              context.go('/config/${Uri.encodeComponent(category)}');
                            },
                          ),
                        ),

                        SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
    required bool isCompact,
    double valueFontSize = 24.0,
  }) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 10.0 : 16.0),
      decoration: BoxDecoration(
        color: AppColors.surfacePrimary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, size: 18, color: color),
            ],
          ),
          SizedBox(height: isCompact ? 3 : 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: valueFontSize,
                fontWeight: FontWeight.bold,
                color: color == AppColors.pastelPurple ? AppColors.darkSlate : (color == AppColors.pastelBlue ? AppColors.darkSlate : color),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
