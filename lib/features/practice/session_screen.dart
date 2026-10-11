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

  Timer? _timer;
  final Stopwatch _stopwatch = Stopwatch();
  int _remainingSeconds = 0;
  bool _isSubmitting = false;
  bool _isFinished = false;

  final List<QuestionAttempt> _attempts = [];
  DateTime _questionStartTime = DateTime.now();

  @override
  void initState() {
    super.initState();
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
    _questionStartTime = DateTime.now();
    _isFinished = false;
    _isSubmitting = false;

    _stopwatch.reset();
    _stopwatch.start();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
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
        _timer = null;
        if (mounted) {
          setState(() {
            _remainingSeconds = 0;
          });
        }
        _finalizeSession(terminatedByLives: false);
      } else if (remaining != _remainingSeconds) {
        if (mounted) {
          setState(() {
            _remainingSeconds = remaining;
          });
        }
      }
    });
  }

  void _finalizeSession({bool terminatedByLives = false}) {
    if (_isFinished) return;
    _isFinished = true;
    _isSubmitting = true;
    _stopwatch.stop();
    _timer?.cancel();
    _timer = null;

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
      'terminated': terminatedByLives,
      'reason': terminatedByLives ? 'Out of Lives' : 'Time Expired',
    };

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go('/results', extra: result);
        }
      });
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

    final prefs = ref.read(userPreferencesNotifierProvider).value;
    final maxLives = prefs?.wrongAnswerThreshold ?? 3;

    // Terminate immediately if all lives are exhausted within time
    if (_wrongCount >= maxLives) {
      await Future.delayed(const Duration(milliseconds: 220));
      if (mounted) {
        _finalizeSession(terminatedByLives: true);
      }
      return;
    }

    await Future.delayed(const Duration(milliseconds: 220));

    if (!mounted || _isFinished || _remainingSeconds <= 0) return;

    setState(() {
      _currentIndex++;
      if (_currentIndex >= _questions.length) {
        _questions.addAll(QuestionGenerator.generateQuestions(widget.config));
      }
      _questionStartTime = DateTime.now();
      _isSubmitting = false;
    });
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
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final currentQuestion = _questions[_currentIndex];
    final prefs = ref.watch(userPreferencesNotifierProvider).value;
    final maxLives = prefs?.wrongAnswerThreshold ?? 3;
    final livesRemaining = (maxLives - _wrongCount).clamp(0, maxLives);

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: Text(widget.config.category, style: Theme.of(context).textTheme.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: _confirmExit,
          tooltip: 'End Session',
        ),
        actions: [
          // Remaining Lives Indicator
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: livesRemaining <= 1
                    ? AppColors.errorRed.withOpacity(0.12)
                    : AppColors.surfacePrimary,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: livesRemaining <= 1
                      ? AppColors.errorRed.withOpacity(0.5)
                      : Colors.black.withOpacity(0.06),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < maxLives; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.5),
                      child: Icon(
                        i < livesRemaining ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 16,
                        color: i < livesRemaining ? AppColors.errorRed : Colors.grey.shade400,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Countdown Timer Indicator
          Padding(
            padding: const EdgeInsets.only(right: 14.0),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                      size: 16,
                      color: _remainingSeconds <= 5 ? AppColors.errorRed : AppColors.primaryOrange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(_remainingSeconds),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: _remainingSeconds <= 5 ? AppColors.errorRed : AppColors.primaryOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
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
            final questionFontSize = isCompact ? 32.0 : 40.0;
            final answerFontSize = isCompact ? 18.0 : 22.0;
            final answerAspect = isCompact ? 2.6 : 2.1;
            final answerSpacing = isCompact ? 10.0 : 16.0;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: isCompact ? 8.0 : 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with counter and live correct/wrong indicators
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
                  SizedBox(height: isCompact ? 8 : 12),
                  Expanded(
                    child: Center(
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        elevation: 3,
                        shadowColor: Colors.black.withOpacity(0.06),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: isCompact ? 16.0 : 24.0,
                            horizontal: 16.0,
                          ),
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                currentQuestion.displayExpression,
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                      fontSize: questionFontSize,
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
                  SizedBox(height: isCompact ? 8 : 16),
                  GridView.count(
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
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: (_isSubmitting || _isFinished) ? null : () => _submitAnswer(option),
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
                  SizedBox(height: isCompact ? 8 : 24),
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
