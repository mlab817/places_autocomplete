import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:example_app/main.dart';

void main() {
  testWidgets('shows the API key prompt when no key is configured', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ExampleApp());

    expect(find.byType(ApiKeyPromptPage), findsOneWidget);
    expect(find.widgetWithText(TextField, 'API key'), findsOneWidget);
  });
}
