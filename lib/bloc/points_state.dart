part of 'points_bloc.dart';

@immutable
class PointsState extends Equatable {
  final Points points;

  const PointsState(this.points);

  @override
  List<Object> get props => [points];
}

@immutable
class PointsInitial extends PointsState {
  const PointsInitial() : super(initialPoints);
}
