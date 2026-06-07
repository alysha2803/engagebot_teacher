// Basic smoke test for EngageBot Teacher App.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:engagebot_teacher/main.dart';

void main() {
  testWidgets('EngageBot app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: EngageBotApp()),
    );
    // The app renders without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
