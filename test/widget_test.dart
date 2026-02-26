import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:junqi/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('象棋 Pro'), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });
}
