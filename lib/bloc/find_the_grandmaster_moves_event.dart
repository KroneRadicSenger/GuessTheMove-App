part of 'find_the_grandmaster_moves_bloc.dart';

abstract class FindTheGrandmasterMovesEvent extends Equatable {
  const FindTheGrandmasterMovesEvent();
}

class FindTheGrandmasterMovesGoToNextStateEvent extends FindTheGrandmasterMovesEvent {
  @override
  List<Object?> get props => [];
}

class FindTheGrandmasterMovesGoToPreviousStateEvent extends FindTheGrandmasterMovesEvent {
  @override
  List<Object?> get props => [];
}

class FindTheGrandmasterMovesSelectGuessEvent extends FindTheGrandmasterMovesEvent {
  final EvaluatedMove moveSelected;

  FindTheGrandmasterMovesSelectGuessEvent(this.moveSelected);

  @override
  List<Object?> get props => [moveSelected];
}

class FindTheGrandmasterMovesUnselectGuessEvent extends FindTheGrandmasterMovesEvent {
  @override
  List<Object?> get props => [];
}

class FindTheGrandmasterMovesSubmitGuessEvent extends FindTheGrandmasterMovesEvent {
  final PointsBloc pointsBloc;

  FindTheGrandmasterMovesSubmitGuessEvent(this.pointsBloc);

  @override
  List<Object?> get props => [pointsBloc];
}

class FindTheGrandmasterMovesRevealOpponentMoveEvent extends FindTheGrandmasterMovesEvent {
  @override
  List<Object?> get props => [];
}

class FindTheGrandmasterMovesShowNextTipEvent extends FindTheGrandmasterMovesEvent {
  final BuildContext? context;
  final PointsBloc pointsBloc;

  FindTheGrandmasterMovesShowNextTipEvent(this.context, this.pointsBloc);

  @override
  List<Object?> get props => [context, pointsBloc];
}

class FindTheGrandmasterMovesEndTimeBattleGameEvent extends FindTheGrandmasterMovesEvent {
  final int initialTimeInSeconds;
  final int totalPointsGivenAmount;
  final int totalMovesPlayedAmount;
  final int correctMovesPlayedAmount;

  FindTheGrandmasterMovesEndTimeBattleGameEvent(
      {required this.initialTimeInSeconds, required this.totalPointsGivenAmount, required this.totalMovesPlayedAmount, required this.correctMovesPlayedAmount});

  @override
  List<Object?> get props => [initialTimeInSeconds, totalPointsGivenAmount, totalMovesPlayedAmount, correctMovesPlayedAmount];
}

class FindTheGrandmasterMovesEndSurvivalGameEvent extends FindTheGrandmasterMovesEvent {
  final int amountLives;
  final int totalPointsGivenAmount;
  final int totalMovesPlayedAmount;
  final int correctMovesPlayedAmount;

  FindTheGrandmasterMovesEndSurvivalGameEvent(
      {required this.amountLives, required this.totalPointsGivenAmount, required this.totalMovesPlayedAmount, required this.correctMovesPlayedAmount});

  @override
  List<Object?> get props => [amountLives, totalPointsGivenAmount, totalMovesPlayedAmount, correctMovesPlayedAmount];
}
