import 'piece_model.dart';

/// 棋盘初始布局
List<PieceModel> initialPieces() {
  return [
    // === 黑方 (top, row 0-4) ===
    // 车 马 象 士 将 士 象 马 车
    const PieceModel(type: PieceType.chariot, side: PieceSide.black, col: 0, row: 0),
    const PieceModel(type: PieceType.horse, side: PieceSide.black, col: 1, row: 0),
    const PieceModel(type: PieceType.elephant, side: PieceSide.black, col: 2, row: 0),
    const PieceModel(type: PieceType.advisor, side: PieceSide.black, col: 3, row: 0),
    const PieceModel(type: PieceType.king, side: PieceSide.black, col: 4, row: 0),
    const PieceModel(type: PieceType.advisor, side: PieceSide.black, col: 5, row: 0),
    const PieceModel(type: PieceType.elephant, side: PieceSide.black, col: 6, row: 0),
    const PieceModel(type: PieceType.horse, side: PieceSide.black, col: 7, row: 0),
    const PieceModel(type: PieceType.chariot, side: PieceSide.black, col: 8, row: 0),
    // 炮
    const PieceModel(type: PieceType.cannon, side: PieceSide.black, col: 1, row: 2),
    const PieceModel(type: PieceType.cannon, side: PieceSide.black, col: 7, row: 2),
    // 卒
    const PieceModel(type: PieceType.soldier, side: PieceSide.black, col: 0, row: 3),
    const PieceModel(type: PieceType.soldier, side: PieceSide.black, col: 2, row: 3),
    const PieceModel(type: PieceType.soldier, side: PieceSide.black, col: 4, row: 3),
    const PieceModel(type: PieceType.soldier, side: PieceSide.black, col: 6, row: 3),
    const PieceModel(type: PieceType.soldier, side: PieceSide.black, col: 8, row: 3),

    // === 红方 (bottom, row 5-9) ===
    // 兵
    const PieceModel(type: PieceType.soldier, side: PieceSide.red, col: 0, row: 6),
    const PieceModel(type: PieceType.soldier, side: PieceSide.red, col: 2, row: 6),
    const PieceModel(type: PieceType.soldier, side: PieceSide.red, col: 4, row: 6),
    const PieceModel(type: PieceType.soldier, side: PieceSide.red, col: 6, row: 6),
    const PieceModel(type: PieceType.soldier, side: PieceSide.red, col: 8, row: 6),
    // 炮
    const PieceModel(type: PieceType.cannon, side: PieceSide.red, col: 1, row: 7),
    const PieceModel(type: PieceType.cannon, side: PieceSide.red, col: 7, row: 7),
    // 车 马 相 仕 帅 仕 相 马 车
    const PieceModel(type: PieceType.chariot, side: PieceSide.red, col: 0, row: 9),
    const PieceModel(type: PieceType.horse, side: PieceSide.red, col: 1, row: 9),
    const PieceModel(type: PieceType.elephant, side: PieceSide.red, col: 2, row: 9),
    const PieceModel(type: PieceType.advisor, side: PieceSide.red, col: 3, row: 9),
    const PieceModel(type: PieceType.king, side: PieceSide.red, col: 4, row: 9),
    const PieceModel(type: PieceType.advisor, side: PieceSide.red, col: 5, row: 9),
    const PieceModel(type: PieceType.elephant, side: PieceSide.red, col: 6, row: 9),
    const PieceModel(type: PieceType.horse, side: PieceSide.red, col: 7, row: 9),
    const PieceModel(type: PieceType.chariot, side: PieceSide.red, col: 8, row: 9),
  ];
}
