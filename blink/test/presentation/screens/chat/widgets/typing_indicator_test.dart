import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blink/presentation/screens/chat/widgets/typing_indicator.dart';

void main() {
  testWidgets('TypingIndicator renders 3 dots', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: TypingIndicator()),
    ));
    expect(find.byKey(const ValueKey('typing-dot-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('typing-dot-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('typing-dot-2')), findsOneWidget);
  });
}
