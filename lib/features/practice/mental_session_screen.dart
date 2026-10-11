import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
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

  Timer? _sessionTimer;
  final Stopwatch _stopwatch = Stopwatch();
  int _remainingSeconds = 0;
  bool _isSubmitting = false;
  bool _isFinished = false;

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
    _stepDurationSeconds = widget.config.stepDurationSeconds > 0 ? widget.config.stepDurationSeconds : 1.4;
    _startSession();
  }

  void _startSession() {
    _questions = QuestionGenerator.generateQuestions(widget.config);
    _currentIndex = 0;
    _correctCount = 0;
    _wrongCount = 0;
    _attempts.clear();
    final targetDuration = widget.config.timerSeconds > 0 ? widget.config.timerSeconds : 60;
    _remainingSeconds = targetDuration;
    _isFinished = false;
    _isSubmitting = false;

    _stopwatch.reset();
    _stopwatch.start();

    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_isFinished) {
        timer.cancel();
        return;
      }
      final elapsedMs = _stopwatch.elapsedMilliseconds;
      final elapsedSecs = elapsedMs ~/ 1000;
      final remaining = targetDuration - elapsedSecs;

      if (remaining <= 0) {
        _stopwatch.stop();
        timer.cancel();
        _sessionTimer = null;
        if (mounted) {
          setState(() {
            _remainingSeconds = 0;
          });
        }
        _finalizeSession();
      } else if (remaining != _remainingSeconds) {
        if (mounted) {
          setState(() {
            _remainingSeconds = remaining;
          });
        }
      }
    });

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
    if (_isSubmitting || _isFinished || _remainingSeconds <= 0) return;
    setState(() {
      _playCurrentQuestionSequence();
    });
  }

  void _finalizeSession() {
    if (_isFinished) return;
    _isFinished = true;
    _isSubmitting = true;
    _stopwatch.stop();
    _sessionTimer?.cancel();
    _sessionTimer = null;
    _stepTimer?.cancel();
    _stepTimer = null;

    final targetDuration = widget.config.timerSeconds > 0 ? widget.config.timerSeconds : 60;
    final elapsedSecs = _stopwatch.elapsedMilliseconds ~/ 1000;
    final durationSeconds = elapsedSecs > 0 ? (elapsedSecs > targetDuration ? targetDuration : elapsedSecs) : targetDuration;

    final result = {
      'category': widget.config.category,
      'score': _correctCount * 10,
      'correctAnswers': _correctCount,
      'incorrectAnswers': _wrongCount,
      'totalQuestions': _attempts.length,
      'durationSeconds': durationSeconds,
      'attempts': _attempts,
      'terminated': false,
    };

    if (mounted) {
      context.pushReplacement('/results', extra: result);
    }
  }

  void _submitAnswer(String selectedOption) async {
    if (_isSubmitting || _isFinished || _remainingSeconds <= 0) return;
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

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted || _isFinished) return;

    // Session does not terminate on mistakes; runs until timer expires
    setState(() {
      _currentIndex++;
      if (_currentIndex >= _questions.length) {
        _questions.addAll(QuestionGenerator.generateQuestions(widget.config));
      }
      _isSubmitting = false;
    });
    _playCurrentQuestionSequence();
  }

  void _confirmExit() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("End Session?"),
        content: const Text("Would you like to finish this session now and see your results?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Continue"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _finalizeSession();
            },
            child: const Text("View Results"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _stopwatch.stop();
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
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: _confirmExit,
          tooltip: 'End Session',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _remainingSeconds <= 5
                      ? AppColors.errorRed.withOpacity(0.12)
                      : AppColors.surfacePrimary,
                  borderRadius: BorderRadius.circular(16),
                  border: _remainingSeconds <= 5
                      ? Border.all(color: AppColors.errorRed.withOpacity(0.5))
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 18,
                      color: _remainingSeconds <= 5 ? AppColors.errorRed : AppColors.primaryOrange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(_remainingSeconds),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: _remainingSeconds <= 5 ? AppColors.errorRed : AppColors.primaryOrange,
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxHeight < 600;
            final hPadding = constraints.maxWidth < 360 ? 14.0 : 24.0;
            final answerFontSize = isCompact ? 18.0 : 22.0;
            final answerAspect = isCompact ? 2.6 : 2.1;
            final answerSpacing = isCompact ? 10.0 : 16.0;
            final mainFontSize = isCompact ? 36.0 : 44.0;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: isCompact ? 4.0 : 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Question Counter & Correct/Wrong Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.surfacePrimary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Question ${_currentIndex + 1}",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.pastelGreen.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle, size: 14, color: AppColors.successGreen),
                                const SizedBox(width: 4),
                                Text(
                                  "$_correctCount",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.successGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.pastelPink.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.cancel, size: 14, color: AppColors.errorRed),
                                const SizedBox(width: 4),
                                Text(
                                  "$_wrongCount",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.errorRed,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: isCompact ? 6 : 12),

                  // Speed & Replay Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
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
                      ),
                      if (_sequenceCompleted)
                        TextButton.icon(
                          onPressed: _replaySequence,
                          icon: const Icon(Icons.replay, size: 16, color: AppColors.primaryOrange),
                          label: const Text("Replay", style: TextStyle(fontSize: 13, color: AppColors.primaryOrange)),
                        ),
                    ],
                  ),

                  SizedBox(height: isCompact ? 4 : 8),

                  // Sequential Display Card
                  Expanded(
                    child: Center(
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
                          padding: EdgeInsets.symmetric(
                            vertical: isCompact ? 16.0 : 24.0,
                            horizontal: 20.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.pastelPurple.withOpacity(0.2),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!_sequenceCompleted)
                                Text(
                                  "Step ${_currentStepIndex + 1} of ${steps.length}",
                                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                ),
                              const SizedBox(height: 8),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  currentDisplayStep,
                                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                        fontSize: mainFontSize,
                                        color: _sequenceCompleted ? AppColors.primaryOrange : AppColors.textPrimary,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              if (_sequenceCompleted) ...[
                                const SizedBox(height: 6),
                                const Text(
                                  "What is the final answer?",
                                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: isCompact ? 8 : 14),

                  // Answer Options
                  AnimatedOpacity(
                    opacity: _sequenceCompleted ? 1.0 : 0.35,
                    duration: const Duration(milliseconds: 300),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      mainAxisSpacing: answerSpacing,
                      crossAxisSpacing: answerSpacing,
                      childAspectRatio: answerAspect,
                      physics: const NeverScrollableScrollPhysics(),
                      children: currentQuestion.answerOptions.map((option) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.surfacePrimary,
                            foregroundColor: AppColors.textPrimary,
                            elevation: _sequenceCompleted ? 3 : 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          onPressed: (!_sequenceCompleted || _isSubmitting || _isFinished)
                              ? null
                              : () => _submitAnswer(option),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              option,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontSize: answerFontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: isCompact ? 8 : 16),
                ],
              ),
            );
          },
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
