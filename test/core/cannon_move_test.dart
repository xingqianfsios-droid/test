import 'package:flutter_test/flutter_test.dart';
import 'package:junqi/models/piece_model.dart';
import 'package:junqi/core/move_validator.dart';

void main() {
  group('炮 (Cannon) 走法测试', () {
    test('空棋盘上炮移动同车', () {
      final pieces = [
        const PieceModel(type: PieceType.cannon, side: PieceSide.red, col: 4, row: 4),
      ];
      final board = buildBoard(pieces);
      final moves = getCannonMoves(col: 4, row: 4, side: PieceSide.red, board: board);

      // 和车一样 17 步
      expect(moves.length, 17);
    });

    test('炮不能直接吃相邻棋子', () {
      final pieces = [
        const PieceModel(type: PieceType.cannon, side: PieceSide.red, col: 4, row: 4),
        const PieceModel(type: PieceType.soldier, side: PieceSide.black, col: 4, row: 3), // 上方相邻
      ];
      final board = buildBoard(pieces);
      final moves = getCannonMoves(col: 4, row: 4, side: PieceSide.red, board: board);

      // 不能吃 (4,3) 因为中间没有炮架
      expect(moves.any((m) => m.col == 4 && m.row == 3), false);
    });

    test('炮翻山吃子', () {
      final pieces = [
        const PieceModel(type: PieceType.cannon, side: PieceSide.red, col: 4, row: 4),
        const PieceModel(type: PieceType.soldier, side: PieceSide.red, col: 4, row: 2), // 炮架
        const PieceModel(type: PieceType.soldier, side: PieceSide.black, col: 4, row: 0), // 可吃目标
      ];
      final board = buildBoard(pieces);
      final moves = getCannonMoves(col: 4, row: 4, side: PieceSide.red, board: board);

      // 可以吃 (4,0)
      expect(moves.any((m) => m.col == 4 && m.row == 0), true);
      // 不能移动到 (4,2) 因为有炮架
      expect(moves.any((m) => m.col == 4 && m.row == 2), false);
      // 不能移动到 (4,1) 因为在炮架后面
      expect(moves.any((m) => m.col == 4 && m.row == 1), false);
    });

    test('炮不能翻山吃己方棋子', () {
      final pieces = [
        const PieceModel(type: PieceType.cannon, side: PieceSide.red, col: 4, row: 4),
        const PieceModel(type: PieceType.soldier, side: PieceSide.red, col: 4, row: 2), // 炮架
        const PieceModel(type: PieceType.soldier, side: PieceSide.red, col: 4, row: 0), // 己方棋子
      ];
      final board = buildBoard(pieces);
      final moves = getCannonMoves(col: 4, row: 4, side: PieceSide.red, board: board);

      expect(moves.any((m) => m.col == 4 && m.row == 0), false);
    });

    test('炮两个炮架不能吃子', () {
      final pieces = [
        const PieceModel(type: PieceType.cannon, side: PieceSide.red, col: 4, row: 4),
        const PieceModel(type: PieceType.soldier, side: PieceSide.red, col: 4, row: 2), // 第一个炮架
        const PieceModel(type: PieceType.soldier, side: PieceSide.red, col: 4, row: 1), // 第二个炮架
        const PieceModel(type: PieceType.soldier, side: PieceSide.black, col: 4, row: 0), // 目标
      ];
      final board = buildBoard(pieces);
      final moves = getCannonMoves(col: 4, row: 4, side: PieceSide.red, board: board);

      // 两个炮架之间，不能吃 (4,0)
      expect(moves.any((m) => m.col == 4 && m.row == 0), false);
    });

    test('炮水平翻山吃子', () {
      final pieces = [
        const PieceModel(type: PieceType.cannon, side: PieceSide.red, col: 0, row: 4),
        const PieceModel(type: PieceType.soldier, side: PieceSide.red, col: 3, row: 4), // 炮架
        const PieceModel(type: PieceType.soldier, side: PieceSide.black, col: 6, row: 4), // 可吃
      ];
      final board = buildBoard(pieces);
      final moves = getCannonMoves(col: 0, row: 4, side: PieceSide.red, board: board);

      expect(moves.any((m) => m.col == 6 && m.row == 4), true);
      // 炮架和目标之间的空位不可走
      expect(moves.any((m) => m.col == 4 && m.row == 4), false);
      expect(moves.any((m) => m.col == 5 && m.row == 4), false);
    });
  });
}
