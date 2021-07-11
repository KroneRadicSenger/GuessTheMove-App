part of 'points_bloc.dart';

abstract class PointsEvent extends Equatable {
  const PointsEvent();

  @override
  List<Object> get props => [];
}

class PointsLoadInitiated extends PointsEvent {}

class PointsReset extends PointsEvent {}

class AddPoints extends PointsEvent {
  final int pointsToAdd;

  const AddPoints(this.pointsToAdd);

  @override
  List<Object> get props => [pointsToAdd];
}

class RemovePoints extends PointsEvent {
  final int pointsToRemove;

  const RemovePoints(this.pointsToRemove);

  @override
  List<Object> get props => [pointsToRemove];
}
