import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import '../models/piece_model.dart';
import '../models/board_state.dart';
import '../core/move_validator.dart';
import '../core/sound_service.dart';

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

  /// 赢家
  final winner = Rx<PieceSide?>(null);

  /// 倒计时秒数
  final countdown = 30.obs;

  /// 回合版本号（每次切换回合+1，用于触发动画）
  final turnVersion = 0.obs;

  static const int maxCountdown = 30;
  static const int warningThreshold = 10;

  Timer? _timer;
  final SoundService _sound = SoundService();
  final _random = Random();

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
    pieces.value = initialPieces();
    currentTurn.value = PieceSide.red;
    selectedIndex.value = -1;
    validMoves.clear();
    inCheck.value = false;
    isGameOver.value = false;
    winner.value = null;
    turnVersion.value = 0;
    _restartTimer();
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

  void _onTick(Timer timer) {
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
    if (isGameOver.value) return;

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

    // 切换回合
    final nextSide =
        currentTurn.value == PieceSide.red ? PieceSide.black : PieceSide.red;
    currentTurn.value = nextSide;
    turnVersion.value++;

    // 检查游戏状态
    _checkGameState();

    // 重启倒计时
    if (!isGameOver.value) {
      _restartTimer();
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
}
