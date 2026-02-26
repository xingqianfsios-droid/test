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

/// 棋子组件
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
    final pieceColor = isRed ? Colors.red.shade800 : Colors.black87;
    final name = getPieceName(piece.type, piece.side);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFAEBD7), // 棋子底色
        border: Border.all(
          color: isSelected ? Colors.amber : pieceColor,
          width: isSelected ? 3.0 : 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 3,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          name,
          style: TextStyle(
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
            color: pieceColor,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
