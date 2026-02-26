import 'package:flutter_test/flutter_test.dart';
import 'package:junqi/models/piece_model.dart';
import 'package:junqi/core/move_validator.dart';

/// 创建空棋盘
List<List<PieceModel?>> emptyBoard() {
  return List.generate(10, (_) => List<PieceModel?>.filled(9, null));
}

/// 在棋盘上放置棋子
void place(List<List<PieceModel?>> board, PieceModel piece) {
  board[piece.row][piece.col] = piece;
}

void main() {
  group('马的合法走位 - 基础日字走法', () {
    test('棋盘中央的马应有8个合法走位', () {
      final board = emptyBoard();
      const horse = PieceModel(
        type: PieceType.horse,
        side: PieceSide.red,
        col: 4,
        row: 5,
      );
      place(board, horse);

      final moves = getHorseMoves(
        col: 4,
        row: 5,
        side: PieceSide.red,
        board: board,
      );

      expect(moves.length, 8);
      // 验证所有8个日字目标
      final expected = {
        (col: 3, row: 3),
        (col: 5, row: 3),
        (col: 3, row: 7),
        (col: 5, row: 7),
        (col: 2, row: 4),
        (col: 2, row: 6),
        (col: 6, row: 4),
        (col: 6, row: 6),
      };
      for (final m in moves) {
        expect(expected.contains((col: m.col, row: m.row)), isTrue,
            reason: '(${m.col}, ${m.row}) 应在预期走位中');
      }
    });

    test('左上角(0,0)的马只有2个合法走位', () {
      final board = emptyBoard();
      const horse = PieceModel(
        type: PieceType.horse,
        side: PieceSide.red,
        col: 0,
        row: 0,
      );
      place(board, horse);

      final moves = getHorseMoves(
        col: 0,
        row: 0,
        side: PieceSide.red,
        board: board,
      );

      expect(moves.length, 2);
      final moveSet = moves.map((m) => (m.col, m.row)).toSet();
      expect(moveSet.contains((1, 2)), isTrue);
      expect(moveSet.contains((2, 1)), isTrue);
    });

    test('右下角(8,9)的马只有2个合法走位', () {
      final board = emptyBoard();
      const horse = PieceModel(
        type: PieceType.horse,
        side: PieceSide.red,
        col: 8,
        row: 9,
      );
      place(board, horse);

      final moves = getHorseMoves(
        col: 8,
        row: 9,
        side: PieceSide.red,
        board: board,
      );

      expect(moves.length, 2);
      final moveSet = moves.map((m) => (m.col, m.row)).toSet();
      expect(moveSet.contains((7, 7)), isTrue);
      expect(moveSet.contains((6, 8)), isTrue);
    });

    test('边缘位置(0,5)的马应有4个合法走位', () {
      final board = emptyBoard();
      const horse = PieceModel(
        type: PieceType.horse,
        side: PieceSide.red,
        col: 0,
        row: 5,
      );
      place(board, horse);

      final moves = getHorseMoves(
        col: 0,
        row: 5,
        side: PieceSide.red,
        board: board,
      );

      expect(moves.length, 4);
      final moveSet = moves.map((m) => (m.col, m.row)).toSet();
      expect(moveSet.contains((1, 3)), isTrue);
      expect(moveSet.contains((1, 7)), isTrue);
      expect(moveSet.contains((2, 4)), isTrue);
      expect(moveSet.contains((2, 6)), isTrue);
    });
  });

  group('马的合法走位 - 别马腿', () {
    test('上方被别腿，应阻挡向上的两个目标', () {
      final board = emptyBoard();
      const horse = PieceModel(
        type: PieceType.horse,
        side: PieceSide.red,
        col: 4,
        row: 5,
      );
      // 在马的正上方放一个棋子别腿
      const blocker = PieceModel(
        type: PieceType.soldier,
        side: PieceSide.black,
        col: 4,
        row: 4,
      );
      place(board, horse);
      place(board, blocker);

      final moves = getHorseMoves(
        col: 4,
        row: 5,
        side: PieceSide.red,
        board: board,
      );

      // 上方两个目标 (3,3) 和 (5,3) 被别掉，剩余6个
      expect(moves.length, 6);
      final moveSet = moves.map((m) => (m.col, m.row)).toSet();
      expect(moveSet.contains((3, 3)), isFalse, reason: '上方被别腿，不应走到(3,3)');
      expect(moveSet.contains((5, 3)), isFalse, reason: '上方被别腿，不应走到(5,3)');
    });

    test('下方被别腿，应阻挡向下的两个目标', () {
      final board = emptyBoard();
      const horse = PieceModel(
        type: PieceType.horse,
        side: PieceSide.red,
        col: 4,
        row: 5,
      );
      const blocker = PieceModel(
        type: PieceType.soldier,
        side: PieceSide.red,
        col: 4,
        row: 6,
      );
      place(board, horse);
      place(board, blocker);

      final moves = getHorseMoves(
        col: 4,
        row: 5,
        side: PieceSide.red,
        board: board,
      );

      expect(moves.length, 6);
      final moveSet = moves.map((m) => (m.col, m.row)).toSet();
      expect(moveSet.contains((3, 7)), isFalse);
      expect(moveSet.contains((5, 7)), isFalse);
    });

    test('左方被别腿，应阻挡向左的两个目标', () {
      final board = emptyBoard();
      const horse = PieceModel(
        type: PieceType.horse,
        side: PieceSide.red,
        col: 4,
        row: 5,
      );
      const blocker = PieceModel(
        type: PieceType.cannon,
        side: PieceSide.black,
        col: 3,
        row: 5,
      );
      place(board, horse);
      place(board, blocker);

      final moves = getHorseMoves(
        col: 4,
        row: 5,
        side: PieceSide.red,
        board: board,
      );

      expect(moves.length, 6);
      final moveSet = moves.map((m) => (m.col, m.row)).toSet();
      expect(moveSet.contains((2, 4)), isFalse);
      expect(moveSet.contains((2, 6)), isFalse);
    });

    test('右方被别腿，应阻挡向右的两个目标', () {
      final board = emptyBoard();
      const horse = PieceModel(
        type: PieceType.horse,
        side: PieceSide.red,
        col: 4,
        row: 5,
      );
      const blocker = PieceModel(
        type: PieceType.chariot,
        side: PieceSide.red,
        col: 5,
        row: 5,
      );
      place(board, horse);
      place(board, blocker);

      final moves = getHorseMoves(
        col: 4,
        row: 5,
        side: PieceSide.red,
        board: board,
      );

      expect(moves.length, 6);
      final moveSet = moves.map((m) => (m.col, m.row)).toSet();
      expect(moveSet.contains((6, 4)), isFalse);
      expect(moveSet.contains((6, 6)), isFalse);
    });

    test('四面全被别腿，马无路可走', () {
      final board = emptyBoard();
      const horse = PieceModel(
        type: PieceType.horse,
        side: PieceSide.red,
        col: 4,
        row: 5,
      );
      place(board, horse);
      // 四个方向各放一个棋子
      place(board, const PieceModel(type: PieceType.soldier, side: PieceSide.red, col: 4, row: 4));
      place(board, const PieceModel(type: PieceType.soldier, side: PieceSide.red, col: 4, row: 6));
      place(board, const PieceModel(type: PieceType.soldier, side: PieceSide.red, col: 3, row: 5));
      place(board, const PieceModel(type: PieceType.soldier, side: PieceSide.red, col: 5, row: 5));

      final moves = getHorseMoves(
        col: 4,
        row: 5,
        side: PieceSide.red,
        board: board,
      );

      expect(moves.length, 0, reason: '四面被别，马应无路可走');
    });

    test('己方棋子别腿和对方棋子别腿效果相同', () {
      final board = emptyBoard();
      const horse = PieceModel(
        type: PieceType.horse,
        side: PieceSide.red,
        col: 4,
        row: 5,
      );
      place(board, horse);
      // 用己方棋子别上方
      place(board, const PieceModel(type: PieceType.soldier, side: PieceSide.red, col: 4, row: 4));

      final movesWithFriendly = getHorseMoves(
        col: 4, row: 5, side: PieceSide.red, board: board,
      );

      // 替换为对方棋子
      board[4][4] = const PieceModel(type: PieceType.soldier, side: PieceSide.black, col: 4, row: 4);

      final movesWithEnemy = getHorseMoves(
        col: 4, row: 5, side: PieceSide.red, board: board,
      );

      expect(movesWithFriendly.length, movesWithEnemy.length,
          reason: '己方/对方棋子别腿效果应相同');
    });
  });

  group('马的合法走位 - 吃子逻辑', () {
    test('目标位置有对方棋子可以吃', () {
      final board = emptyBoard();
      const horse = PieceModel(
        type: PieceType.horse,
        side: PieceSide.red,
        col: 4,
        row: 5,
      );
      const enemy = PieceModel(
        type: PieceType.cannon,
        side: PieceSide.black,
        col: 3,
        row: 3,
      );
      place(board, horse);
      place(board, enemy);

      final moves = getHorseMoves(
        col: 4,
        row: 5,
        side: PieceSide.red,
        board: board,
      );

      final moveSet = moves.map((m) => (m.col, m.row)).toSet();
      expect(moveSet.contains((3, 3)), isTrue, reason: '应可以吃对方棋子');
    });

    test('目标位置有己方棋子不能走', () {
      final board = emptyBoard();
      const horse = PieceModel(
        type: PieceType.horse,
        side: PieceSide.red,
        col: 4,
        row: 5,
      );
      const friendly = PieceModel(
        type: PieceType.cannon,
        side: PieceSide.red,
        col: 3,
        row: 3,
      );
      place(board, horse);
      place(board, friendly);

      final moves = getHorseMoves(
        col: 4,
        row: 5,
        side: PieceSide.red,
        board: board,
      );

      final moveSet = moves.map((m) => (m.col, m.row)).toSet();
      expect(moveSet.contains((3, 3)), isFalse, reason: '不能吃己方棋子');
      expect(moves.length, 7, reason: '8个目标中有1个被己方棋子占据');
    });
  });

  group('马的合法走位 - 使用 buildBoard 辅助函数', () {
    test('buildBoard 正确构建棋盘', () {
      final pieces = [
        const PieceModel(type: PieceType.horse, side: PieceSide.red, col: 1, row: 9),
        const PieceModel(type: PieceType.chariot, side: PieceSide.red, col: 0, row: 9),
      ];
      final board = buildBoard(pieces);

      expect(board[9][1]?.type, PieceType.horse);
      expect(board[9][0]?.type, PieceType.chariot);
      expect(board[0][0], isNull);
    });

    test('初始局面红方左马的合法走位', () {
      // 初始局面: 红马在 (1,9)，马腿上方 (1,8) 无棋子，左方 (0,9) 有车
      final pieces = [
        const PieceModel(type: PieceType.chariot, side: PieceSide.red, col: 0, row: 9),
        const PieceModel(type: PieceType.horse, side: PieceSide.red, col: 1, row: 9),
        const PieceModel(type: PieceType.elephant, side: PieceSide.red, col: 2, row: 9),
      ];
      final board = buildBoard(pieces);

      final moves = getHorseMoves(
        col: 1,
        row: 9,
        side: PieceSide.red,
        board: board,
      );

      // 左方(0,9)有车别腿 → 不能走(-1,8)和(-1,10)（越界）
      // 右方(2,9)有象别腿 → 不能走(3,8)和(3,10)（10越界）
      // 上方(1,8)空 → 可走(0,7)和(2,7)
      // 下方(1,10)越界
      expect(moves.length, 2);
      final moveSet = moves.map((m) => (m.col, m.row)).toSet();
      expect(moveSet.contains((0, 7)), isTrue);
      expect(moveSet.contains((2, 7)), isTrue);
    });
  });
}
