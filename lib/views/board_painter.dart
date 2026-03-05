import 'package:flutter/material.dart';

/// 象棋棋盘绘制器 — 古风木纹风格
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
    _drawBorder(canvas, size);
    _drawGrid(canvas);
    _drawPalaceDiagonals(canvas);
    _drawStarPoints(canvas);
    _drawRiverText(canvas);
  }

  void _drawBackground(Canvas canvas, Size size) {
    // 木质底色
    final paint = Paint()..color = const Color(0xFFF5DEB3);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // 细微木纹纹理效果
    final grainPaint = Paint()
      ..color = const Color(0x0A6B3A1F)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    for (double y = 0; y < size.height; y += 3.5) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grainPaint);
    }
  }

  void _drawBorder(Canvas canvas, Size size) {
    // 外边框 — 深色粗框，模拟传统棋盘边框
    final borderPaint = Paint()
      ..color = const Color(0xFF3C2415)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    final borderRect = Rect.fromLTWH(
      offsetX - cellSize * 0.15,
      offsetY - cellSize * 0.15,
      8 * cellSize + cellSize * 0.3,
      9 * cellSize + cellSize * 0.3,
    );
    canvas.drawRect(borderRect, borderPaint);
  }

  void _drawGrid(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFF3C2415)
      ..strokeWidth = 1.2
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
      ..color = const Color(0xFF3C2415)
      ..strokeWidth = 1.2
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

  /// 绘制炮/兵位置的星位标记（十字花）
  void _drawStarPoints(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFF3C2415)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final d = cellSize * 0.12;
    final gap = cellSize * 0.04;

    // 炮位
    _drawStar(canvas, 1, 2, paint, d, gap);
    _drawStar(canvas, 7, 2, paint, d, gap);
    _drawStar(canvas, 1, 7, paint, d, gap);
    _drawStar(canvas, 7, 7, paint, d, gap);

    // 兵/卒位
    for (int c in [0, 2, 4, 6, 8]) {
      _drawStar(canvas, c, 3, paint, d, gap);
      _drawStar(canvas, c, 6, paint, d, gap);
    }
  }

  void _drawStar(Canvas canvas, int col, int row, Paint paint, double d, double gap) {
    final x = offsetX + col * cellSize;
    final y = offsetY + row * cellSize;

    // 四个角各画一个 L 形
    void drawCorner(double dx, double dy) {
      final sx = x + dx * gap;
      final sy = y + dy * gap;
      canvas.drawLine(Offset(sx, sy), Offset(sx + dx * d, sy), paint);
      canvas.drawLine(Offset(sx, sy), Offset(sx, sy + dy * d), paint);
    }

    // 左边不画左侧角（col == 0），右边不画右侧角（col == 8）
    if (col > 0) {
      drawCorner(-1, -1);
      drawCorner(-1, 1);
    }
    if (col < 8) {
      drawCorner(1, -1);
      drawCorner(1, 1);
    }
  }

  void _drawRiverText(Canvas canvas) {
    final textStyle = TextStyle(
      fontSize: cellSize * 0.5,
      color: const Color(0xFF6B3A1F),
      fontWeight: FontWeight.bold,
      letterSpacing: cellSize * 0.3,
    );

    // "楚河" 在左侧
    final chuHePainter = TextPainter(
      text: TextSpan(text: '楚河', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    chuHePainter.paint(
      canvas,
      Offset(
        offsetX + 1.5 * cellSize - chuHePainter.width / 2,
        offsetY + 4.5 * cellSize - chuHePainter.height / 2,
      ),
    );

    // "汉界" 在右侧
    final hanJiePainter = TextPainter(
      text: TextSpan(text: '汉界', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    hanJiePainter.paint(
      canvas,
      Offset(
        offsetX + 6.5 * cellSize - hanJiePainter.width / 2,
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
