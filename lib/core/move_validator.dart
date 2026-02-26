import '../models/piece_model.dart';

/// 从棋子列表构建 9x10 棋盘二维数组
/// board[row][col] 为该位置的棋子，null 表示空位
List<List<PieceModel?>> buildBoard(List<PieceModel> pieces) {
  final board = List.generate(10, (_) => List<PieceModel?>.filled(9, null));
  for (final p in pieces) {
    board[p.row][p.col] = p;
  }
  return board;
}

/// 判断坐标是否在棋盘内 (9列 x 10行)
bool _inBounds(int col, int row) {
  return col >= 0 && col <= 8 && row >= 0 && row <= 9;
}

/// 获取马从 (col, row) 出发的所有合法目标位置
///
/// 日字走法：先沿一个直线方向走一格，再斜走一格。
/// 别马腿：如果直线方向第一格有棋子，则该方向的两个目标位置均不可走。
List<({int col, int row})> getHorseMoves({
  required int col,
  required int row,
  required PieceSide side,
  required List<List<PieceModel?>> board,
}) {
  final moves = <({int col, int row})>[];

  // 四个直线方向及其对应的两个斜向终点
  // (legDCol, legDRow) 是马腿位置的偏移
  // (tCol, tRow) 是两个终点的偏移
  const directions = [
    // 向上走一格，马腿在 (0, -1)
    (legDCol: 0, legDRow: -1, targets: [(-1, -2), (1, -2)]),
    // 向下走一格，马腿在 (0, +1)
    (legDCol: 0, legDRow: 1, targets: [(-1, 2), (1, 2)]),
    // 向左走一格，马腿在 (-1, 0)
    (legDCol: -1, legDRow: 0, targets: [(-2, -1), (-2, 1)]),
    // 向右走一格，马腿在 (+1, 0)
    (legDCol: 1, legDRow: 0, targets: [(2, -1), (2, 1)]),
  ];

  for (final dir in directions) {
    final legCol = col + dir.legDCol;
    final legRow = row + dir.legDRow;

    // 马腿位置超出棋盘
    if (!_inBounds(legCol, legRow)) continue;

    // 别马腿：马腿位置有棋子则该方向不可走
    if (board[legRow][legCol] != null) continue;

    for (final (dCol, dRow) in dir.targets) {
      final tCol = col + dCol;
      final tRow = row + dRow;

      if (!_inBounds(tCol, tRow)) continue;

      // 目标位置有己方棋子则不可走
      final target = board[tRow][tCol];
      if (target != null && target.side == side) continue;

      moves.add((col: tCol, row: tRow));
    }
  }

  return moves;
}
