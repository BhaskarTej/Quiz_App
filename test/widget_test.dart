import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/main.dart';

void main() {
  testWidgets('QuizApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(QuizApp());

    // Verify that the setup screen is displayed.
    expect(find.text('Customize Your Quiz'), findsOneWidget);

    // Interact with the slider and verify it updates.
    final slider = find.byType(Slider);
    await tester.drag(slider, const Offset(50.0, 0.0)); // Simulates user dragging slider.
    await tester.pump();

    // Check for the presence of Start Quiz button.
    expect(find.text('Start Quiz'), findsOneWidget);
  });
}