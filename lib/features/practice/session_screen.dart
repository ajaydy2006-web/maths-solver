import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../services/question_generator.dart';

class SessionScreen extends ConsumerStatefulWidget {
  final PracticeConfiguration config;
  const SessionScreen({Key? key, required this.config}) : super(key: key);

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  late List<GeneratedQuestion> _questions;
  int _currentIndex = 0;
  
  int _correctCount = 0;
  int _wrongCount = 0;
  int _consecutiveWrongCount = 0; // For 3-wrong restart rule
  
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isSubmitting = false;

  late int _wrongThreshold;
  late bool _threeWrongRestartEnabled;

  final List<QuestionAttempt> _attempts = [];
  DateTime _questionStartTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(userPreferencesNotifierProvider).value;
    _wrongThreshold = prefs?.wrongAnswerThreshold ?? 3;
    _threeWrongRestartEnabled = prefs?.threeWrongRestartEnabled ?? true;
    _startSession();
  }

  void _startSession() {
    _questions = QuestionGenerator.generateQuestions(widget.config);
    _currentIndex = 0;
    _correctCount = 0;
    _wrongCount = 0;
    _attempts.clear();
    _remainingSeconds = 0;
    _questionStartTime = DateTime.now();
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _remainingSeconds++;
      });
    });
  }

  void _finalizeSession({bool terminatedDueToMistakes = false}) {
    _timer?.cancel();
    
    final result = {
      'category': widget.config.category,
      'score': _correctCount * 10,
      'correctAnswers': _correctCount,
      'incorrectAnswers': _wrongCount,
      'totalQuestions': _attempts.length,
      'durationSeconds': _remainingSeconds,
      'attempts': _attempts,
      'terminated': terminatedDueToMistakes,
    };
    
    context.pushReplacement('/results', extra: result);
  }

  void _submitAnswer(String selectedOption) async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
    });

    final currentQuestion = _questions[_currentIndex];
    final isCorrect = selectedOption == currentQuestion.correctAnswer;
    final timeSpent = DateTime.now().difference(_questionStartTime).inSeconds;

    _attempts.add(
      QuestionAttempt(
        question: currentQuestion,
        selectedAnswer: selectedOption,
        isCorrect: isCorrect,
        durationSeconds: timeSpent,
      ),
    );

    if (isCorrect) {
      _correctCount++;
    } else {
      _wrongCount++;
    }

    await Future.delayed(const Duration(milliseconds: 350));
    
    if (!mounted) return;

    if (_wrongCount >= _wrongThreshold) {
      _isSubmitting = false;
      _finalizeSession(terminatedDueToMistakes: true);
      return;
    }

    setState(() {
      _currentIndex++;
      if (_currentIndex >= _questions.length) {
        _questions.addAll(QuestionGenerator.generateQuestions(widget.config));
      }
      _questionStartTime = DateTime.now();
      _isSubmitting = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final currentQuestion = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: Text(widget.config.category, style: Theme.of(context).textTheme.titleLarge),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfacePrimary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 18, color: AppColors.primaryOrange),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(_remainingSeconds),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _remainingSeconds < 10 ? AppColors.errorRed : AppColors.primaryOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with counter and lives indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Question ${_currentIndex + 1}",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                  ),
                  if (_threeWrongRestartEnabled)
                    Row(
                      children: List.generate(_wrongThreshold, (idx) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Icon(
                            Icons.favorite,
                            size: 16,
                            color: idx < (_wrongThreshold - _wrongCount)
                                ? AppColors.errorRed
                                : Colors.grey.shade400,
                          ),
                        );
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Center(
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    elevation: 3,
                    shadowColor: Colors.black.withOpacity(0.06),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            currentQuestion.displayExpression,
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 40,
                              letterSpacing: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2.1,
                physics: const NeverScrollableScrollPhysics(),
                children: currentQuestion.answerOptions.map((option) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfacePrimary,
                      foregroundColor: AppColors.textPrimary,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: _isSubmitting ? null : () => _submitAnswer(option),
                    child: Text(
                      option,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = (seconds / 60).floor();
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
