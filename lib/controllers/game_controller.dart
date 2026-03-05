import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import '../models/piece_model.dart';
import '../models/board_state.dart';
import '../core/move_validator.dart';
import '../core/sound_service.dart';

/// 一步棋的记录
class MoveRecord {
  final List<PieceModel> pieces;
  final PieceSide turn;
  final bool wasInCheck;

  MoveRecord({
    required this.pieces,
    required this.turn,
    required this.wasInCheck,
  });
}

class GameController extends GetxController {
  /// 棋盘上的所有棋子
  final pieces = <PieceModel>[].obs;

  /// 当前回合方
  final currentTurn = PieceSide.red.obs;

  /// 当前选中的棋子索引 (-1 表示未选中)
  final selectedIndex = (-1).obs;

  /// 当前选中棋子的合法走位
  final validMoves = <({int col, int row})>[].obs;

  /// 是否将军
  final inCheck = false.obs;

  /// 游戏是否结束
  final isGameOver = false.obs;

  /// 是否暂停
  final isPaused = false.obs;

  /// AI（黑方）是否正在思考中
  final isAiThinking = false.obs;

  /// 赢家
  final winner = Rx<PieceSide?>(null);

  /// 倒计时秒数
  final countdown = 30.obs;

  /// 回合版本号（每次切换回合+1，用于触发动画）
  final turnVersion = 0.obs;

  /// 走棋历史（用于悔棋）
  final _moveHistory = <MoveRecord>[];

  /// 是否可以悔棋
  final canUndo = false.obs;

  /// 提示的棋子索引
  final hintPieceIndex = (-1).obs;

  /// 提示的目标位置
  final hintTarget = Rx<({int col, int row})?>(null);

  static const int maxCountdown = 30;
  static const int warningThreshold = 10;

  Timer? _timer;
  final SoundService _sound = SoundService();
  final _random = Random();

  /// AI 走棋取消令牌：每次悔棋/重置时递增，已安排的 AI 走棋检测不一致则取消
  int _aiMoveToken = 0;

  @override
  void onInit() {
    super.onInit();
    resetBoard();
  }

  @override
  void onClose() {
    _stopTimer();
    _sound.dispose();
    super.onClose();
  }

  /// 重置棋盘到初始状态
  void resetBoard() {
    // 取消任何待执行的 AI 走棋
    _aiMoveToken++;
    pieces.value = initialPieces();
    currentTurn.value = PieceSide.red;
    selectedIndex.value = -1;
    validMoves.clear();
    inCheck.value = false;
    isGameOver.value = false;
    isPaused.value = false;
    isAiThinking.value = false;
    winner.value = null;
    turnVersion.value = 0;
    _moveHistory.clear();
    canUndo.value = false;
    _clearHint();
    _restartTimer();
    _sound.playStart();
  }

  // ============================================================
  // 倒计时逻辑
  // ============================================================

  void _restartTimer() {
    _stopTimer();
    countdown.value = maxCountdown;
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _resumeTimer() {
    _stopTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  void _onTick(Timer timer) {
    if (isPaused.value) return;
    if (isGameOver.value) {
      _stopTimer();
      return;
    }

    countdown.value--;

    // 10秒时播放提示音
    if (countdown.value == warningThreshold) {
      _sound.playBeep();
    }
    // 每秒 <= 5 秒也播放提示音
    if (countdown.value > 0 && countdown.value <= 5) {
      _sound.playBeep();
    }

    // 超时自动走子
    if (countdown.value <= 0) {
      _stopTimer();
      _autoMove();
    }
  }

  /// 超时自动走子：随机选一个有合法走法的己方棋子，随机走一步
  void _autoMove() {
    final board = buildBoard(pieces);
    final side = currentTurn.value;

    // 收集所有有合法走法的己方棋子
    final candidates = <(int pieceIndex, List<({int col, int row})> moves)>[];
    for (int i = 0; i < pieces.length; i++) {
      final p = pieces[i];
      if (p.side != side) continue;
      final moves = getValidMoves(piece: p, board: board);
      if (moves.isNotEmpty) {
        candidates.add((i, moves));
      }
    }

    if (candidates.isEmpty) return;

    // 随机选一个棋子和一个走法
    final chosen = candidates[_random.nextInt(candidates.length)];
    final move = chosen.$2[_random.nextInt(chosen.$2.length)];

    // 选中并执行
    selectedIndex.value = chosen.$1;
    validMoves.value = chosen.$2;
    _executeMove(move.col, move.row);
  }

  // ============================================================
  // 点击 & 走子逻辑
  // ============================================================

  /// 统一点击处理
  void onBoardTap(int col, int row) {
    if (isPaused.value) return;
    if (isGameOver.value) return;
    // AI 思考期间（黑方回合）禁止玩家操作棋盘
    if (isAiThinking.value) return;
    // 只有红方由玩家操作
    if (currentTurn.value == PieceSide.black) return;

    final board = buildBoard(pieces);
    final tappedPiece = board[row][col];

    if (selectedIndex.value == -1) {
      if (tappedPiece != null && tappedPiece.side == currentTurn.value) {
        _selectPiece(tappedPiece, board);
      }
    } else {
      final selected = pieces[selectedIndex.value];

      if (tappedPiece != null && tappedPiece.side == currentTurn.value) {
        if (tappedPiece.col == selected.col && tappedPiece.row == selected.row) {
          _clearSelection();
        } else {
          _selectPiece(tappedPiece, board);
        }
        return;
      }

      final isValid = validMoves.any((m) => m.col == col && m.row == row);
      if (isValid) {
        _executeMove(col, row);
      } else {
        _clearSelection();
      }
    }
  }

  void _selectPiece(PieceModel piece, List<List<PieceModel?>> board) {
    final index = pieces.indexWhere(
      (p) => p.col == piece.col && p.row == piece.row,
    );
    if (index == -1) return;

    selectedIndex.value = index;
    validMoves.value = getValidMoves(piece: piece, board: board);
  }

  void _clearSelection() {
    selectedIndex.value = -1;
    validMoves.clear();
  }

  /// 执行走子
  void _executeMove(int targetCol, int targetRow) {
    // 记录走棋前的状态用于悔棋
    _moveHistory.add(MoveRecord(
      pieces: List<PieceModel>.from(pieces),
      turn: currentTurn.value,
      wasInCheck: inCheck.value,
    ));
    canUndo.value = true;
    _clearHint();

    final selected = pieces[selectedIndex.value];

    final capturedIndex = pieces.indexWhere(
      (p) => p.col == targetCol && p.row == targetRow,
    );

    final newPieces = List<PieceModel>.from(pieces);

    if (capturedIndex != -1) {
      newPieces.removeAt(capturedIndex);
      final adjustedSelectedIndex =
          capturedIndex < selectedIndex.value
              ? selectedIndex.value - 1
              : selectedIndex.value;
      newPieces[adjustedSelectedIndex] = selected.copyWith(
        col: targetCol,
        row: targetRow,
      );
    } else {
      newPieces[selectedIndex.value] = selected.copyWith(
        col: targetCol,
        row: targetRow,
      );
    }

    pieces.value = newPieces;
    _clearSelection();

    // 播放音效
    if (capturedIndex != -1) {
      _sound.playCapture();
    } else {
      _sound.playMove();
    }

    // 切换回合
    final nextSide =
        currentTurn.value == PieceSide.red ? PieceSide.black : PieceSide.red;
    currentTurn.value = nextSide;
    turnVersion.value++;

    // 检查游戏状态
    _checkGameState();

    if (!isGameOver.value) {
      if (nextSide == PieceSide.black) {
        // 黑方由 AI 自动走棋：停止倒计时，延迟 800ms 后执行
        _stopTimer();
        isAiThinking.value = true;
        final token = ++_aiMoveToken;
        Future.delayed(const Duration(milliseconds: 800), () {
          // 令牌不一致说明已被悔棋/重置取消
          if (token != _aiMoveToken) return;
          if (!isGameOver.value && !isPaused.value) {
            _autoMove();
          }
          isAiThinking.value = false;
        });
      } else {
        // 红方由玩家操作：重启倒计时
        isAiThinking.value = false;
        _restartTimer();
      }
    }
  }

  /// 检查游戏状态
  void _checkGameState() {
    final board = buildBoard(pieces);
    final currentSide = currentTurn.value;

    inCheck.value = isInCheck(currentSide, board);

    if (!hasLegalMoves(currentSide, board)) {
      isGameOver.value = true;
      winner.value =
          currentSide == PieceSide.red ? PieceSide.black : PieceSide.red;
      _stopTimer();
    }
  }

  /// 暂停游戏
  void pauseGame() {
    if (isGameOver.value) return;
    isPaused.value = true;
    _stopTimer();
  }

  /// 恢复游戏
  void resumeGame() {
    if (isGameOver.value) return;
    isPaused.value = false;
    if (currentTurn.value == PieceSide.black) {
      // 黑方回合恢复时，重新安排 AI 走棋
      isAiThinking.value = true;
      final token = ++_aiMoveToken;
      Future.delayed(const Duration(milliseconds: 800), () {
        if (token != _aiMoveToken) return;
        if (!isGameOver.value && !isPaused.value) {
          _autoMove();
        }
        isAiThinking.value = false;
      });
    } else {
      // 红方回合恢复倒计时
      _resumeTimer();
    }
  }

  /// 选中棋子（保留向后兼容）
  void selectPiece(int index) {
    if (index < 0 || index >= pieces.length) return;
    if (pieces[index].side != currentTurn.value) return;
    final board = buildBoard(pieces);
    _selectPiece(pieces[index], board);
  }

  /// 切换回合
  void switchTurn() {
    currentTurn.value =
        currentTurn.value == PieceSide.red ? PieceSide.black : PieceSide.red;
    selectedIndex.value = -1;
    validMoves.clear();
  }

  // ============================================================
  // 悔棋
  // ============================================================

  /// 悔棋：回退到上一步状态
  /// 由于黑方是 AI，一次悔棋会连续倒退两步（黑方 + 红方），确保始终回到红方回合
  void undoMove() {
    if (_moveHistory.isEmpty) return;
    if (isGameOver.value) return;

    // 取消任何待执行的 AI 走棋
    _aiMoveToken++;
    isAiThinking.value = false;

    // 弹出最近一步
    var record = _moveHistory.removeLast();

    // 如果弹出后回合变成了黑方（说明刚才弹的是红方走的那步），
    // 需要再弹一步黑方的走棋记录，确保最终回到红方回合
    if (record.turn == PieceSide.black && _moveHistory.isNotEmpty) {
      record = _moveHistory.removeLast();
    }

    pieces.value = record.pieces;
    currentTurn.value = record.turn;
    inCheck.value = record.wasInCheck;
    selectedIndex.value = -1;
    validMoves.clear();
    canUndo.value = _moveHistory.isNotEmpty;
    _clearHint();

    // 重启倒计时（红方回合）
    _restartTimer();
  }

  // ============================================================
  // 提示（走法建议）
  // ============================================================

  /// 清除提示状态
  void _clearHint() {
    hintPieceIndex.value = -1;
    hintTarget.value = null;
  }

  /// 给当前走棋方一个走法提示
  void showHint() {
    if (isPaused.value || isGameOver.value) return;

    final board = buildBoard(pieces);
    final side = currentTurn.value;

    // 优先级：能吃子 > 能将军 > 普通走法
    ({int pieceIndex, ({int col, int row}) target, int score})? bestMove;

    for (int i = 0; i < pieces.length; i++) {
      final p = pieces[i];
      if (p.side != side) continue;
      final moves = getValidMoves(piece: p, board: board);
      for (final m in moves) {
        int score = 0;

        // 吃子得分
        final targetPiece = board[m.row][m.col];
        if (targetPiece != null && targetPiece.side != side) {
          score += _pieceValue(targetPiece.type);
        }

        // 走后是否将军得分
        final simBoard = _simulateMove(board, p, m.col, m.row);
        final enemySide =
            side == PieceSide.red ? PieceSide.black : PieceSide.red;
        if (isInCheck(enemySide, simBoard)) {
          score += 50;
        }

        if (bestMove == null || score > bestMove.score) {
          bestMove = (pieceIndex: i, target: m, score: score);
        }
      }
    }

    if (bestMove != null) {
      hintPieceIndex.value = bestMove.pieceIndex;
      hintTarget.value = bestMove.target;

      // 3秒后自动清除提示
      Future.delayed(const Duration(seconds: 3), () {
        _clearHint();
      });
    }
  }

  /// 模拟走子（用于提示评估）
  static List<List<PieceModel?>> _simulateMove(
    List<List<PieceModel?>> board,
    PieceModel piece,
    int targetCol,
    int targetRow,
  ) {
    final newBoard = List.generate(
      10,
      (r) => List<PieceModel?>.generate(9, (c) => board[r][c]),
    );
    newBoard[piece.row][piece.col] = null;
    newBoard[targetRow][targetCol] =
        piece.copyWith(col: targetCol, row: targetRow);
    return newBoard;
  }

  /// 棋子价值评估
  static int _pieceValue(PieceType type) {
    switch (type) {
      case PieceType.king:
        return 10000;
      case PieceType.chariot:
        return 100;
      case PieceType.horse:
        return 50;
      case PieceType.cannon:
        return 50;
      case PieceType.elephant:
        return 20;
      case PieceType.advisor:
        return 20;
      case PieceType.soldier:
        return 10;
    }
  }
}
