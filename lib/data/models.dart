import 'dart:convert';

class UserPreferences {
  final String displayName;
  final List<String> examGoals;
  final String currentLevel;
  final int dailyGoalMinutes;
  final bool hasCompletedOnboarding;
  final int wrongAnswerThreshold;
  final bool threeWrongRestartEnabled;
  final bool soundEnabled;
  final bool hapticsEnabled;

  UserPreferences({
    this.displayName = 'Calculator',
    this.examGoals = const [],
    this.currentLevel = 'Beginner',
    this.dailyGoalMinutes = 10,
    this.hasCompletedOnboarding = false,
    this.wrongAnswerThreshold = 3,
    this.threeWrongRestartEnabled = true,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
  });

  UserPreferences copyWith({
    String? displayName,
    List<String>? examGoals,
    String? currentLevel,
    int? dailyGoalMinutes,
    bool? hasCompletedOnboarding,
    int? wrongAnswerThreshold,
    bool? threeWrongRestartEnabled,
    bool? soundEnabled,
    bool? hapticsEnabled,
  }) {
    return UserPreferences(
      displayName: displayName ?? this.displayName,
      examGoals: examGoals ?? this.examGoals,
      currentLevel: currentLevel ?? this.currentLevel,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      wrongAnswerThreshold: wrongAnswerThreshold ?? this.wrongAnswerThreshold,
      threeWrongRestartEnabled: threeWrongRestartEnabled ?? this.threeWrongRestartEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'examGoals': jsonEncode(examGoals),
      'currentLevel': currentLevel,
      'dailyGoalMinutes': dailyGoalMinutes,
      'hasCompletedOnboarding': hasCompletedOnboarding ? 1 : 0,
      'wrongAnswerThreshold': wrongAnswerThreshold,
      'threeWrongRestartEnabled': threeWrongRestartEnabled ? 1 : 0,
      'soundEnabled': soundEnabled ? 1 : 0,
      'hapticsEnabled': hapticsEnabled ? 1 : 0,
    };
  }

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      displayName: map['displayName'] ?? 'Calculator',
      examGoals: map['examGoals'] != null
          ? List<String>.from(jsonDecode(map['examGoals']))
          : [],
      currentLevel: map['currentLevel'] ?? 'Beginner',
      dailyGoalMinutes: map['dailyGoalMinutes'] ?? 10,
      hasCompletedOnboarding: map['hasCompletedOnboarding'] == 1,
      wrongAnswerThreshold: map['wrongAnswerThreshold'] ?? 3,
      threeWrongRestartEnabled: map['threeWrongRestartEnabled'] == 1,
      soundEnabled: map['soundEnabled'] == 1,
      hapticsEnabled: map['hapticsEnabled'] == 1,
    );
  }
}

class PracticeConfiguration {
  final String category;
  final String difficulty;
  final int timerSeconds;
  final int questionCount;
  final int answerOptions;
  final bool instantFeedback;
  final bool hintsEnabled;
  final String? operation;
  final int digits;
  final int operandsCount;
  final String? subType;
  final List<String>? enabledOperations;
  final List<String>? enabledCategories;
  final double stepDurationSeconds;

  PracticeConfiguration({
    required this.category,
    this.difficulty = 'Medium',
    this.timerSeconds = 60,
    this.questionCount = 20,
    this.answerOptions = 4,
    this.instantFeedback = true,
    this.hintsEnabled = false,
    this.operation,
    this.digits = 2,
    this.operandsCount = 2,
    this.subType,
    this.enabledOperations,
    this.enabledCategories,
    this.stepDurationSeconds = 1.4,
  });
}

class GeneratedQuestion {
  final String id;
  final String category;
  final String questionType;
  final String displayExpression;
  final String correctAnswer;
  final List<String> answerOptions;
  final String difficulty;
  final String? explanation;
  final List<String>? mentalSteps;

  GeneratedQuestion({
    required this.id,
    required this.category,
    required this.questionType,
    required this.displayExpression,
    required this.correctAnswer,
    required this.answerOptions,
    required this.difficulty,
    this.explanation,
    this.mentalSteps,
  });
}

class QuestionAttempt {
  final GeneratedQuestion question;
  final String selectedAnswer;
  final bool isCorrect;
  final int durationSeconds;

  QuestionAttempt({
    required this.question,
    required this.selectedAnswer,
    required this.isCorrect,
    this.durationSeconds = 0,
  });
}

class SessionRecord {
  final int? id;
  final String category;
  final String date;
  final int score;
  final int correctAnswers;
  final int incorrectAnswers;
  final int totalQuestions;
  final int durationSeconds;

  SessionRecord({
    this.id,
    required this.category,
    required this.date,
    required this.score,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.totalQuestions,
    required this.durationSeconds,
  });

  double get accuracy =>
      totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0.0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'date': date,
      'score': score,
      'correctAnswers': correctAnswers,
      'incorrectAnswers': incorrectAnswers,
      'totalQuestions': totalQuestions,
      'durationSeconds': durationSeconds,
    };
  }

  factory SessionRecord.fromMap(Map<String, dynamic> map) {
    return SessionRecord(
      id: map['id'] as int?,
      category: map['category'] as String? ?? 'Practice',
      date: map['date'] as String? ?? '',
      score: map['score'] as int? ?? 0,
      correctAnswers: map['correctAnswers'] as int? ?? 0,
      incorrectAnswers: map['incorrectAnswers'] as int? ?? 0,
      totalQuestions: map['totalQuestions'] as int? ?? 0,
      durationSeconds: map['durationSeconds'] as int? ?? 0,
    );
  }
}
