import 'package:flutter_test/flutter_test.dart';
import 'package:junqi/models/piece_model.dart';
import 'package:junqi/core/move_validator.dart';

void main() {
  group('帅/将 (King) 走法测试', () {
    test('红帅在九宫中央可走4步', () {
      final pieces = [
        const PieceModel(type: PieceType.king, side: PieceSide.red, col: 4, row: 8),
      ];
      final board = buildBoard(pieces);
      final moves = getKingMoves(col: 4, row: 8, side: PieceSide.red, board: board);

      expect(moves.length, 4);
      expect(moves, containsAll([
        (col: 3, row: 8),
        (col: 5, row: 8),
        (col: 4, row: 7),
        (col: 4, row: 9),
      ]));
    });

    test('红帅在左下角只能走2步', () {
      final pieces = [
        const PieceModel(type: PieceType.king, side: PieceSide.red, col: 3, row: 9),
      ];
      final board = buildBoard(pieces);
      final moves = getKingMoves(col: 3, row: 9, side: PieceSide.red, board: board);

      expect(moves.length, 2);
      expect(moves, containsAll([
        (col: 4, row: 9),
        (col: 3, row: 8),
      ]));
    });

    test('黑将在九宫中央可走4步', () {
      final pieces = [
        const PieceModel(type: PieceType.king, side: PieceSide.black, col: 4, row: 1),
      ];
      final board = buildBoard(pieces);
      final moves = getKingMoves(col: 4, row: 1, side: PieceSide.black, board: board);

      expect(moves.length, 4);
      expect(moves, containsAll([
        (col: 3, row: 1),
        (col: 5, row: 1),
        (col: 4, row: 0),
        (col: 4, row: 2),
      ]));
    });

    test('帅不可走出九宫', () {
      final pieces = [
        const PieceModel(type: PieceType.king, side: PieceSide.red, col: 5, row: 7),
      ];
      final board = buildBoard(pieces);
      final moves = getKingMoves(col: 5, row: 7, side: PieceSide.red, board: board);

      // 不能走到 col=6
      for (final m in moves) {
        expect(m.col, inInclusiveRange(3, 5));
        expect(m.row, inInclusiveRange(7, 9));
      }
    });

    test('帅不可吃己方棋子', () {
      final pieces = [
        const PieceModel(type: PieceType.king, side: PieceSide.red, col: 4, row: 8),
        const PieceModel(type: PieceType.advisor, side: PieceSide.red, col: 4, row: 7),
      ];
      final board = buildBoard(pieces);
      final moves = getKingMoves(col: 4, row: 8, side: PieceSide.red, board: board);

      expect(moves.any((m) => m.col == 4 && m.row == 7), false);
    });

    test('帅可吃敌方棋子', () {
      final pieces = [
        const PieceModel(type: PieceType.king, side: PieceSide.red, col: 4, row: 8),
        const PieceModel(type: PieceType.soldier, side: PieceSide.black, col: 4, row: 7),
      ];
      final board = buildBoard(pieces);
      final moves = getKingMoves(col: 4, row: 8, side: PieceSide.red, board: board);

      expect(moves.any((m) => m.col == 4 && m.row == 7), true);
    });
  });

  group('将帅对面检测', () {
    test('将帅同列且中间无棋子时 getValidMoves 过滤送将走法', () {
      // 红帅在 (4,9)，黑将在 (4,0)，中间无棋子
      // 红方仕在 (4,8)，如果移走仕则将帅对面
      final pieces = [
        const PieceModel(type: PieceType.king, side: PieceSide.red, col: 4, row: 9),
        const PieceModel(type: PieceType.king, side: PieceSide.black, col: 4, row: 0),
        const PieceModel(type: PieceType.advisor, side: PieceSide.red, col: 4, row: 8),
      ];
      final board = buildBoard(pieces);
      final advisor = pieces[2];
      final moves = getValidMoves(piece: advisor, board: board);

      // 仕不能离开 col=4（否则将帅对面），所以无合法走法
      expect(moves.isEmpty, true);
    });
  });
}
