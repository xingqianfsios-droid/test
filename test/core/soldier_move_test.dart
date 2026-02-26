import 'package:flutter_test/flutter_test.dart';
import 'package:junqi/models/piece_model.dart';
import 'package:junqi/core/move_validator.dart';

void main() {
  group('兵/卒 (Soldier) 走法测试', () {
    test('红兵未过河只能前进(上)1步', () {
      final pieces = [
        const PieceModel(id: 'p1', type: PieceType.soldier, side: PieceSide.red, col: 4, row: 6),
      ];
      final board = buildBoard(pieces);
      final moves = getSoldierMoves(col: 4, row: 6, side: PieceSide.red, board: board);

      expect(moves.length, 1);
      expect(moves, contains((col: 4, row: 5)));
    });

    test('黑卒未过河只能前进(下)1步', () {
      final pieces = [
        const PieceModel(id: 'p1', type: PieceType.soldier, side: PieceSide.black, col: 4, row: 3),
      ];
      final board = buildBoard(pieces);
      final moves = getSoldierMoves(col: 4, row: 3, side: PieceSide.black, board: board);

      expect(moves.length, 1);
      expect(moves, contains((col: 4, row: 4)));
    });

    test('红兵过河后可前进和左右', () {
      // row <= 4 为过河
      final pieces = [
        const PieceModel(id: 'p1', type: PieceType.soldier, side: PieceSide.red, col: 4, row: 4),
      ];
      final board = buildBoard(pieces);
      final moves = getSoldierMoves(col: 4, row: 4, side: PieceSide.red, board: board);

      expect(moves.length, 3);
      expect(moves, containsAll([
        (col: 4, row: 3), // 前进
        (col: 3, row: 4), // 左
        (col: 5, row: 4), // 右
      ]));
    });

    test('黑卒过河后可前进和左右', () {
      // row >= 5 为过河
      final pieces = [
        const PieceModel(id: 'p1', type: PieceType.soldier, side: PieceSide.black, col: 4, row: 5),
      ];
      final board = buildBoard(pieces);
      final moves = getSoldierMoves(col: 4, row: 5, side: PieceSide.black, board: board);

      expect(moves.length, 3);
      expect(moves, containsAll([
        (col: 4, row: 6), // 前进
        (col: 3, row: 5), // 左
        (col: 5, row: 5), // 右
      ]));
    });

    test('红兵在左边界过河后只能前进和右走', () {
      final pieces = [
        const PieceModel(id: 'p1', type: PieceType.soldier, side: PieceSide.red, col: 0, row: 3),
      ];
      final board = buildBoard(pieces);
      final moves = getSoldierMoves(col: 0, row: 3, side: PieceSide.red, board: board);

      expect(moves.length, 2);
      expect(moves, containsAll([
        (col: 0, row: 2),
        (col: 1, row: 3),
      ]));
    });

    test('红兵在最顶行只能左右走', () {
      final pieces = [
        const PieceModel(id: 'p1', type: PieceType.soldier, side: PieceSide.red, col: 4, row: 0),
      ];
      final board = buildBoard(pieces);
      final moves = getSoldierMoves(col: 4, row: 0, side: PieceSide.red, board: board);

      expect(moves.length, 2);
      expect(moves, containsAll([
        (col: 3, row: 0),
        (col: 5, row: 0),
      ]));
    });

    test('兵可吃前方敌子', () {
      final pieces = [
        const PieceModel(id: 'p1', type: PieceType.soldier, side: PieceSide.red, col: 4, row: 6),
        const PieceModel(id: 'p2', type: PieceType.soldier, side: PieceSide.black, col: 4, row: 5),
      ];
      final board = buildBoard(pieces);
      final moves = getSoldierMoves(col: 4, row: 6, side: PieceSide.red, board: board);

      expect(moves.any((m) => m.col == 4 && m.row == 5), true);
    });

    test('兵不能吃前方己方棋子', () {
      final pieces = [
        const PieceModel(id: 'p1', type: PieceType.soldier, side: PieceSide.red, col: 4, row: 6),
        const PieceModel(id: 'p2', type: PieceType.soldier, side: PieceSide.red, col: 4, row: 5),
      ];
      final board = buildBoard(pieces);
      final moves = getSoldierMoves(col: 4, row: 6, side: PieceSide.red, board: board);

      expect(moves.isEmpty, true);
    });
  });
}
