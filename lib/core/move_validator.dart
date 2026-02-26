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

// ============================================================
// 帅/将 (King)
// ============================================================

/// 获取帅/将的合法走位：九宫内上下左右各1步
List<({int col, int row})> getKingMoves({
  required int col,
  required int row,
  required PieceSide side,
  required List<List<PieceModel?>> board,
}) {
  final moves = <({int col, int row})>[];

  // 九宫范围
  final minCol = 3;
  final maxCol = 5;
  final minRow = side == PieceSide.red ? 7 : 0;
  final maxRow = side == PieceSide.red ? 9 : 2;

  const deltas = [(0, -1), (0, 1), (-1, 0), (1, 0)];

  for (final (dc, dr) in deltas) {
    final nc = col + dc;
    final nr = row + dr;
    if (nc < minCol || nc > maxCol || nr < minRow || nr > maxRow) continue;
    final target = board[nr][nc];
    if (target != null && target.side == side) continue;
    moves.add((col: nc, row: nr));
  }

  return moves;
}

// ============================================================
// 仕/士 (Advisor)
// ============================================================

/// 获取仕/士的合法走位：九宫内斜走1步
List<({int col, int row})> getAdvisorMoves({
  required int col,
  required int row,
  required PieceSide side,
  required List<List<PieceModel?>> board,
}) {
  final moves = <({int col, int row})>[];

  final minCol = 3;
  final maxCol = 5;
  final minRow = side == PieceSide.red ? 7 : 0;
  final maxRow = side == PieceSide.red ? 9 : 2;

  const deltas = [(-1, -1), (-1, 1), (1, -1), (1, 1)];

  for (final (dc, dr) in deltas) {
    final nc = col + dc;
    final nr = row + dr;
    if (nc < minCol || nc > maxCol || nr < minRow || nr > maxRow) continue;
    final target = board[nr][nc];
    if (target != null && target.side == side) continue;
    moves.add((col: nc, row: nr));
  }

  return moves;
}

// ============================================================
// 相/象 (Elephant)
// ============================================================

/// 获取相/象的合法走位：田字对角走2步，检查象眼，不可过河
List<({int col, int row})> getElephantMoves({
  required int col,
  required int row,
  required PieceSide side,
  required List<List<PieceModel?>> board,
}) {
  final moves = <({int col, int row})>[];

  // 不可过河
  final minRow = side == PieceSide.red ? 5 : 0;
  final maxRow = side == PieceSide.red ? 9 : 4;

  // 四个方向：(象眼偏移, 终点偏移)
  const directions = [
    (eyeDc: -1, eyeDr: -1, dc: -2, dr: -2),
    (eyeDc: -1, eyeDr: 1, dc: -2, dr: 2),
    (eyeDc: 1, eyeDr: -1, dc: 2, dr: -2),
    (eyeDc: 1, eyeDr: 1, dc: 2, dr: 2),
  ];

  for (final dir in directions) {
    final eyeCol = col + dir.eyeDc;
    final eyeRow = row + dir.eyeDr;
    final nc = col + dir.dc;
    final nr = row + dir.dr;

    // 终点不在棋盘内或不在己方半场
    if (!_inBounds(nc, nr)) continue;
    if (nr < minRow || nr > maxRow) continue;

    // 象眼被阻塞
    if (board[eyeRow][eyeCol] != null) continue;

    // 目标有己方棋子
    final target = board[nr][nc];
    if (target != null && target.side == side) continue;

    moves.add((col: nc, row: nr));
  }

  return moves;
}

// ============================================================
// 马 (Horse)
// ============================================================

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

// ============================================================
// 车 (Chariot)
// ============================================================

/// 获取车的合法走位：四方向直线扫描，遇子停止，可吃敌方
List<({int col, int row})> getChariotMoves({
  required int col,
  required int row,
  required PieceSide side,
  required List<List<PieceModel?>> board,
}) {
  final moves = <({int col, int row})>[];

  const deltas = [(0, -1), (0, 1), (-1, 0), (1, 0)];

  for (final (dc, dr) in deltas) {
    var nc = col + dc;
    var nr = row + dr;
    while (_inBounds(nc, nr)) {
      final target = board[nr][nc];
      if (target == null) {
        moves.add((col: nc, row: nr));
      } else {
        if (target.side != side) {
          moves.add((col: nc, row: nr));
        }
        break;
      }
      nc += dc;
      nr += dr;
    }
  }

  return moves;
}

// ============================================================
// 炮 (Cannon)
// ============================================================

/// 获取炮的合法走位：直线移动同车；吃子需翻山（中间恰好1子）
List<({int col, int row})> getCannonMoves({
  required int col,
  required int row,
  required PieceSide side,
  required List<List<PieceModel?>> board,
}) {
  final moves = <({int col, int row})>[];

  const deltas = [(0, -1), (0, 1), (-1, 0), (1, 0)];

  for (final (dc, dr) in deltas) {
    var nc = col + dc;
    var nr = row + dr;
    bool foundMount = false;

    while (_inBounds(nc, nr)) {
      final target = board[nr][nc];
      if (!foundMount) {
        // 未翻山前
        if (target == null) {
          moves.add((col: nc, row: nr));
        } else {
          foundMount = true; // 找到炮架
        }
      } else {
        // 翻山后：只能吃子
        if (target != null) {
          if (target.side != side) {
            moves.add((col: nc, row: nr));
          }
          break; // 无论是否能吃，翻山后遇到棋子就停
        }
      }
      nc += dc;
      nr += dr;
    }
  }

  return moves;
}

// ============================================================
// 兵/卒 (Soldier)
// ============================================================

/// 获取兵/卒的合法走位：红向上，黑向下；过河后可左右
List<({int col, int row})> getSoldierMoves({
  required int col,
  required int row,
  required PieceSide side,
  required List<List<PieceModel?>> board,
}) {
  final moves = <({int col, int row})>[];

  final forward = side == PieceSide.red ? -1 : 1;
  final hasCrossedRiver = side == PieceSide.red ? row <= 4 : row >= 5;

  // 前进
  final nr = row + forward;
  if (_inBounds(col, nr)) {
    final target = board[nr][col];
    if (target == null || target.side != side) {
      moves.add((col: col, row: nr));
    }
  }

  // 过河后可左右
  if (hasCrossedRiver) {
    for (final dc in [-1, 1]) {
      final nc = col + dc;
      if (_inBounds(nc, row)) {
        final target = board[row][nc];
        if (target == null || target.side != side) {
          moves.add((col: nc, row: row));
        }
      }
    }
  }

  return moves;
}

// ============================================================
// 统一入口 & 送将检测
// ============================================================

/// 获取某一原始走法（不考虑送将）
List<({int col, int row})> _getRawMoves({
  required PieceModel piece,
  required List<List<PieceModel?>> board,
}) {
  switch (piece.type) {
    case PieceType.king:
      return getKingMoves(
          col: piece.col, row: piece.row, side: piece.side, board: board);
    case PieceType.advisor:
      return getAdvisorMoves(
          col: piece.col, row: piece.row, side: piece.side, board: board);
    case PieceType.elephant:
      return getElephantMoves(
          col: piece.col, row: piece.row, side: piece.side, board: board);
    case PieceType.horse:
      return getHorseMoves(
          col: piece.col, row: piece.row, side: piece.side, board: board);
    case PieceType.chariot:
      return getChariotMoves(
          col: piece.col, row: piece.row, side: piece.side, board: board);
    case PieceType.cannon:
      return getCannonMoves(
          col: piece.col, row: piece.row, side: piece.side, board: board);
    case PieceType.soldier:
      return getSoldierMoves(
          col: piece.col, row: piece.row, side: piece.side, board: board);
  }
}

/// 深拷贝棋盘并模拟走子
List<List<PieceModel?>> _simulateMove(
  List<List<PieceModel?>> board,
  PieceModel piece,
  int targetCol,
  int targetRow,
) {
  // 深拷贝棋盘
  final newBoard = List.generate(
    10,
    (r) => List<PieceModel?>.generate(9, (c) => board[r][c]),
  );
  // 清除原位置
  newBoard[piece.row][piece.col] = null;
  // 放到新位置
  newBoard[targetRow][targetCol] = piece.copyWith(col: targetCol, row: targetRow);
  return newBoard;
}

/// 检查将帅是否面对面（同列且中间无棋子）
bool _kingsAreFacing(List<List<PieceModel?>> board) {
  // 找到双方将/帅
  int? redCol, redRow, blackCol, blackRow;
  for (int r = 0; r < 10; r++) {
    for (int c = 0; c < 9; c++) {
      final p = board[r][c];
      if (p != null && p.type == PieceType.king) {
        if (p.side == PieceSide.red) {
          redCol = c;
          redRow = r;
        } else {
          blackCol = c;
          blackRow = r;
        }
      }
    }
  }
  if (redCol == null || blackCol == null) return false;
  if (redCol != blackCol) return false;

  // 检查中间是否有棋子
  final minR = blackRow! < redRow! ? blackRow : redRow;
  final maxR = blackRow > redRow ? blackRow : redRow;
  for (int r = minR + 1; r < maxR; r++) {
    if (board[r][redCol] != null) return false;
  }
  return true; // 面对面
}

/// 检查某方帅/将是否被攻击（用原始走法避免递归）
bool _isKingAttacked(PieceSide side, List<List<PieceModel?>> board) {
  // 找到该方的帅/将
  int? kingCol, kingRow;
  for (int r = 0; r < 10; r++) {
    for (int c = 0; c < 9; c++) {
      final p = board[r][c];
      if (p != null && p.type == PieceType.king && p.side == side) {
        kingCol = c;
        kingRow = r;
        break;
      }
    }
    if (kingCol != null) break;
  }
  if (kingCol == null || kingRow == null) return true; // 将被吃了

  final enemySide = side == PieceSide.red ? PieceSide.black : PieceSide.red;

  // 检查所有敌方棋子的原始走法是否能攻击到帅/将
  for (int r = 0; r < 10; r++) {
    for (int c = 0; c < 9; c++) {
      final p = board[r][c];
      if (p == null || p.side != enemySide) continue;
      final rawMoves = _getRawMoves(piece: p, board: board);
      for (final m in rawMoves) {
        if (m.col == kingCol && m.row == kingRow) return true;
      }
    }
  }
  return false;
}

/// 公开接口：判断某方是否被将军
bool isInCheck(PieceSide side, List<List<PieceModel?>> board) {
  return _isKingAttacked(side, board);
}

/// 获取棋子的所有合法走位（过滤送将和将帅对面）
List<({int col, int row})> getValidMoves({
  required PieceModel piece,
  required List<List<PieceModel?>> board,
}) {
  final rawMoves = _getRawMoves(piece: piece, board: board);
  final validMoves = <({int col, int row})>[];

  for (final m in rawMoves) {
    final simBoard = _simulateMove(board, piece, m.col, m.row);
    // 走后不能让自己被将
    if (_isKingAttacked(piece.side, simBoard)) continue;
    // 走后不能将帅对面
    if (_kingsAreFacing(simBoard)) continue;
    validMoves.add(m);
  }

  return validMoves;
}

/// 检查某方是否有合法走法
bool hasLegalMoves(PieceSide side, List<List<PieceModel?>> board) {
  for (int r = 0; r < 10; r++) {
    for (int c = 0; c < 9; c++) {
      final p = board[r][c];
      if (p == null || p.side != side) continue;
      final moves = getValidMoves(piece: p, board: board);
      if (moves.isNotEmpty) return true;
    }
  }
  return false;
}
