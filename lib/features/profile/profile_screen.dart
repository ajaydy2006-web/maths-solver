import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final prefsState = ref.watch(userPreferencesNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: const Text("Profile & Settings"),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: prefsState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text("Error: $err")),
          data: (prefs) {
            return ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                // User Profile Header Card
                _buildProfileHeaderCard(context, prefs),
                const SizedBox(height: 24),

                // Exam Goals Section
                Text("Target Exam Goals", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                _buildExamGoalsCard(context, prefs),
                const SizedBox(height: 24),

                // 3-Wrong Restart Rule Settings
                Text("Practice Challenge Rules", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                _buildChallengeRulesCard(context, prefs),
                const SizedBox(height: 24),

                // Daily Goal & Sound Preferences
                Text("Preferences", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                _buildPreferencesCard(context, prefs),
                const SizedBox(height: 24),

                // Data Management
                Text("Data Management", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                _buildDataManagementCard(context),
                const SizedBox(height: 32),

                // App Info & Version
                Center(
                  child: Column(
                    children: [
                      Text(
                        "${AppConstants.appName} v1.0.0",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppConstants.tagline,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeaderCard(BuildContext context, UserPreferences prefs) {
    return Card(
      color: AppColors.surfacePrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.pastelPurple,
              child: Text(
                prefs.displayName.isNotEmpty ? prefs.displayName[0].toUpperCase() : 'C',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          prefs.displayName,
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 22),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18, color: AppColors.primaryOrange),
                        onPressed: () => _showEditNameDialog(prefs),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.pastelGreen.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Level: ${prefs.currentLevel}",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamGoalsCard(BuildContext context, UserPreferences prefs) {
    final availableExams = ['SSC', 'Railway', 'Banking', 'State Government Exams', 'Other Competitive Exams'];

    return Card(
      color: AppColors.surfacePrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableExams.map((exam) {
            final isSelected = prefs.examGoals.contains(exam);
            return FilterChip(
              label: Text(exam),
              selected: isSelected,
              selectedColor: AppColors.pastelGreen,
              backgroundColor: AppColors.backgroundCream,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (selected) {
                final updated = List<String>.from(prefs.examGoals);
                if (selected) {
                  updated.add(exam);
                } else {
                  updated.remove(exam);
                }
                ref.read(userPreferencesNotifierProvider.notifier).updatePrefs(
                      prefs.copyWith(examGoals: updated),
                    );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildChallengeRulesCard(BuildContext context, UserPreferences prefs) {
    return Card(
      color: AppColors.surfacePrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("3-Wrong Restart Rule", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text(
                "Restarts practice session if mistake threshold is hit to reinforce flawless accuracy.",
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              value: prefs.threeWrongRestartEnabled,
              activeColor: AppColors.primaryOrange,
              onChanged: (val) {
                ref.read(userPreferencesNotifierProvider.notifier).updatePrefs(
                      prefs.copyWith(threeWrongRestartEnabled: val),
                    );
              },
            ),
            if (prefs.threeWrongRestartEnabled) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Mistake Threshold", style: TextStyle(fontSize: 14)),
                    Text(
                      "${prefs.wrongAnswerThreshold} Mistakes",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.errorRed),
                    ),
                  ],
                ),
              ),
              Slider(
                value: prefs.wrongAnswerThreshold.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: "${prefs.wrongAnswerThreshold}",
                activeColor: AppColors.errorRed,
                onChanged: (val) {
                  ref.read(userPreferencesNotifierProvider.notifier).updatePrefs(
                        prefs.copyWith(wrongAnswerThreshold: val.toInt()),
                      );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesCard(BuildContext context, UserPreferences prefs) {
    return Card(
      color: AppColors.surfacePrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Daily Target Practice Time", style: TextStyle(fontWeight: FontWeight.w600)),
                DropdownButton<int>(
                  value: prefs.dailyGoalMinutes,
                  underline: const SizedBox(),
                  items: [5, 10, 15, 20, 30].map((mins) {
                    return DropdownMenuItem<int>(
                      value: mins,
                      child: Text("$mins mins/day"),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(userPreferencesNotifierProvider.notifier).updatePrefs(
                            prefs.copyWith(dailyGoalMinutes: val),
                          );
                    }
                  },
                ),
              ],
            ),
            const Divider(),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Sound Effects"),
              value: prefs.soundEnabled,
              activeColor: AppColors.primaryOrange,
              onChanged: (val) {
                ref.read(userPreferencesNotifierProvider.notifier).updatePrefs(
                      prefs.copyWith(soundEnabled: val),
                    );
              },
            ),
            const Divider(),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Haptic Feedback"),
              value: prefs.hapticsEnabled,
              activeColor: AppColors.primaryOrange,
              onChanged: (val) {
                ref.read(userPreferencesNotifierProvider.notifier).updatePrefs(
                      prefs.copyWith(hapticsEnabled: val),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataManagementCard(BuildContext context) {
    return Card(
      color: AppColors.surfacePrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.delete_outline, color: AppColors.errorRed),
              title: const Text("Clear Practice History"),
              subtitle: const Text("Deletes recorded sessions and accuracy charts", style: TextStyle(fontSize: 12)),
              onTap: () => _confirmClearHistory(),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.restore, color: AppColors.darkSlate),
              title: const Text("Reset All Settings & Data"),
              subtitle: const Text("Re-initializes preferences and stats to factory state", style: TextStyle(fontSize: 12)),
              onTap: () => _confirmResetAll(),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditNameDialog(UserPreferences prefs) {
    final controller = TextEditingController(text: prefs.displayName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Change Name"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter your name"),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                ref.read(userPreferencesNotifierProvider.notifier).updatePrefs(
                      prefs.copyWith(displayName: newName),
                    );
              }
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _confirmClearHistory() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Clear History?"),
        content: const Text("This will permanently erase all completed session records and stats."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
            onPressed: () async {
              await ref.read(statsNotifierProvider.notifier).clearHistory();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Session history cleared successfully.")),
              );
            },
            child: const Text("Clear"),
          ),
        ],
      ),
    );
  }

  void _confirmResetAll() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Reset Everything?"),
        content: const Text("All user settings, preferences, and progress will be reset."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
            onPressed: () async {
              await ref.read(statsNotifierProvider.notifier).resetAll();
              await ref.read(userPreferencesNotifierProvider.notifier).reload();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("All data has been reset to defaults.")),
              );
            },
            child: const Text("Reset"),
          ),
        ],
      ),
    );
  }
}
