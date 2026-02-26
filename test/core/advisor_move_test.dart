import 'package:flutter_test/flutter_test.dart';
import 'package:junqi/models/piece_model.dart';
import 'package:junqi/core/move_validator.dart';

void main() {
  group('仕/士 (Advisor) 走法测试', () {
    test('红仕在九宫中央可走4步', () {
      final pieces = [
        const PieceModel(type: PieceType.advisor, side: PieceSide.red, col: 4, row: 8),
      ];
      final board = buildBoard(pieces);
      final moves = getAdvisorMoves(col: 4, row: 8, side: PieceSide.red, board: board);

      expect(moves.length, 4);
      expect(moves, containsAll([
        (col: 3, row: 7),
        (col: 5, row: 7),
        (col: 3, row: 9),
        (col: 5, row: 9),
      ]));
    });

    test('红仕在角落只能走1步', () {
      final pieces = [
        const PieceModel(type: PieceType.advisor, side: PieceSide.red, col: 3, row: 7),
      ];
      final board = buildBoard(pieces);
      final moves = getAdvisorMoves(col: 3, row: 7, side: PieceSide.red, board: board);

      expect(moves.length, 1);
      expect(moves, contains((col: 4, row: 8)));
    });

    test('黑士在九宫中央可走4步', () {
      final pieces = [
        const PieceModel(type: PieceType.advisor, side: PieceSide.black, col: 4, row: 1),
      ];
      final board = buildBoard(pieces);
      final moves = getAdvisorMoves(col: 4, row: 1, side: PieceSide.black, board: board);

      expect(moves.length, 4);
    });

    test('仕不可走出九宫', () {
      final pieces = [
        const PieceModel(type: PieceType.advisor, side: PieceSide.red, col: 5, row: 9),
      ];
      final board = buildBoard(pieces);
      final moves = getAdvisorMoves(col: 5, row: 9, side: PieceSide.red, board: board);

      for (final m in moves) {
        expect(m.col, inInclusiveRange(3, 5));
        expect(m.row, inInclusiveRange(7, 9));
      }
    });

    test('仕不可吃己方棋子', () {
      final pieces = [
        const PieceModel(type: PieceType.advisor, side: PieceSide.red, col: 4, row: 8),
        const PieceModel(type: PieceType.king, side: PieceSide.red, col: 3, row: 7),
      ];
      final board = buildBoard(pieces);
      final moves = getAdvisorMoves(col: 4, row: 8, side: PieceSide.red, board: board);

      expect(moves.any((m) => m.col == 3 && m.row == 7), false);
    });

    test('仕可吃敌方棋子', () {
      final pieces = [
        const PieceModel(type: PieceType.advisor, side: PieceSide.red, col: 4, row: 8),
        const PieceModel(type: PieceType.soldier, side: PieceSide.black, col: 3, row: 7),
      ];
      final board = buildBoard(pieces);
      final moves = getAdvisorMoves(col: 4, row: 8, side: PieceSide.red, board: board);

      expect(moves.any((m) => m.col == 3 && m.row == 7), true);
    });
  });
}
