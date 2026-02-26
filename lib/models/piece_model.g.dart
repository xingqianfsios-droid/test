// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'piece_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PieceModelImpl _$$PieceModelImplFromJson(Map<String, dynamic> json) =>
    _$PieceModelImpl(
      id: json['id'] as String,
      type: $enumDecode(_$PieceTypeEnumMap, json['type']),
      side: $enumDecode(_$PieceSideEnumMap, json['side']),
      col: (json['col'] as num).toInt(),
      row: (json['row'] as num).toInt(),
    );

Map<String, dynamic> _$$PieceModelImplToJson(_$PieceModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$PieceTypeEnumMap[instance.type]!,
      'side': _$PieceSideEnumMap[instance.side]!,
      'col': instance.col,
      'row': instance.row,
    };

const _$PieceTypeEnumMap = {
  PieceType.king: 'king',
  PieceType.advisor: 'advisor',
  PieceType.elephant: 'elephant',
  PieceType.horse: 'horse',
  PieceType.chariot: 'chariot',
  PieceType.cannon: 'cannon',
  PieceType.soldier: 'soldier',
};

const _$PieceSideEnumMap = {PieceSide.red: 'red', PieceSide.black: 'black'};
