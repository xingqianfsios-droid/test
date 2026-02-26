import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:junqi/main.dart';
import 'package:junqi/controllers/game_controller.dart';

void main() {
  testWidgets('Home page renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // 主页显示标题和按钮
    expect(find.text('象棋'), findsOneWidget);
    expect(find.text('Xiangqi Pro'), findsOneWidget);
    expect(find.text('开始游戏'), findsOneWidget);
    expect(find.text('游戏规则'), findsOneWidget);

    Get.reset();
  });

  testWidgets('Navigate to game page', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // 点击开始游戏
    await tester.tap(find.text('开始游戏'));
    await tester.pumpAndSettle();

    // 游戏页面元素
    expect(find.text('象棋 Pro'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
    expect(find.byIcon(Icons.help_outline), findsOneWidget);
    expect(find.byIcon(Icons.pause), findsOneWidget);

    // 清理 GetX controller 中的 Timer
    final controller = Get.find<GameController>();
    controller.onClose();
    Get.reset();
  });
}
