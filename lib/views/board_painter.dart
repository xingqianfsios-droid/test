import 'package:flutter/material.dart';

/// 象棋棋盘绘制器
class BoardPainter extends CustomPainter {
  /// 格子大小（由外部传入）
  final double cellSize;

  /// 棋盘左上角偏移
  final double offsetX;
  final double offsetY;

  BoardPainter({
    required this.cellSize,
    required this.offsetX,
    required this.offsetY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawGrid(canvas);
    _drawPalaceDiagonals(canvas);
    _drawRiverText(canvas);
  }

  void _drawBackground(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFDEB887);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  void _drawGrid(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // 10条横线
    for (int r = 0; r < 10; r++) {
      final y = offsetY + r * cellSize;
      canvas.drawLine(
        Offset(offsetX, y),
        Offset(offsetX + 8 * cellSize, y),
        paint,
      );
    }

    // 左右两条完整竖线
    for (int c in [0, 8]) {
      final x = offsetX + c * cellSize;
      canvas.drawLine(
        Offset(x, offsetY),
        Offset(x, offsetY + 9 * cellSize),
        paint,
      );
    }

    // 中间竖线在河界处断开
    for (int c = 1; c <= 7; c++) {
      final x = offsetX + c * cellSize;
      // 上半部分 (row 0 到 row 4)
      canvas.drawLine(
        Offset(x, offsetY),
        Offset(x, offsetY + 4 * cellSize),
        paint,
      );
      // 下半部分 (row 5 到 row 9)
      canvas.drawLine(
        Offset(x, offsetY + 5 * cellSize),
        Offset(x, offsetY + 9 * cellSize),
        paint,
      );
    }
  }

  void _drawPalaceDiagonals(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // 黑方九宫 (col 3-5, row 0-2)
    canvas.drawLine(
      Offset(offsetX + 3 * cellSize, offsetY),
      Offset(offsetX + 5 * cellSize, offsetY + 2 * cellSize),
      paint,
    );
    canvas.drawLine(
      Offset(offsetX + 5 * cellSize, offsetY),
      Offset(offsetX + 3 * cellSize, offsetY + 2 * cellSize),
      paint,
    );

    // 红方九宫 (col 3-5, row 7-9)
    canvas.drawLine(
      Offset(offsetX + 3 * cellSize, offsetY + 7 * cellSize),
      Offset(offsetX + 5 * cellSize, offsetY + 9 * cellSize),
      paint,
    );
    canvas.drawLine(
      Offset(offsetX + 5 * cellSize, offsetY + 7 * cellSize),
      Offset(offsetX + 3 * cellSize, offsetY + 9 * cellSize),
      paint,
    );
  }

  void _drawRiverText(Canvas canvas) {
    final textStyle = TextStyle(
      fontSize: cellSize * 0.55,
      color: Colors.black54,
      fontWeight: FontWeight.bold,
    );

    // "楚河" 在左侧
    final chuHePainter = TextPainter(
      text: TextSpan(text: '楚  河', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    chuHePainter.paint(
      canvas,
      Offset(
        offsetX + 1 * cellSize - chuHePainter.width / 2,
        offsetY + 4.5 * cellSize - chuHePainter.height / 2,
      ),
    );

    // "汉界" 在右侧
    final hanJiePainter = TextPainter(
      text: TextSpan(text: '汉  界', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    hanJiePainter.paint(
      canvas,
      Offset(
        offsetX + 7 * cellSize - hanJiePainter.width / 2,
        offsetY + 4.5 * cellSize - hanJiePainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) {
    return oldDelegate.cellSize != cellSize ||
        oldDelegate.offsetX != offsetX ||
        oldDelegate.offsetY != offsetY;
  }
}

/// 网格坐标转像素坐标
Offset gridToPixel(int col, int row, double cellSize, double offsetX, double offsetY) {
  return Offset(offsetX + col * cellSize, offsetY + row * cellSize);
}

/// 像素坐标转网格坐标（四舍五入到最近的交叉点）
({int col, int row})? pixelToGrid(
  double x,
  double y,
  double cellSize,
  double offsetX,
  double offsetY,
) {
  final col = ((x - offsetX) / cellSize).round();
  final row = ((y - offsetY) / cellSize).round();
  if (col < 0 || col > 8 || row < 0 || row > 9) return null;

  // 检查是否足够接近交叉点
  final px = offsetX + col * cellSize;
  final py = offsetY + row * cellSize;
  final dist = (x - px) * (x - px) + (y - py) * (y - py);
  if (dist > cellSize * cellSize * 0.4) return null;

  return (col: col, row: row);
}
