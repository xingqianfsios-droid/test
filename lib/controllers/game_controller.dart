import 'package:get/get.dart';
import '../models/piece_model.dart';
import '../models/board_state.dart';
import '../core/move_validator.dart';

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

  @override
  void onInit() {
    super.onInit();
    resetBoard();
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
  }

  /// 统一点击处理
  void onBoardTap(int col, int row) {
    if (isGameOver.value) return;

    final board = buildBoard(pieces);

    // 检查点击位置是否有棋子
    final tappedPiece = board[row][col];

    if (selectedIndex.value == -1) {
      // 未选中状态：选择己方棋子
      if (tappedPiece != null && tappedPiece.side == currentTurn.value) {
        _selectPiece(tappedPiece, board);
      }
    } else {
      final selected = pieces[selectedIndex.value];

      // 点击了己方另一个棋子：切换选择
      if (tappedPiece != null && tappedPiece.side == currentTurn.value) {
        if (tappedPiece.col == selected.col && tappedPiece.row == selected.row) {
          // 点击同一个棋子：取消选择
          _clearSelection();
        } else {
          _selectPiece(tappedPiece, board);
        }
        return;
      }

      // 检查是否为合法走位
      final isValid = validMoves.any((m) => m.col == col && m.row == row);
      if (isValid) {
        _executeMove(col, row);
      } else {
        // 点击无效位置：取消选择
        _clearSelection();
      }
    }
  }

  void _selectPiece(PieceModel piece, List<List<PieceModel?>> board) {
    // 找到该棋子在 pieces 列表中的索引
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

    // 移除被吃的棋子
    final capturedIndex = pieces.indexWhere(
      (p) => p.col == targetCol && p.row == targetRow,
    );

    final newPieces = List<PieceModel>.from(pieces);

    if (capturedIndex != -1) {
      newPieces.removeAt(capturedIndex);
      // 调整选中索引（如果被吃棋子在选中棋子前面）
      final adjustedSelectedIndex =
          capturedIndex < selectedIndex.value
              ? selectedIndex.value - 1
              : selectedIndex.value;
      // 更新棋子位置
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

    // 检查游戏状态
    _checkGameState();
  }

  /// 检查游戏状态
  void _checkGameState() {
    final board = buildBoard(pieces);
    final currentSide = currentTurn.value;

    // 检查是否被将
    inCheck.value = isInCheck(currentSide, board);

    // 检查对方是否还有合法走法
    if (!hasLegalMoves(currentSide, board)) {
      isGameOver.value = true;
      // 无合法走法的一方输
      winner.value =
          currentSide == PieceSide.red ? PieceSide.black : PieceSide.red;
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
