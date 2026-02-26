import 'package:flutter/material.dart';
import '../models/piece_model.dart';

/// 获取棋子的中文名称
String getPieceName(PieceType type, PieceSide side) {
  const redNames = {
    PieceType.king: '帅',
    PieceType.advisor: '仕',
    PieceType.elephant: '相',
    PieceType.horse: '馬',
    PieceType.chariot: '車',
    PieceType.cannon: '炮',
    PieceType.soldier: '兵',
  };

  const blackNames = {
    PieceType.king: '将',
    PieceType.advisor: '士',
    PieceType.elephant: '象',
    PieceType.horse: '馬',
    PieceType.chariot: '車',
    PieceType.cannon: '砲',
    PieceType.soldier: '卒',
  };

  return side == PieceSide.red ? redNames[type]! : blackNames[type]!;
}

/// 棋子组件 — 传统木质棋子风格
class PieceWidget extends StatelessWidget {
  final PieceModel piece;
  final double size;
  final bool isSelected;

  const PieceWidget({
    super.key,
    required this.piece,
    required this.size,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final isRed = piece.side == PieceSide.red;
    final textColor = isRed ? const Color(0xFFA01010) : const Color(0xFF1A1A1A);
    final name = getPieceName(piece.type, piece.side);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // 木质棋子渐变底色
        gradient: RadialGradient(
          center: const Alignment(-0.2, -0.3),
          radius: 0.9,
          colors: isSelected
              ? [const Color(0xFFFFF3D6), const Color(0xFFE8C878)]
              : [const Color(0xFFF7E8C8), const Color(0xFFD4B47A)],
        ),
        border: Border.all(
          color: isSelected ? const Color(0xFFD4A84B) : const Color(0xFF6B3A1F),
          width: isSelected ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isSelected ? 0.5 : 0.35),
            blurRadius: isSelected ? 6 : 3,
            offset: const Offset(1, 2),
          ),
          if (isSelected)
            const BoxShadow(
              color: Color(0x40D4A84B),
              blurRadius: 10,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.78,
          height: size * 0.78,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: textColor.withValues(alpha: 0.3),
              width: 1.0,
            ),
          ),
          child: Center(
            child: Text(
              name,
              style: TextStyle(
                fontSize: size * 0.48,
                fontWeight: FontWeight.w900,
                color: textColor,
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
