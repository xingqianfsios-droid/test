import 'piece_model.dart';

/// 棋盘初始布局
List<PieceModel> initialPieces() {
  return [
    // === 黑方 (top, row 0-4) ===
    // 车 马 象 士 将 士 象 马 车
    const PieceModel(id: 'b_chariot_l', type: PieceType.chariot, side: PieceSide.black, col: 0, row: 0),
    const PieceModel(id: 'b_horse_l', type: PieceType.horse, side: PieceSide.black, col: 1, row: 0),
    const PieceModel(id: 'b_elephant_l', type: PieceType.elephant, side: PieceSide.black, col: 2, row: 0),
    const PieceModel(id: 'b_advisor_l', type: PieceType.advisor, side: PieceSide.black, col: 3, row: 0),
    const PieceModel(id: 'b_king', type: PieceType.king, side: PieceSide.black, col: 4, row: 0),
    const PieceModel(id: 'b_advisor_r', type: PieceType.advisor, side: PieceSide.black, col: 5, row: 0),
    const PieceModel(id: 'b_elephant_r', type: PieceType.elephant, side: PieceSide.black, col: 6, row: 0),
    const PieceModel(id: 'b_horse_r', type: PieceType.horse, side: PieceSide.black, col: 7, row: 0),
    const PieceModel(id: 'b_chariot_r', type: PieceType.chariot, side: PieceSide.black, col: 8, row: 0),
    // 炮
    const PieceModel(id: 'b_cannon_l', type: PieceType.cannon, side: PieceSide.black, col: 1, row: 2),
    const PieceModel(id: 'b_cannon_r', type: PieceType.cannon, side: PieceSide.black, col: 7, row: 2),
    // 卒
    const PieceModel(id: 'b_soldier_1', type: PieceType.soldier, side: PieceSide.black, col: 0, row: 3),
    const PieceModel(id: 'b_soldier_2', type: PieceType.soldier, side: PieceSide.black, col: 2, row: 3),
    const PieceModel(id: 'b_soldier_3', type: PieceType.soldier, side: PieceSide.black, col: 4, row: 3),
    const PieceModel(id: 'b_soldier_4', type: PieceType.soldier, side: PieceSide.black, col: 6, row: 3),
    const PieceModel(id: 'b_soldier_5', type: PieceType.soldier, side: PieceSide.black, col: 8, row: 3),

    // === 红方 (bottom, row 5-9) ===
    // 兵
    const PieceModel(id: 'r_soldier_1', type: PieceType.soldier, side: PieceSide.red, col: 0, row: 6),
    const PieceModel(id: 'r_soldier_2', type: PieceType.soldier, side: PieceSide.red, col: 2, row: 6),
    const PieceModel(id: 'r_soldier_3', type: PieceType.soldier, side: PieceSide.red, col: 4, row: 6),
    const PieceModel(id: 'r_soldier_4', type: PieceType.soldier, side: PieceSide.red, col: 6, row: 6),
    const PieceModel(id: 'r_soldier_5', type: PieceType.soldier, side: PieceSide.red, col: 8, row: 6),
    // 炮
    const PieceModel(id: 'r_cannon_l', type: PieceType.cannon, side: PieceSide.red, col: 1, row: 7),
    const PieceModel(id: 'r_cannon_r', type: PieceType.cannon, side: PieceSide.red, col: 7, row: 7),
    // 车 马 相 仕 帅 仕 相 马 车
    const PieceModel(id: 'r_chariot_l', type: PieceType.chariot, side: PieceSide.red, col: 0, row: 9),
    const PieceModel(id: 'r_horse_l', type: PieceType.horse, side: PieceSide.red, col: 1, row: 9),
    const PieceModel(id: 'r_elephant_l', type: PieceType.elephant, side: PieceSide.red, col: 2, row: 9),
    const PieceModel(id: 'r_advisor_l', type: PieceType.advisor, side: PieceSide.red, col: 3, row: 9),
    const PieceModel(id: 'r_king', type: PieceType.king, side: PieceSide.red, col: 4, row: 9),
    const PieceModel(id: 'r_advisor_r', type: PieceType.advisor, side: PieceSide.red, col: 5, row: 9),
    const PieceModel(id: 'r_elephant_r', type: PieceType.elephant, side: PieceSide.red, col: 6, row: 9),
    const PieceModel(id: 'r_horse_r', type: PieceType.horse, side: PieceSide.red, col: 7, row: 9),
    const PieceModel(id: 'r_chariot_r', type: PieceType.chariot, side: PieceSide.red, col: 8, row: 9),
  ];
}
