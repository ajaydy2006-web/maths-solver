import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calcup/core/constants.dart';
import 'package:calcup/data/models.dart';
import 'package:calcup/services/question_generator.dart';
import 'package:calcup/features/practice/widgets/time_slider.dart';

void main() {
  group('Category and Navigation Flow Tests', () {
    test('All 10 required practice categories exist in AppConstants', () {
      const expectedCategories = [
        'Arithmetic',
        'Random Calculations',
        'BODMAS Challenge',
        'Number Series',
        'Inequalities',
        'Mental Maths',
        'Missing Number',
        'Number Puzzles',
        'Mixed Practice',
        'Custom Practice',
      ];

      expect(AppConstants.categories, equals(expectedCategories));
      for (final cat in expectedCategories) {
        expect(AppConstants.categoryDetails.containsKey(cat), isTrue);
        final meta = AppConstants.categoryDetails[cat]!;
        expect(meta.title, equals(cat));
        expect(meta.description.isNotEmpty, isTrue);
      }
    });

    test('Arithmetic question generation respects operation and digits', () {
      final multConfig = PracticeConfiguration(
        category: 'Arithmetic',
        operation: 'Multiplication',
        digits: 2,
        operandsCount: 2,
        timerSeconds: 45,
      );

      final questions = QuestionGenerator.generateQuestions(multConfig);
      expect(questions.length, equals(multConfig.questionCount));

      for (final q in questions) {
        expect(q.category, equals('Arithmetic'));
        expect(q.displayExpression.contains('×'), isTrue);
        expect(q.answerOptions.length, equals(4));
        expect(q.answerOptions.contains(q.correctAnswer), isTrue);
      }

      final addConfig = PracticeConfiguration(
        category: 'Arithmetic',
        operation: 'Addition',
        digits: 1,
        operandsCount: 2,
      );
      final addQuestions = QuestionGenerator.generateQuestions(addConfig);
      for (final q in addQuestions) {
        expect(q.displayExpression.contains('+'), isTrue);
      }
    });

    test('3-operand arithmetic generation produces valid expressions', () {
      final config = PracticeConfiguration(
        category: 'Arithmetic',
        operation: 'Addition',
        digits: 2,
        operandsCount: 3,
      );

      final questions = QuestionGenerator.generateQuestions(config);
      for (final q in questions) {
        // e.g. a + b + c = ?
        final plusCount = '+'.allMatches(q.displayExpression).length;
        expect(plusCount, greaterThanOrEqualTo(2));
      }
    });

    test('Mental Maths question generation produces sequential steps', () {
      final config = PracticeConfiguration(
        category: 'Mental Maths',
        operandsCount: 5,
        subType: 'Add & Subtract (+/-)',
        stepDurationSeconds: 1.4,
      );

      final questions = QuestionGenerator.generateQuestions(config);
      for (final q in questions) {
        expect(q.mentalSteps, isNotNull);
        expect(q.mentalSteps!.length, equals(5));
      }
    });
  });

  group('CalcupTimeSlider Widget Tests', () {
    testWidgets('renders MM:SS format and handles quick select presets', (tester) async {
      int selectedTime = 60;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return CalcupTimeSlider(
                  selectedSeconds: selectedTime,
                  onTimeChanged: (newSecs) {
                    setState(() {
                      selectedTime = newSecs;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify MM:SS badge display for 60 seconds
      expect(find.text('01:00'), findsOneWidget);
      expect(find.text('Practice Duration'), findsOneWidget);

      // Verify quick presets are visible
      expect(find.text('30s'), findsOneWidget);
      expect(find.text('1m'), findsOneWidget);
      expect(find.text('2m'), findsOneWidget);
      expect(find.text('5m'), findsOneWidget);
      expect(find.text('10m'), findsOneWidget);

      // Tap 2m preset (120s)
      await tester.tap(find.text('2m'));
      await tester.pumpAndSettle();

      expect(selectedTime, equals(120));
      expect(find.text('02:00'), findsOneWidget);

      // Tap 30s preset
      await tester.tap(find.text('30s'));
      await tester.pumpAndSettle();

      expect(selectedTime, equals(30));
      expect(find.text('00:30'), findsOneWidget);
    });
  });
}
