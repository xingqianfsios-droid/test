import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../models/piece_model.dart';
import '../core/move_validator.dart';
import 'board_painter.dart';
import 'piece_widget.dart';
import 'valid_move_indicator.dart';

class GameView extends GetView<GameController> {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('象棋 Pro'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _showResetConfirm(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 状态栏
          Obx(() => _buildStatusBar()),
          // 棋盘区域
          Expanded(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return _buildBoard(constraints);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    final turnText = controller.currentTurn.value == PieceSide.red ? '红方' : '黑方';
    final checkText = controller.inCheck.value ? ' | 将军！' : '';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: controller.currentTurn.value == PieceSide.red
          ? Colors.red.shade50
          : Colors.grey.shade200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: controller.currentTurn.value == PieceSide.red
                  ? Colors.red
                  : Colors.black,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$turnText走棋$checkText',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: controller.inCheck.value ? Colors.red : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoard(BoxConstraints constraints) {
    // 计算棋盘尺寸
    // 棋盘是 8 格宽 × 9 格高（交叉点 9×10）
    // 需要额外边距放置棋子
    final maxW = constraints.maxWidth;
    final maxH = constraints.maxHeight;

    // 以格子大小为基准适配
    final cellByWidth = (maxW - 40) / 8; // 两侧各留20边距
    final cellByHeight = (maxH - 40) / 9;
    final cellSize = cellByWidth < cellByHeight ? cellByWidth : cellByHeight;

    final boardWidth = cellSize * 8;
    final boardHeight = cellSize * 9;
    final pieceSize = cellSize * 0.85;

    // 棋盘区域总大小（包含半个棋子的外边距）
    final totalWidth = boardWidth + pieceSize;
    final totalHeight = boardHeight + pieceSize;

    final offsetX = pieceSize / 2;
    final offsetY = pieceSize / 2;

    return SizedBox(
      width: totalWidth,
      height: totalHeight,
      child: GestureDetector(
        onTapUp: (details) {
          final grid = pixelToGrid(
            details.localPosition.dx,
            details.localPosition.dy,
            cellSize,
            offsetX,
            offsetY,
          );
          if (grid != null) {
            controller.onBoardTap(grid.col, grid.row);
          }
        },
        child: Obx(() {
          final board = buildBoard(controller.pieces);

          return Stack(
            children: [
              // 底层：棋盘
              CustomPaint(
                size: Size(totalWidth, totalHeight),
                painter: BoardPainter(
                  cellSize: cellSize,
                  offsetX: offsetX,
                  offsetY: offsetY,
                ),
              ),

              // 中层：合法走位提示
              ...controller.validMoves.map((m) {
                final pos = gridToPixel(m.col, m.row, cellSize, offsetX, offsetY);
                final isCapture = board[m.row][m.col] != null;
                return Positioned(
                  left: pos.dx - pieceSize / 2,
                  top: pos.dy - pieceSize / 2,
                  child: IgnorePointer(
                    child: SizedBox(
                      width: pieceSize,
                      height: pieceSize,
                      child: Center(
                        child: ValidMoveIndicator(
                          isCapture: isCapture,
                          size: pieceSize,
                        ),
                      ),
                    ),
                  ),
                );
              }),

              // 顶层：棋子
              ...controller.pieces.asMap().entries.map((entry) {
                final index = entry.key;
                final piece = entry.value;
                final pos = gridToPixel(
                  piece.col,
                  piece.row,
                  cellSize,
                  offsetX,
                  offsetY,
                );
                final isSelected = controller.selectedIndex.value == index;

                return AnimatedPositioned(
                  key: ValueKey('${piece.side.name}_${piece.type.name}_$index'),
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  left: pos.dx - pieceSize / 2,
                  top: pos.dy - pieceSize / 2,
                  child: IgnorePointer(
                    child: PieceWidget(
                      piece: piece,
                      size: pieceSize,
                      isSelected: isSelected,
                    ),
                  ),
                );
              }),

              // 游戏结束对话框触发
              if (controller.isGameOver.value)
                _buildGameOverOverlay(),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    final winnerText = controller.winner.value == PieceSide.red ? '红方' : '黑方';

    // 使用 addPostFrameCallback 来弹出对话框
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.isGameOver.value && Get.isDialogOpen != true) {
        Get.dialog(
          AlertDialog(
            title: const Text('游戏结束'),
            content: Text('$winnerText获胜！'),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                  controller.resetBoard();
                },
                child: const Text('再来一局'),
              ),
            ],
          ),
          barrierDismissible: false,
        );
      }
    });

    return const SizedBox.shrink();
  }

  void _showResetConfirm(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('重新开始'),
        content: const Text('确定要重新开始游戏吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.resetBoard();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
