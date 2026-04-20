import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blink/presentation/screens/chat/widgets/message_input.dart';

void main() {
  group('MessageInput', () {
    testWidgets('send button disabled when text is empty and no image',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MessageInput(
            onSendText: (_) {},
            onSendImage: (_) {},
            onTypingChanged: (_) {},
          ),
        ),
      ));
      final btn = tester.widget<IconButton>(
        find.byKey(const ValueKey('send-button')),
      );
      expect(btn.onPressed, isNull);
    });

    testWidgets('typing in field enables send and triggers onTypingChanged',
        (tester) async {
      var typingState = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MessageInput(
            onSendText: (_) {},
            onSendImage: (_) {},
            onTypingChanged: (v) => typingState = v,
          ),
        ),
      ));
      await tester.enterText(
          find.byKey(const ValueKey('message-input-field')), 'hello');
      await tester.pump();
      expect(typingState, isTrue);
      final btn = tester.widget<IconButton>(
        find.byKey(const ValueKey('send-button')),
      );
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('sending text clears the field', (tester) async {
      String? sent;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MessageInput(
            onSendText: (t) => sent = t,
            onSendImage: (_) {},
            onTypingChanged: (_) {},
          ),
        ),
      ));
      await tester.enterText(
          find.byKey(const ValueKey('message-input-field')), 'salom');
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('send-button')));
      await tester.pump();
      expect(sent, 'salom');
      expect(find.text('salom'), findsNothing);
    });
  });
}
