import 'package:flutter_test/flutter_test.dart';
import 'package:calcup/data/models.dart';

void main() {
  group('Models Serialization and Logic Tests', () {
    test('UserPreferences serialization toMap and fromMap roundtrip', () {
      final prefs = UserPreferences(
        displayName: 'Aarav',
        examGoals: ['SSC', 'Banking'],
        currentLevel: 'Intermediate',
        dailyGoalMinutes: 15,
        hasCompletedOnboarding: true,
        wrongAnswerThreshold: 4,
        threeWrongRestartEnabled: true,
        soundEnabled: false,
        hapticsEnabled: true,
      );

      final map = prefs.toMap();
      final restored = UserPreferences.fromMap(map);

      expect(restored.displayName, 'Aarav');
      expect(restored.examGoals, ['SSC', 'Banking']);
      expect(restored.currentLevel, 'Intermediate');
      expect(restored.dailyGoalMinutes, 15);
      expect(restored.hasCompletedOnboarding, isTrue);
      expect(restored.wrongAnswerThreshold, 4);
      expect(restored.threeWrongRestartEnabled, isTrue);
      expect(restored.soundEnabled, isFalse);
      expect(restored.hapticsEnabled, isTrue);
    });

    test('UserPreferences copyWith updates values selectively', () {
      final initial = UserPreferences(displayName: 'TestUser', dailyGoalMinutes: 10);
      final updated = initial.copyWith(displayName: 'SuperUser', dailyGoalMinutes: 20);

      expect(updated.displayName, 'SuperUser');
      expect(updated.dailyGoalMinutes, 20);
      expect(updated.currentLevel, initial.currentLevel);
      expect(updated.wrongAnswerThreshold, initial.wrongAnswerThreshold);
    });

    test('SessionRecord calculates accuracy correctly', () {
      final session = SessionRecord(
        category: 'Basic Arithmetic',
        date: '2026-10-10',
        score: 180,
        correctAnswers: 18,
        incorrectAnswers: 2,
        totalQuestions: 20,
        durationSeconds: 50,
      );

      expect(session.accuracy, 90.0);
      final map = session.toMap();
      final restored = SessionRecord.fromMap(map);
      expect(restored.category, 'Basic Arithmetic');
      expect(restored.score, 180);
      expect(restored.accuracy, 90.0);
    });
  });
}
