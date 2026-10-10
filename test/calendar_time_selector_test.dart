import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calcup/features/practice/widgets/calendar_time_selector.dart';

void main() {
  group('CalendarTimeSelector Widget Tests', () {
    testWidgets('renders time options and default selection correctly', (tester) async {
      int selectedTime = 60;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarTimeSelector(
              selectedSeconds: selectedTime,
              onTimeChanged: (newVal) {
                selectedTime = newVal;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify that key duration options are present including starting 3s option
      expect(find.text('3'), findsOneWidget);
      expect(find.text('60'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);

      // Verify active badge label for 60s
      expect(find.text('60 Seconds • 1 Minute'), findsOneWidget);
    });

    testWidgets('selecting 3s option updates selection and label properly', (tester) async {
      int selectedTime = 60;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: CalendarTimeSelector(
                  selectedSeconds: selectedTime,
                  onTimeChanged: (newVal) {
                    setState(() {
                      selectedTime = newVal;
                    });
                  },
                ),
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      final threeItem = find.text('3');
      expect(threeItem, findsOneWidget);
      await tester.tap(threeItem);
      await tester.pumpAndSettle();

      expect(selectedTime, equals(3));
      expect(find.text('3 Seconds • Instant Flash'), findsOneWidget);
    });

    testWidgets('tapping an unselected time option triggers onTimeChanged and updates UI', (tester) async {
      int selectedTime = 60;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: CalendarTimeSelector(
                  selectedSeconds: selectedTime,
                  onTimeChanged: (newVal) {
                    setState(() {
                      selectedTime = newVal;
                    });
                  },
                ),
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      // Tap on '30'
      final targetItem = find.text('30');
      expect(targetItem, findsOneWidget);
      await tester.tap(targetItem);
      await tester.pumpAndSettle();

      // Verify callback triggered
      expect(selectedTime, equals(30));
      expect(find.text('30 Seconds • Rapid'), findsOneWidget);
    });

    testWidgets('supports horizontal scrolling across options smoothly', (tester) async {
      int selectedTime = 30;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarTimeSelector(
              selectedSeconds: selectedTime,
              onTimeChanged: (newVal) {
                selectedTime = newVal;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Drag to scroll horizontally
      await tester.drag(find.byType(ListView), const Offset(-300, 0));
      await tester.pumpAndSettle();

      // Verify that further options like 300s are reached
      expect(find.text('300'), findsOneWidget);
    });
  });
}
