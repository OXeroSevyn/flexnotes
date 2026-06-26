import 'dart:io';

import 'package:flex_notes/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Flex Notes loads the offline workspace', (tester) async {
    final directory = Directory.systemTemp.createTempSync('flex_notes_test_');
    const channel = MethodChannel('com.flexnotes.app/storage');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'filesDir') {
            return directory.path;
          }
          return null;
        });

    await tester.pumpWidget(const FlexNotesApp());
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump();

    expect(
      find.textContaining(RegExp('notes', caseSensitive: false)),
      findsWidgets,
    );
    expect(find.byIcon(Icons.wifi_off_rounded), findsNothing);

    directory.deleteSync(recursive: true);
  });
}
