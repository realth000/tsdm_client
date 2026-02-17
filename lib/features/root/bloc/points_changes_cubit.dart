import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'points_changes_cubit.mapper.dart';

/// What kinds of points changed and how much value changed.
@MappableClass()
final class PointsChangesValue with PointsChangesValueMappable {
  /// Constructor.
  const PointsChangesValue({
    this.ww = 0,
    this.tsb = 0,
    this.xc = 0,
    this.tr = 0,
    this.fh = 0,
    this.jl = 0,
    this.specialAttr = 0,
    this.specialAttr2 = 0,
  });

  /// The empty one.
  static const empty = PointsChangesValue();

  /// 威望
  final int ww;

  /// 天使币
  final int tsb;

  /// 宣传
  final int xc;

  /// 天然
  final int tr;

  /// 腹黑
  final int fh;

  /// 精灵
  final int jl;

  /// Kind of attribute changes following seasons events.
  final int specialAttr;

  /// Another kind of attribute changes following seasons events.
  final int specialAttr2;
}

/// Cubit of user points changes events.
final class PointsChangesCubit extends Cubit<PointsChangesValue> {
  /// Constructor.
  PointsChangesCubit() : super(PointsChangesValue.empty);

  /// New points changes arrived.
  void recordsChanges(PointsChangesValue value) => emit(value);
}
