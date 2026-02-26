import 'package:get/get.dart';
import '../models/piece_model.dart';
import '../models/board_state.dart';

class GameController extends GetxController {
  /// 棋盘上的所有棋子
  final pieces = <PieceModel>[].obs;

  /// 当前回合方
  final currentTurn = PieceSide.red.obs;

  /// 当前选中的棋子索引 (-1 表示未选中)
  final selectedIndex = (-1).obs;

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
  }

  /// 选中棋子
  void selectPiece(int index) {
    if (index < 0 || index >= pieces.length) return;
    if (pieces[index].side != currentTurn.value) return;
    selectedIndex.value = index;
  }

  /// 切换回合
  void switchTurn() {
    currentTurn.value =
        currentTurn.value == PieceSide.red ? PieceSide.black : PieceSide.red;
    selectedIndex.value = -1;
  }
}
