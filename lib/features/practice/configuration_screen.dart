import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import 'widgets/calendar_time_selector.dart';

class ConfigurationScreen extends ConsumerStatefulWidget {
  final String category;
  const ConfigurationScreen({Key? key, required this.category}) : super(key: key);

  @override
  ConsumerState<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends ConsumerState<ConfigurationScreen> {
  String _difficulty = 'Medium';
  int _timerSeconds = 3;
  int _questionCount = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: Text(widget.category, style: Theme.of(context).textTheme.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: AppColors.surfacePrimary,
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Difficulty", style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: ['Easy', 'Medium', 'Hard'].map((d) {
                          final isSelected = _difficulty == d;
                          return ChoiceChip(
                            label: Text(d),
                            selected: isSelected,
                            selectedColor: AppColors.pastelGreen,
                            backgroundColor: AppColors.backgroundCream,
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              if (val) setState(() => _difficulty = d);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Timer Duration", style: Theme.of(context).textTheme.titleLarge),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              "$_timerSeconds s",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFEF4444),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Calendar-inspired time selector
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8FA),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFEAEBED), width: 1),
                        ),
                        child: CalendarTimeSelector(
                          selectedSeconds: _timerSeconds,
                          onTimeChanged: (val) {
                            setState(() => _timerSeconds = val);
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primaryOrange.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Text("⚡", style: TextStyle(fontSize: 22)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Endless Survival Mode", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 2),
                                  Text("Questions continue until all 3 lives are lost.", style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    final config = PracticeConfiguration(
                      category: widget.category,
                      difficulty: _difficulty,
                      timerSeconds: _timerSeconds,
                      questionCount: _questionCount,
                    );
                    if (widget.category == 'Mental Calculation') {
                      context.push('/mental-session', extra: config);
                    } else {
                      context.push('/session', extra: config);
                    }
                  },
                  child: const Text("Start Practice"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
