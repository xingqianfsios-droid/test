import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:junqi/main.dart';
import 'package:junqi/controllers/game_controller.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('象棋 Pro'), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
    expect(find.byIcon(Icons.help_outline), findsOneWidget);

    // 清理 GetX controller 中的 Timer
    final controller = Get.find<GameController>();
    controller.onClose();
    Get.reset();
  });
}
