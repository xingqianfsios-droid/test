import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';

class GameView extends GetView<GameController> {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xiangqi Pro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.resetBoard,
          ),
        ],
      ),
      body: Center(
        child: Obx(() => Text(
              '棋子数: ${controller.pieces.length} | '
              '当前回合: ${controller.currentTurn.value.name}',
              style: const TextStyle(fontSize: 18),
            )),
      ),
    );
  }
}
