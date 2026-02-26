import 'package:flutter/material.dart';

/// 合法走位提示指示器
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
      // 可吃子：空心圆环
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.green.withValues(alpha: 0.7),
            width: 2.5,
          ),
        ),
      );
    } else {
      // 空位可走：小圆点
      return Container(
        width: size * 0.35,
        height: size * 0.35,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.green.withValues(alpha: 0.5),
        ),
      );
    }
  }
}
