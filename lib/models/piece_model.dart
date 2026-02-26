import 'package:freezed_annotation/freezed_annotation.dart';

part 'piece_model.freezed.dart';
part 'piece_model.g.dart';

/// 棋子类型
enum PieceType {
  /// 帅/将
  king,

  /// 仕/士
  advisor,

  /// 相/象
  elephant,

  /// 马
  horse,

  /// 车
  chariot,

  /// 炮
  cannon,

  /// 兵/卒
  soldier,
}

/// 棋子阵营
enum PieceSide {
  red,
  black,
}

/// 棋子模型 - 9x10 坐标系，左上角为 (0,0)
@freezed
class PieceModel with _$PieceModel {
  const factory PieceModel({
    /// 棋子唯一标识（用于 UI key 稳定性）
    required String id,

    required PieceType type,
    required PieceSide side,

    /// 列坐标 (0-8)
    required int col,

    /// 行坐标 (0-9)
    required int row,
  }) = _PieceModel;

  factory PieceModel.fromJson(Map<String, dynamic> json) =>
      _$PieceModelFromJson(json);
}
