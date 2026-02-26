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
            icon: const Icon(Icons.help_outline),
            tooltip: '象棋规则',
            onPressed: () => _showRulesDialog(context),
          ),
          Obx(() => IconButton(
                icon: Icon(controller.isPaused.value
                    ? Icons.play_arrow
                    : Icons.pause),
                tooltip: controller.isPaused.value ? '继续' : '暂停',
                onPressed: () {
                  if (controller.isPaused.value) {
                    controller.resumeGame();
                  } else {
                    controller.pauseGame();
                  }
                },
              )),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _showResetConfirm(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 动画状态栏 + 倒计时
          Obx(() => _TurnStatusBar(
                isRed: controller.currentTurn.value == PieceSide.red,
                inCheck: controller.inCheck.value,
                countdown: controller.countdown.value,
                turnVersion: controller.turnVersion.value,
                isPaused: controller.isPaused.value,
              )),
          // 棋盘区域：左右各 16px 间隙
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return _buildBoard(constraints);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoard(BoxConstraints constraints) {
    final maxW = constraints.maxWidth;
    final maxH = constraints.maxHeight;

    // 棋盘总宽 = cellSize * 8 + pieceSize = cellSize * 8.88
    // 棋盘总高 = cellSize * 9 + pieceSize = cellSize * 9.88
    // 宽度填满可用空间（外层已有 16px 水平 padding）
    final cellByWidth = maxW / 8.88;
    // 高度仅留极小上下边距，尽量拉高
    final cellByHeight = (maxH - 8) / 9.88;
    final cellSize = cellByWidth < cellByHeight ? cellByWidth : cellByHeight;

    final boardWidth = cellSize * 8;
    final boardHeight = cellSize * 9;
    final pieceSize = cellSize * 0.88;

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
                  key: ValueKey(piece.id),
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

              // 暂停遮罩
              if (controller.isPaused.value)
                Positioned.fill(
                  child: Container(
                    color: Colors.black54,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.pause_circle_filled,
                              size: 64, color: Colors.white),
                          const SizedBox(height: 16),
                          const Text('游戏暂停',
                              style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('继续游戏'),
                            onPressed: () => controller.resumeGame(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

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

  void _showRulesDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.menu_book, color: Colors.brown),
            SizedBox(width: 8),
            Text('象棋规则'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _RuleSection(title: '帅/将', content: '只能在九宫格内移动（3x3区域），每步上下左右走一格。两方的帅和将不能在同一列上直接对面（中间无棋子阻隔）。'),
              _RuleSection(title: '仕/士', content: '只能在九宫格内沿斜线移动，每步走一格。'),
              _RuleSection(title: '相/象', content: '沿对角线走"田"字（两格），不能越过河界到对方阵地。如果"田"字中心有棋子（塞象眼），则不能走。'),
              _RuleSection(title: '马', content: '走"日"字，先直走一格再斜走一格。如果直走方向有棋子（别马腿/蹩马腿），则不能走该方向。'),
              _RuleSection(title: '车', content: '横竖直线任意移动，不能越过其他棋子。可以吃路径上第一个遇到的对方棋子。'),
              _RuleSection(title: '炮', content: '移动方式与车相同（直线）。但吃子时必须翻过恰好一个棋子（炮架），吃掉炮架后面的第一个对方棋子。'),
              _RuleSection(title: '兵/卒', content: '未过河前只能向前走一步。过河后可以向前、向左或向右走一步，但不能后退。'),
              Divider(),
              _RuleSection(title: '胜负判定', content: '将对方的帅/将吃掉或使其无路可走（绝杀/困毙）即获胜。'),
              _RuleSection(title: '倒计时', content: '每步棋有30秒的思考时间。倒计时10秒时会有声音提示，超时系统将自动帮你走一步棋。'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }
}

/// 规则说明段落组件
class _RuleSection extends StatelessWidget {
  final String title;
  final String content;

  const _RuleSection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
          children: [
            TextSpan(
              text: '$title：',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown),
            ),
            TextSpan(text: content),
          ],
        ),
      ),
    );
  }
}

/// 带动画的回合状态栏（StatefulWidget 以支持 AnimationController）
class _TurnStatusBar extends StatefulWidget {
  final bool isRed;
  final bool inCheck;
  final int countdown;
  final int turnVersion;
  final bool isPaused;

  const _TurnStatusBar({
    required this.isRed,
    required this.inCheck,
    required this.countdown,
    required this.turnVersion,
    required this.isPaused,
  });

  @override
  State<_TurnStatusBar> createState() => _TurnStatusBarState();
}

class _TurnStatusBarState extends State<_TurnStatusBar>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  int _lastTurnVersion = -1;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _TurnStatusBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 回合切换时触发滑入动画
    if (widget.turnVersion != _lastTurnVersion) {
      _lastTurnVersion = widget.turnVersion;
      _slideController.forward(from: 0);
      _pulseController.repeat(reverse: true);
      // 2秒后停止脉冲
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _pulseController.stop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final turnText = widget.isRed ? '红方' : '黑方';
    final checkText = widget.inCheck ? ' | 将军！' : '';
    final isWarning = widget.countdown <= GameController.warningThreshold;

    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _pulseAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isRed
                  ? [Colors.red.shade100, Colors.red.shade50]
                  : [Colors.blueGrey.shade100, Colors.grey.shade200],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 走棋方指示圆点
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isRed ? Colors.red : Colors.black,
                  boxShadow: [
                    BoxShadow(
                      color: (widget.isRed ? Colors.red : Colors.black)
                          .withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // 回合文字
              Text(
                '$turnText走棋$checkText',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: widget.inCheck ? Colors.red.shade700 : Colors.black87,
                ),
              ),
              const SizedBox(width: 16),
              // 倒计时
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.isPaused
                      ? Colors.grey
                      : isWarning
                          ? Colors.red.shade600
                          : Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.isPaused ? '暂停' : '${widget.countdown}s',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: widget.isPaused ? 0 : (isWarning ? 1.0 : 0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
