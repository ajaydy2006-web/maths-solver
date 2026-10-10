import 'package:flutter_test/flutter_test.dart';
import 'package:calcup/data/models.dart';
import 'package:calcup/services/question_generator.dart';

void main() {
  group('QuestionGenerator Tests', () {
    test('Basic Arithmetic generates valid expressions and 4 unique options', () {
      final config = PracticeConfiguration(category: 'Basic Arithmetic', questionCount: 15);
      final questions = QuestionGenerator.generateQuestions(config);

      expect(questions.length, 15);
      for (final q in questions) {
        expect(q.category, 'Basic Arithmetic');
        expect(q.answerOptions.length, 4);
        expect(q.answerOptions.toSet().length, 4, reason: 'Options must be unique');
        expect(q.answerOptions.contains(q.correctAnswer), isTrue, reason: 'Options must include the correct answer');
        expect(q.explanation, isNotNull);
        expect(q.explanation!.isNotEmpty, isTrue);
      }
    });

    test('BODMAS Challenge generates expressions with valid answers', () {
      final config = PracticeConfiguration(category: 'BODMAS Challenge', questionCount: 15);
      final questions = QuestionGenerator.generateQuestions(config);

      expect(questions.length, 15);
      for (final q in questions) {
        expect(q.category, 'BODMAS Challenge');
        expect(q.answerOptions.length, 4);
        expect(q.answerOptions.contains(q.correctAnswer), isTrue);
        expect(int.tryParse(q.correctAnswer), isNotNull);
      }
    });

    test('Number Series produces mathematically coherent sequences', () {
      final config = PracticeConfiguration(category: 'Number Series', questionCount: 10);
      final questions = QuestionGenerator.generateQuestions(config);

      expect(questions.length, 10);
      for (final q in questions) {
        expect(q.displayExpression.contains('?'), isTrue);
        expect(q.answerOptions.contains(q.correctAnswer), isTrue);
        expect(int.tryParse(q.correctAnswer), isNotNull);
      }
    });

    test('Inequalities produces >, <, or = with correct logic', () {
      final config = PracticeConfiguration(category: 'Inequalities', questionCount: 10);
      final questions = QuestionGenerator.generateQuestions(config);

      expect(questions.length, 10);
      for (final q in questions) {
        expect(['>', '<', '='].contains(q.correctAnswer), isTrue);
        expect(q.answerOptions.contains(q.correctAnswer), isTrue);
      }
    });

    test('Mental Calculation produces valid mentalSteps and math consistency', () {
      final config = PracticeConfiguration(category: 'Mental Calculation', questionCount: 10);
      final questions = QuestionGenerator.generateQuestions(config);

      expect(questions.length, 10);
      for (final q in questions) {
        expect(q.mentalSteps, isNotNull);
        expect(q.mentalSteps!.length, greaterThanOrEqualTo(3));
        
        // Re-evaluate steps to verify deterministic correctness
        int total = int.parse(q.mentalSteps![0]);
        for (int i = 1; i < q.mentalSteps!.length; i++) {
          final step = q.mentalSteps![i];
          final parts = step.split(' ');
          final op = parts[0];
          final val = int.parse(parts[1]);
          if (op == '+') {
            total += val;
          } else if (op == '-') {
            total -= val;
          }
        }
        expect(total.toString(), q.correctAnswer, reason: 'Mental calculation sequence must evaluate to correctAnswer');
      }
    });

    test('Missing Number generates valid equations', () {
      final config = PracticeConfiguration(category: 'Missing Number', questionCount: 10);
      final questions = QuestionGenerator.generateQuestions(config);

      expect(questions.length, 10);
      for (final q in questions) {
        expect(q.displayExpression.contains('?'), isTrue);
        expect(q.answerOptions.contains(q.correctAnswer), isTrue);
      }
    });
  });
}
