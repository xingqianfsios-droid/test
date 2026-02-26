import 'package:flutter_test/flutter_test.dart';
import 'package:junqi/models/piece_model.dart';
import 'package:junqi/core/move_validator.dart';

void main() {
  group('车 (Chariot) 走法测试', () {
    test('空棋盘中央车可走17步', () {
      // (4,4) 中央：上4下5左4右4 = 17步
      final pieces = [
        const PieceModel(type: PieceType.chariot, side: PieceSide.red, col: 4, row: 4),
      ];
      final board = buildBoard(pieces);
      final moves = getChariotMoves(col: 4, row: 4, side: PieceSide.red, board: board);

      expect(moves.length, 17);
    });

    test('车在角落可走17步', () {
      // (0,0) 角落：上0下9左0右8 = 17步
      final pieces = [
        const PieceModel(type: PieceType.chariot, side: PieceSide.red, col: 0, row: 0),
      ];
      final board = buildBoard(pieces);
      final moves = getChariotMoves(col: 0, row: 0, side: PieceSide.red, board: board);

      expect(moves.length, 17);
    });

    test('车遇己方棋子阻塞', () {
      final pieces = [
        const PieceModel(type: PieceType.chariot, side: PieceSide.red, col: 4, row: 4),
        const PieceModel(type: PieceType.soldier, side: PieceSide.red, col: 4, row: 2), // 上方阻塞
      ];
      final board = buildBoard(pieces);
      final moves = getChariotMoves(col: 4, row: 4, side: PieceSide.red, board: board);

      // 上方只能到 row 3（不能到 row 2 及以上）
      expect(moves.any((m) => m.col == 4 && m.row == 3), true);
      expect(moves.any((m) => m.col == 4 && m.row == 2), false);
      expect(moves.any((m) => m.col == 4 && m.row == 1), false);
    });

    test('车可吃敌方棋子', () {
      final pieces = [
        const PieceModel(type: PieceType.chariot, side: PieceSide.red, col: 4, row: 4),
        const PieceModel(type: PieceType.soldier, side: PieceSide.black, col: 4, row: 2),
      ];
      final board = buildBoard(pieces);
      final moves = getChariotMoves(col: 4, row: 4, side: PieceSide.red, board: board);

      // 可以吃到 (4,2) 的敌方卒
      expect(moves.any((m) => m.col == 4 && m.row == 2), true);
      // 但不能继续前进
      expect(moves.any((m) => m.col == 4 && m.row == 1), false);
    });

    test('车被两侧己方棋子夹住', () {
      final pieces = [
        const PieceModel(type: PieceType.chariot, side: PieceSide.red, col: 4, row: 4),
        const PieceModel(type: PieceType.soldier, side: PieceSide.red, col: 3, row: 4), // 左
        const PieceModel(type: PieceType.soldier, side: PieceSide.red, col: 5, row: 4), // 右
        const PieceModel(type: PieceType.soldier, side: PieceSide.red, col: 4, row: 3), // 上
        const PieceModel(type: PieceType.soldier, side: PieceSide.red, col: 4, row: 5), // 下
      ];
      final board = buildBoard(pieces);
      final moves = getChariotMoves(col: 4, row: 4, side: PieceSide.red, board: board);

      expect(moves.isEmpty, true);
    });
  });
}
