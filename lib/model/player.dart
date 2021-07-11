import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'player.g.dart';

final RegExp playerNameRegex = new RegExp(
  r"^[a-zA-Z0-9 '\-]+, ([a-zA-Z0-9 '\-\.]+|\\?)$",
  multiLine: false,
);

@JsonSerializable()
class Player extends Equatable {
  final String fullName;
  final String latestEloRating;

  Player(this.fullName, this.latestEloRating) : assert(playerNameRegex.hasMatch(fullName));

  @override
  List<Object?> get props => [fullName];

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerToJson(this);

  String getFirstName() {
    return fullName.split(', ').last;
  }

  String getLastName() {
    return fullName.split(', ').first;
  }

  String getFirstAndLastName() {
    return '${getFirstName()} ${getLastName()}';
  }
}
