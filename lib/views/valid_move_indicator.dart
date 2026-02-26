import 'package:flutter/material.dart';

/// 合法走位提示指示器 — 水墨风格
class ValidMoveIndicator extends StatelessWidget {
  /// 小圆点（空位可走）还是空心圆环（可吃子）
  final bool isCapture;
  final double size;

  const ValidMoveIndicator({
    super.key,
    required this.isCapture,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (isCapture) {
      // 可吃子：深色虚环
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF8B6914).withValues(alpha: 0.7),
            width: 2.5,
          ),
        ),
      );
    } else {
      // 空位可走：墨色小圆点
      return Container(
        width: size * 0.3,
        height: size * 0.3,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF3C2415).withValues(alpha: 0.45),
        ),
      );
    }
  }
}
