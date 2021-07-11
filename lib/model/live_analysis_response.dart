import 'package:equatable/equatable.dart';
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:json_annotation/json_annotation.dart';

part 'live_analysis_response.g.dart';

@JsonSerializable()
class LiveAnalysisResponse extends Equatable {
  final GrandmasterSide turn;
  final EvaluatedMove evaluatedMove;
  final List<EvaluatedMove> alternativeMoves;

  LiveAnalysisResponse(this.turn, this.evaluatedMove, this.alternativeMoves);

  @override
  List<Object?> get props => [turn, evaluatedMove, alternativeMoves];

  factory LiveAnalysisResponse.fromJson(Map<String, dynamic> json) => _$LiveAnalysisResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LiveAnalysisResponseToJson(this);
}
