import 'package:equatable/equatable.dart';
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:json_annotation/json_annotation.dart';

part 'summary_data.g.dart';

@JsonSerializable()
class SummaryDataGuessEvaluated extends Equatable {
  final AnalyzedMove move;
  final List<EvaluatedMove> shuffledAnswerMoves;
  final EvaluatedMove chosenMove;
  final bool grandmasterMovePlayed;
  final AnalyzedMoveType chosenMoveType;
  final int pointsGiven;

  SummaryDataGuessEvaluated(this.move, this.shuffledAnswerMoves, this.chosenMove, this.grandmasterMovePlayed, this.chosenMoveType, this.pointsGiven);

  @override
  List<Object?> get props => [move, shuffledAnswerMoves, chosenMove, grandmasterMovePlayed, chosenMoveType, pointsGiven];

  factory SummaryDataGuessEvaluated.fromJson(Map<String, dynamic> json) => _$SummaryDataGuessEvaluatedFromJson(json);
  Map<String, dynamic> toJson() => _$SummaryDataGuessEvaluatedToJson(this);
}

@JsonSerializable()
class SummaryData extends Equatable {
  final List<SummaryDataGuessEvaluated> guessEvaluatedList;

  SummaryData(this.guessEvaluatedList);

  @override
  List<Object?> get props => [guessEvaluatedList];

  factory SummaryData.fromJson(Map<String, dynamic> json) => _$SummaryDataFromJson(json);
  Map<String, dynamic> toJson() => _$SummaryDataToJson(this);

  int getPointsGivenTotalAmount() {
    if (guessEvaluatedList.isEmpty) {
      return 0;
    }
    return guessEvaluatedList.map((state) => state.pointsGiven).reduce((value, element) => value + element);
  }

  int getTotalMovesGuessedAmount() {
    if (guessEvaluatedList.isEmpty) {
      return 0;
    }
    return guessEvaluatedList.length;
  }

  int getGrandmasterMovesGuessedAmount() {
    if (guessEvaluatedList.isEmpty) {
      return 0;
    }
    return guessEvaluatedList.where((state) => state.grandmasterMovePlayed).length;
  }

  Map<AnalyzedMoveType, int> getMovesGuessesAmountsByAnalyzedMoveType() {
    final Map<AnalyzedMoveType, int> guessedAmountByMoveType = {};

    for (var analyzedMoveType in AnalyzedMoveType.values) {
      if (analyzedMoveType == AnalyzedMoveType.book) {
        continue;
      }
      guessedAmountByMoveType[analyzedMoveType] = 0;
    }

    for (int i = 0; i < guessEvaluatedList.length; i++) {
      var screenState = guessEvaluatedList[i];
      guessedAmountByMoveType[screenState.chosenMoveType] = guessedAmountByMoveType[screenState.chosenMoveType]! + 1;
    }

    return guessedAmountByMoveType;
  }

  int getBestMovesGuessedAmount() {
    if (guessEvaluatedList.isEmpty) {
      return 0;
    }

    final Map<AnalyzedMoveType, int> guessedAmountByMoveType = getMovesGuessesAmountsByAnalyzedMoveType();

    return guessedAmountByMoveType[AnalyzedMoveType.brilliant]! +
        guessedAmountByMoveType[AnalyzedMoveType.critical]! +
        guessedAmountByMoveType[AnalyzedMoveType.gameChanger]! +
        guessedAmountByMoveType[AnalyzedMoveType.best]!;
  }
}
