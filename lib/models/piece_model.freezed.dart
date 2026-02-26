// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'piece_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PieceModel _$PieceModelFromJson(Map<String, dynamic> json) {
  return _PieceModel.fromJson(json);
}

/// @nodoc
mixin _$PieceModel {
  /// 棋子唯一标识（用于 UI key 稳定性）
  String get id => throw _privateConstructorUsedError;
  PieceType get type => throw _privateConstructorUsedError;
  PieceSide get side => throw _privateConstructorUsedError;

  /// 列坐标 (0-8)
  int get col => throw _privateConstructorUsedError;

  /// 行坐标 (0-9)
  int get row => throw _privateConstructorUsedError;

  /// Serializes this PieceModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PieceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PieceModelCopyWith<PieceModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PieceModelCopyWith<$Res> {
  factory $PieceModelCopyWith(
    PieceModel value,
    $Res Function(PieceModel) then,
  ) = _$PieceModelCopyWithImpl<$Res, PieceModel>;
  @useResult
  $Res call({String id, PieceType type, PieceSide side, int col, int row});
}

/// @nodoc
class _$PieceModelCopyWithImpl<$Res, $Val extends PieceModel>
    implements $PieceModelCopyWith<$Res> {
  _$PieceModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PieceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? side = null,
    Object? col = null,
    Object? row = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as PieceType,
            side: null == side
                ? _value.side
                : side // ignore: cast_nullable_to_non_nullable
                      as PieceSide,
            col: null == col
                ? _value.col
                : col // ignore: cast_nullable_to_non_nullable
                      as int,
            row: null == row
                ? _value.row
                : row // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PieceModelImplCopyWith<$Res>
    implements $PieceModelCopyWith<$Res> {
  factory _$$PieceModelImplCopyWith(
    _$PieceModelImpl value,
    $Res Function(_$PieceModelImpl) then,
  ) = __$$PieceModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, PieceType type, PieceSide side, int col, int row});
}

/// @nodoc
class __$$PieceModelImplCopyWithImpl<$Res>
    extends _$PieceModelCopyWithImpl<$Res, _$PieceModelImpl>
    implements _$$PieceModelImplCopyWith<$Res> {
  __$$PieceModelImplCopyWithImpl(
    _$PieceModelImpl _value,
    $Res Function(_$PieceModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PieceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? side = null,
    Object? col = null,
    Object? row = null,
  }) {
    return _then(
      _$PieceModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as PieceType,
        side: null == side
            ? _value.side
            : side // ignore: cast_nullable_to_non_nullable
                  as PieceSide,
        col: null == col
            ? _value.col
            : col // ignore: cast_nullable_to_non_nullable
                  as int,
        row: null == row
            ? _value.row
            : row // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PieceModelImpl implements _PieceModel {
  const _$PieceModelImpl({
    required this.id,
    required this.type,
    required this.side,
    required this.col,
    required this.row,
  });

  factory _$PieceModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PieceModelImplFromJson(json);

  /// 棋子唯一标识（用于 UI key 稳定性）
  @override
  final String id;
  @override
  final PieceType type;
  @override
  final PieceSide side;

  /// 列坐标 (0-8)
  @override
  final int col;

  /// 行坐标 (0-9)
  @override
  final int row;

  @override
  String toString() {
    return 'PieceModel(id: $id, type: $type, side: $side, col: $col, row: $row)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PieceModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.side, side) || other.side == side) &&
            (identical(other.col, col) || other.col == col) &&
            (identical(other.row, row) || other.row == row));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, type, side, col, row);

  /// Create a copy of PieceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PieceModelImplCopyWith<_$PieceModelImpl> get copyWith =>
      __$$PieceModelImplCopyWithImpl<_$PieceModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PieceModelImplToJson(this);
  }
}

abstract class _PieceModel implements PieceModel {
  const factory _PieceModel({
    required final String id,
    required final PieceType type,
    required final PieceSide side,
    required final int col,
    required final int row,
  }) = _$PieceModelImpl;

  factory _PieceModel.fromJson(Map<String, dynamic> json) =
      _$PieceModelImpl.fromJson;

  /// 棋子唯一标识（用于 UI key 稳定性）
  @override
  String get id;
  @override
  PieceType get type;
  @override
  PieceSide get side;

  /// 列坐标 (0-8)
  @override
  int get col;

  /// 行坐标 (0-9)
  @override
  int get row;

  /// Create a copy of PieceModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PieceModelImplCopyWith<_$PieceModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
