import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../models/piece_model.dart';
import '../core/move_validator.dart';
import 'board_painter.dart';
import 'piece_widget.dart';
import 'valid_move_indicator.dart';

/// 古风色彩常量
const _kParchment = Color(0xFFF5E6C8);
const _kInk = Color(0xFF3C2415);
const _kGold = Color(0xFF8B6914);
const _kGoldLight = Color(0xFFD4A84B);
const _kBamboo = Color(0xFFE8D5B0);
const _kRedInk = Color(0xFFA01010);

/// 按钮主色：深朱红
const _kBtnPrimary = Color(0xFFC0392B);
const _kBtnPrimaryDark = Color(0xFF922B21);
const _kBtnPrimaryLight = Color(0xFFE74C3C);
const _kBtnOutlineBorder = Color(0xFFD4A84B);

class GameView extends GetView<GameController> {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kParchment,
      appBar: AppBar(
        backgroundColor: _kInk,
        foregroundColor: _kBamboo,
        title: const Text('对 弈'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: _kBamboo,
          letterSpacing: 8,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _showExitConfirm(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_stories),
            tooltip: '棋谱规则',
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
                isAiThinking: controller.isAiThinking.value,
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
          // 底部功能按钮栏
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildBoard(BoxConstraints constraints) {
    final maxW = constraints.maxWidth;
    final maxH = constraints.maxHeight;

    final cellByWidth = maxW / 8.88;
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

              // 提示层：高亮提示棋子和目标位置
              if (controller.hintPieceIndex.value >= 0 &&
                  controller.hintPieceIndex.value < controller.pieces.length) ...[
                // 提示棋子高亮
                Builder(builder: (_) {
                  final hintPiece = controller.pieces[controller.hintPieceIndex.value];
                  final pos = gridToPixel(hintPiece.col, hintPiece.row, cellSize, offsetX, offsetY);
                  return Positioned(
                    left: pos.dx - pieceSize / 2 - 3,
                    top: pos.dy - pieceSize / 2 - 3,
                    child: IgnorePointer(
                      child: _HintGlow(size: pieceSize + 6, color: _kGoldLight),
                    ),
                  );
                }),
                // 提示目标位置
                if (controller.hintTarget.value != null)
                  Builder(builder: (_) {
                    final t = controller.hintTarget.value!;
                    final pos = gridToPixel(t.col, t.row, cellSize, offsetX, offsetY);
                    return Positioned(
                      left: pos.dx - pieceSize / 2,
                      top: pos.dy - pieceSize / 2,
                      child: IgnorePointer(
                        child: _HintGlow(size: pieceSize, color: const Color(0xFF4CAF50)),
                      ),
                    );
                  }),
              ],

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
                    color: const Color(0xCC2C1810),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.pause_circle_outlined,
                              size: 64, color: _kGoldLight),
                          const SizedBox(height: 16),
                          const Text('暂 停',
                              style: TextStyle(
                                  fontSize: 28,
                                  color: _kBamboo,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 12)),
                          const SizedBox(height: 24),
                          _GamePrimaryButton(
                            label: '继续对弈',
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
            backgroundColor: _kParchment,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: _kGold, width: 1.5),
            ),
            title: const Text('对弈结束', style: TextStyle(color: _kInk)),
            content: Text('$winnerText获胜！',
                style: const TextStyle(fontSize: 18, color: Color(0xFF5C3A1E))),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: _kBtnPrimary,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
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
        backgroundColor: _kParchment,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: _kGold, width: 1.5),
        ),
        title: const Text('重新开局', style: TextStyle(color: _kInk)),
        content: const Text('确定要重新开始对弈吗？'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: _kGold,
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: _kBtnPrimary,
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
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

  void _showExitConfirm() {
    controller.pauseGame();
    Get.dialog(
      AlertDialog(
        backgroundColor: _kParchment,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: _kGold, width: 1.5),
        ),
        title: const Text('返回首页', style: TextStyle(color: _kInk)),
        content: const Text('当前对局将会丢失，确定返回吗？'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: _kGold,
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
            onPressed: () {
              Get.back();
              controller.resumeGame();
            },
            child: const Text('继续对弈'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: _kBtnPrimary,
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            onPressed: () {
              Get.back();
              Get.back();
            },
            child: const Text('确定返回'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0x20000000), width: 1),
        ),
      ),
      child: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ActionButton(
                icon: Icons.replay,
                label: '重玩',
                onTap: () => _showResetConfirm(context),
              ),
              _ActionButton(
                icon: Icons.lightbulb_outline,
                label: '提示',
                onTap: controller.isPaused.value || controller.isGameOver.value
                    ? null
                    : () => controller.showHint(),
              ),
              _ActionButton(
                icon: Icons.undo,
                label: '悔棋',
                onTap: controller.canUndo.value &&
                        !controller.isPaused.value &&
                        !controller.isGameOver.value
                    ? () => controller.undoMove()
                    : null,
              ),
            ],
          )),
    );
  }

  void _showRulesDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: _kParchment,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: _kGold, width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.auto_stories, color: _kGold),
            SizedBox(width: 8),
            Text('棋谱规则', style: TextStyle(color: _kInk)),
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
              Divider(color: _kGold),
              _RuleSection(title: '胜负判定', content: '将对方的帅/将吃掉或使其无路可走（绝杀/困毙）即获胜。'),
              _RuleSection(title: '倒计时', content: '每步棋有30秒的思考时间。倒计时10秒时会有声音提示，超时系统将自动帮你走一步棋。'),
            ],
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: _kBtnPrimary,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            onPressed: () => Get.back(),
            child: const Text('知晓'),
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
          style: const TextStyle(fontSize: 14, color: Color(0xFF5C3A1E), height: 1.6),
          children: [
            TextSpan(
              text: '$title：',
              style: const TextStyle(fontWeight: FontWeight.bold, color: _kGold),
            ),
            TextSpan(text: content),
          ],
        ),
      ),
    );
  }
}

/// 底部功能按钮（升级版：启用态深朱红边框 + 阴影，禁用态淡出）
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final iconColor = enabled ? _kBtnPrimary : const Color(0xFFBBAA9A);
    final textColor = enabled ? _kInk : const Color(0xFFBBAA9A);
    final borderColor = enabled ? _kBtnPrimary : const Color(0xFFCCC4B4);
    final bgColor = enabled ? const Color(0xFFFAF0E6) : const Color(0xFFF5EDE4);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: enabled ? 1.5 : 1),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: _kBtnPrimary.withValues(alpha: 0.18),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                  const BoxShadow(
                    color: Color(0x20000000),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: iconColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: textColor,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 游戏页内主按钮（暂停遮罩使用）
class _GamePrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _GamePrimaryButton({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kBtnPrimaryLight, _kBtnPrimary, _kBtnPrimaryDark],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _kBtnOutlineBorder, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x60922B21),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: _kParchment,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

/// 提示光晕效果
class _HintGlow extends StatefulWidget {
  final double size;
  final Color color;

  const _HintGlow({required this.size, required this.color});

  @override
  State<_HintGlow> createState() => _HintGlowState();
}

class _HintGlowState extends State<_HintGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.color.withValues(alpha: _animation.value),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: _animation.value * 0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 带动画的回合状态栏
class _TurnStatusBar extends StatefulWidget {
  final bool isRed;
  final bool inCheck;
  final int countdown;
  final int turnVersion;
  final bool isPaused;
  final bool isAiThinking;

  const _TurnStatusBar({
    required this.isRed,
    required this.inCheck,
    required this.countdown,
    required this.turnVersion,
    required this.isPaused,
    required this.isAiThinking,
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
    if (widget.turnVersion != _lastTurnVersion) {
      _lastTurnVersion = widget.turnVersion;
      _slideController.forward(from: 0);
      _pulseController.repeat(reverse: true);
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
                  ? [const Color(0xFFECDBC0), const Color(0xFFF2E4CC)]
                  : [const Color(0xFFD6CEBF), const Color(0xFFE0D8CA)],
            ),
            border: const Border(
              bottom: BorderSide(color: Color(0x30000000), width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 走棋方指示
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isRed ? _kRedInk : const Color(0xFF1A1A1A),
                  boxShadow: [
                    BoxShadow(
                      color: (widget.isRed ? _kRedInk : const Color(0xFF1A1A1A))
                          .withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // 回合文字
              Text(
                widget.isAiThinking
                    ? 'AI 思考中$checkText'
                    : '$turnText执棋$checkText',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: widget.inCheck ? _kRedInk : _kInk,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 16),
              // 倒计时 / AI 状态标签
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.isPaused
                      ? const Color(0xFF8B8B7A)
                      : widget.isAiThinking
                          ? const Color(0xFF1A1A1A)
                          : isWarning
                              ? _kRedInk
                              : _kInk,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.isPaused
                      ? '暂停'
                      : widget.isAiThinking
                          ? '...'
                          : '${widget.countdown}s',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _kBamboo,
                    letterSpacing: widget.isPaused
                        ? 2
                        : widget.isAiThinking
                            ? 4
                            : (isWarning ? 1.0 : 0),
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
