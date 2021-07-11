import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_settings.g.dart';

enum MoveNotationEnum { san, fan, uci }

enum MoveEvaluationNotationEnum { pawnScore, grandmasterExpectation }

enum BoardRotationEnum { white, grandmaster }

const initialUserSettings = UserSettings(
  ThemeMode.light,
  MoveNotationEnum.fan,
  MoveEvaluationNotationEnum.pawnScore,
  true,
  true,
  true,
  BoardRotationEnum.grandmaster,
);

@JsonSerializable()
class UserSettings extends Equatable {
  final ThemeMode themeMode;
  final MoveNotationEnum moveNotation;
  final MoveEvaluationNotationEnum moveEvaluationNotation;
  final bool revealOpponentMovesFindGrandmasterMove;
  final bool revealOpponentMovesTimeBattle;
  final bool revealOpponentMovesSurvival;
  final BoardRotationEnum boardRotation;

  const UserSettings(this.themeMode, this.moveNotation, this.moveEvaluationNotation, this.revealOpponentMovesFindGrandmasterMove, this.revealOpponentMovesTimeBattle,
      this.revealOpponentMovesSurvival, this.boardRotation);

  @override
  List<Object?> get props =>
      [themeMode, moveNotation, moveEvaluationNotation, revealOpponentMovesFindGrandmasterMove, revealOpponentMovesTimeBattle, revealOpponentMovesSurvival, boardRotation];

  factory UserSettings.fromJson(Map<String, dynamic> json) => _$UserSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$UserSettingsToJson(this);

  UserSettings copyWith({
    final ThemeMode? themeMode,
    final MoveNotationEnum? moveNotation,
    final MoveEvaluationNotationEnum? moveEvaluationNotation,
    final bool? revealOpponentMovesFindGrandmasterMove,
    final bool? revealOpponentMovesTimeBattle,
    final bool? revealOpponentMovesSurvival,
    final BoardRotationEnum? boardRotation,
  }) {
    return UserSettings(
      themeMode ?? this.themeMode,
      moveNotation ?? this.moveNotation,
      moveEvaluationNotation ?? this.moveEvaluationNotation,
      revealOpponentMovesFindGrandmasterMove ?? this.revealOpponentMovesFindGrandmasterMove,
      revealOpponentMovesTimeBattle ?? this.revealOpponentMovesTimeBattle,
      revealOpponentMovesSurvival ?? this.revealOpponentMovesSurvival,
      boardRotation ?? this.boardRotation,
    );
  }
}
