part of 'puzzle_bloc.dart';

@immutable
abstract class PuzzleEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class PuzzlePlayMoveEvent extends PuzzleEvent {
  final String sanMove;
  final PointsBloc pointsBloc;

  PuzzlePlayMoveEvent(this.sanMove, this.pointsBloc);

  @override
  List<Object?> get props => [sanMove, pointsBloc];
}

class PuzzleShowNextTipEvent extends PuzzleEvent {
  final BuildContext? context;
  final PointsBloc pointsBloc;

  PuzzleShowNextTipEvent(this.context, this.pointsBloc);

  @override
  List<Object?> get props => [context, pointsBloc];
}

class PuzzleRetryCurrentPuzzleEvent extends PuzzleEvent {}

class PuzzleShowNextPuzzleEvent extends PuzzleEvent {}

class PuzzleEndGameEvent extends PuzzleEvent {}
