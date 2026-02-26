import 'package:flutter_test/flutter_test.dart';
import 'package:junqi/models/piece_model.dart';
import 'package:junqi/core/move_validator.dart';

void main() {
  group('相/象 (Elephant) 走法测试', () {
    test('红相在中央可走4步', () {
      final pieces = [
        const PieceModel(id: 'p1', type: PieceType.elephant, side: PieceSide.red, col: 4, row: 7),
      ];
      final board = buildBoard(pieces);
      final moves = getElephantMoves(col: 4, row: 7, side: PieceSide.red, board: board);

      expect(moves.length, 4);
      expect(moves, containsAll([
        (col: 2, row: 5),
        (col: 6, row: 5),
        (col: 2, row: 9),
        (col: 6, row: 9),
      ]));
    });

    test('红相不可过河', () {
      final pieces = [
        const PieceModel(id: 'p1', type: PieceType.elephant, side: PieceSide.red, col: 2, row: 5),
      ];
      final board = buildBoard(pieces);
      final moves = getElephantMoves(col: 2, row: 5, side: PieceSide.red, board: board);

      // 所有走法都在红方半场 (row >= 5)
      for (final m in moves) {
        expect(m.row, greaterThanOrEqualTo(5));
      }
    });

    test('黑象不可过河', () {
      final pieces = [
        const PieceModel(id: 'p1', type: PieceType.elephant, side: PieceSide.black, col: 2, row: 4),
      ];
      final board = buildBoard(pieces);
      final moves = getElephantMoves(col: 2, row: 4, side: PieceSide.black, board: board);

      for (final m in moves) {
        expect(m.row, lessThanOrEqualTo(4));
      }
    });

    test('象眼被阻塞不可走', () {
      final pieces = [
        const PieceModel(id: 'p1', type: PieceType.elephant, side: PieceSide.red, col: 4, row: 7),
        // 阻塞左上象眼
        const PieceModel(id: 'p2', type: PieceType.soldier, side: PieceSide.red, col: 3, row: 6),
        // 阻塞右上象眼
        const PieceModel(id: 'p3', type: PieceType.soldier, side: PieceSide.red, col: 5, row: 6),
      ];
      final board = buildBoard(pieces);
      final moves = getElephantMoves(col: 4, row: 7, side: PieceSide.red, board: board);

      // 上面两个方向被阻塞，只剩下面2个
      expect(moves.length, 2);
      expect(moves, containsAll([
        (col: 2, row: 9),
        (col: 6, row: 9),
      ]));
    });

    test('全部象眼被阻塞时无走法', () {
      final pieces = [
        const PieceModel(id: 'p1', type: PieceType.elephant, side: PieceSide.red, col: 4, row: 7),
        const PieceModel(id: 'p2', type: PieceType.soldier, side: PieceSide.red, col: 3, row: 6),
        const PieceModel(id: 'p3', type: PieceType.soldier, side: PieceSide.red, col: 5, row: 6),
        const PieceModel(id: 'p4', type: PieceType.soldier, side: PieceSide.red, col: 3, row: 8),
        const PieceModel(id: 'p5', type: PieceType.soldier, side: PieceSide.red, col: 5, row: 8),
      ];
      final board = buildBoard(pieces);
      final moves = getElephantMoves(col: 4, row: 7, side: PieceSide.red, board: board);

      expect(moves.isEmpty, true);
    });

    test('象可吃敌方棋子', () {
      final pieces = [
        const PieceModel(id: 'p1', type: PieceType.elephant, side: PieceSide.red, col: 4, row: 7),
        const PieceModel(id: 'p2', type: PieceType.soldier, side: PieceSide.black, col: 2, row: 5),
      ];
      final board = buildBoard(pieces);
      final moves = getElephantMoves(col: 4, row: 7, side: PieceSide.red, board: board);

      expect(moves.any((m) => m.col == 2 && m.row == 5), true);
    });
  });
}
