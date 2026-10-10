import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../services/question_generator.dart';

class MentalSessionScreen extends ConsumerStatefulWidget {
  final PracticeConfiguration config;
  const MentalSessionScreen({Key? key, required this.config}) : super(key: key);

  @override
  ConsumerState<MentalSessionScreen> createState() => _MentalSessionScreenState();
}

class _MentalSessionScreenState extends ConsumerState<MentalSessionScreen> {
  late List<GeneratedQuestion> _questions;
  int _currentIndex = 0;

  int _correctCount = 0;
  int _wrongCount = 0;
  int _consecutiveWrongCount = 0;

  Timer? _sessionTimer;
  int _remainingSeconds = 0;
  bool _isSubmitting = false;

  late int _wrongThreshold;
  late bool _threeWrongRestartEnabled;

  // Mental calculation flashing sequence state
  int _currentStepIndex = 0;
  Timer? _stepTimer;
  bool _sequenceCompleted = false;
  double _stepDurationSeconds = 1.4; // Configurable flash speed

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
    _consecutiveWrongCount = 0;
    _attempts.clear();
    _remainingSeconds = widget.config.timerSeconds;

    _sessionTimer?.cancel();
    if (_remainingSeconds > 0) {
      _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _finalizeSession();
          }
        });
      });
    }

    _playCurrentQuestionSequence();
  }

  void _playCurrentQuestionSequence() {
    _stepTimer?.cancel();
    _currentStepIndex = 0;
    _sequenceCompleted = false;
    _questionStartTime = DateTime.now();

    final steps = _questions[_currentIndex].mentalSteps ?? [_questions[_currentIndex].displayExpression];

    _stepTimer = Timer.periodic(
      Duration(milliseconds: (_stepDurationSeconds * 1000).round()),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          if (_currentStepIndex < steps.length - 1) {
            _currentStepIndex++;
          } else {
            _sequenceCompleted = true;
            timer.cancel();
          }
        });
      },
    );
  }

  void _replaySequence() {
    if (_isSubmitting) return;
    setState(() {
      _playCurrentQuestionSequence();
    });
  }

  void _handleRestart() {
    _sessionTimer?.cancel();
    _stepTimer?.cancel();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "$_wrongThreshold mistakes! Let's try again. Every retry strengthens your mental stamina.",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.errorRed,
        duration: const Duration(seconds: 2),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _startSession();
        });
      }
    });
  }

  void _finalizeSession() {
    _sessionTimer?.cancel();
    _stepTimer?.cancel();

    final result = {
      'category': widget.config.category,
      'score': _correctCount * 10,
      'correctAnswers': _correctCount,
      'incorrectAnswers': _wrongCount,
      'totalQuestions': _questions.length,
      'durationSeconds': widget.config.timerSeconds - _remainingSeconds,
      'attempts': _attempts,
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
      _consecutiveWrongCount = 0;
    } else {
      _wrongCount++;
      _consecutiveWrongCount++;
    }

    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    if (_threeWrongRestartEnabled && _consecutiveWrongCount >= _wrongThreshold) {
      _isSubmitting = false;
      _handleRestart();
      return;
    }

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _isSubmitting = false;
      });
      _playCurrentQuestionSequence();
    } else {
      _isSubmitting = false;
      _finalizeSession();
    }
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _stepTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentQuestion = _questions[_currentIndex];
    final steps = currentQuestion.mentalSteps ?? [currentQuestion.displayExpression];
    final currentDisplayStep = _sequenceCompleted ? "= ?" : steps[_currentStepIndex];

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: Text("Mental Calculation", style: Theme.of(context).textTheme.titleLarge),
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
              // Progress Bar & Question Counter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Question ${_currentIndex + 1} of ${_questions.length}",
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
                            color: idx < (_wrongThreshold - _consecutiveWrongCount)
                                ? AppColors.errorRed
                                : Colors.grey.shade400,
                          ),
                        );
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (_currentIndex) / _questions.length,
                backgroundColor: AppColors.surfacePrimary,
                color: AppColors.pastelPurple,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 16),

              // Speed & Replay Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text("Flash Speed: ", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      Wrap(
                        spacing: 4,
                        children: [1.0, 1.4, 1.8].map((speed) {
                          final isSelected = _stepDurationSeconds == speed;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _stepDurationSeconds = speed;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.pastelPurple : AppColors.surfacePrimary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${speed}s',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  if (_sequenceCompleted)
                    TextButton.icon(
                      onPressed: _replaySequence,
                      icon: const Icon(Icons.replay, size: 16, color: AppColors.primaryOrange),
                      label: const Text("Replay", style: TextStyle(fontSize: 13, color: AppColors.primaryOrange)),
                    ),
                ],
              ),

              const Spacer(),

              // Sequential Display Card
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: Container(
                    key: ValueKey<String>('step_${_currentStepIndex}_$_sequenceCompleted'),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.pastelPurple.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_sequenceCompleted)
                          Text(
                            "Step ${_currentStepIndex + 1} of ${steps.length}",
                            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                          ),
                        const SizedBox(height: 12),
                        Text(
                          currentDisplayStep,
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                fontSize: 52,
                                color: _sequenceCompleted ? AppColors.primaryOrange : AppColors.textPrimary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        if (_sequenceCompleted) ...[
                          const SizedBox(height: 8),
                          const Text(
                            "What is the final answer?",
                            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Answer Options (Shown after sequence completes, or dimmed while flashing)
              AnimatedOpacity(
                opacity: _sequenceCompleted ? 1.0 : 0.35,
                duration: const Duration(milliseconds: 300),
                child: GridView.count(
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
                        elevation: _sequenceCompleted ? 3 : 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: (!_sequenceCompleted || _isSubmitting)
                          ? null
                          : () => _submitAnswer(option),
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
              ),
              const SizedBox(height: 16),
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
