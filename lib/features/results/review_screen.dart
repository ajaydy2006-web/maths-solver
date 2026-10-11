import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../data/models.dart';

class ReviewScreen extends StatefulWidget {
  final Map<String, dynamic> result;

  const ReviewScreen({Key? key, required this.result}) : super(key: key);

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  String _filter = 'All'; // 'All', 'Incorrect', 'Correct'

  @override
  Widget build(BuildContext context) {
    final attempts = (widget.result['attempts'] as List<dynamic>?)
            ?.cast<QuestionAttempt>() ??
        [];
    final category = widget.result['category'] as String? ?? 'Practice';
    final correctCount = widget.result['correctAnswers'] as int? ?? 0;
    final totalCount = widget.result['totalQuestions'] as int? ?? attempts.length;

    final filteredAttempts = attempts.where((attempt) {
      if (_filter == 'Incorrect') return !attempt.isCorrect;
      if (_filter == 'Correct') return attempt.isCorrect;
      return true;
    }).toList();

    final wrongCount = totalCount - correctCount;

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: const Text("Review Answers"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Overview Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Card(
                color: AppColors.surfacePrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Text("Category", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 36, color: Colors.grey.shade300),
                      Expanded(
                        child: Column(
                          children: [
                            const Text("Score", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "${widget.result['score'] ?? 0} pts",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryOrange),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 36, color: Colors.grey.shade300),
                      Expanded(
                        child: Column(
                          children: [
                            const Text("Accuracy", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                totalCount > 0 ? "${((correctCount / totalCount) * 100).toStringAsFixed(0)}%" : "0%",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.successGreen),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  _buildFilterChip('All', 'All (${attempts.length})'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Incorrect', 'Wrong ($wrongCount)', color: AppColors.pastelPink),
                  const SizedBox(width: 8),
                  _buildFilterChip('Correct', 'Correct ($correctCount)', color: AppColors.pastelGreen),
                ],
              ),
            ),

            // Question Attempts List
            Expanded(
              child: filteredAttempts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 64, color: AppColors.pastelGreen),
                          const SizedBox(height: 12),
                          Text(
                            _filter == 'Incorrect' ? "No wrong answers! Awesome job!" : "No questions found.",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      itemCount: filteredAttempts.length,
                      itemBuilder: (context, index) {
                        final attempt = filteredAttempts[index];
                        final questionIndex = attempts.indexOf(attempt) + 1;
                        return _buildQuestionCard(context, attempt, questionIndex);
                      },
                    ),
            ),

            // Bottom Action Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => context.go('/home'),
                  child: const Text("Return to Home"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label, {Color? color}) {
    final isSelected = _filter == filterKey;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: color ?? AppColors.pastelBlue,
      backgroundColor: AppColors.surfacePrimary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      onSelected: (val) {
        if (val) setState(() => _filter = filterKey);
      },
    );
  }

  Widget _buildQuestionCard(BuildContext context, QuestionAttempt attempt, int questionNumber) {
    final q = attempt.question;
    final isCorrect = attempt.isCorrect;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCorrect ? AppColors.pastelGreen : AppColors.pastelPink,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Q$questionNumber",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundCream,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        q.difficulty,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      color: isCorrect ? AppColors.successGreen : AppColors.errorRed,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isCorrect ? "Correct" : "Incorrect",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isCorrect ? AppColors.successGreen : AppColors.errorRed,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Expression
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surfacePrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                q.displayExpression,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),

            // User Answer vs Correct Answer
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? AppColors.pastelGreen.withOpacity(0.4)
                          : AppColors.pastelPink.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Your Answer",
                          style: TextStyle(
                            fontSize: 11,
                            color: isCorrect ? AppColors.successGreen : AppColors.errorRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          attempt.selectedAnswer,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isCorrect ? AppColors.successGreen : AppColors.errorRed,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.pastelGreen.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Correct Answer",
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.successGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          q.correctAnswer,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.successGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Explanation & Mental Shortcut
            if (q.explanation != null && q.explanation!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.pastelPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.pastelPurple.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.lightbulb_outline, size: 16, color: AppColors.darkSlate),
                        SizedBox(width: 4),
                        Text(
                          "Mental Shortcut & Explanation",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlate,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      q.explanation!,
                      style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
