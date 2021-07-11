import 'package:equatable/equatable.dart';
import 'package:guess_the_move/model/player.dart';
import 'package:json_annotation/json_annotation.dart';

part 'analyzed_games_bundle.g.dart';

enum AnalyzedGamesBundleType { byGrandmasterAndYear }

abstract class AnalyzedGamesBundle extends Equatable implements Comparable {
  const AnalyzedGamesBundle();

  String getId();

  AnalyzedGamesBundleType getType();

  String getFileName();

  String getDisplayName();

  String getInfoText();

  @override
  int compareTo(other) {
    if (other == null || !(other is AnalyzedGamesBundle)) {
      return 1;
    }

    switch (other.getType()) {
      case AnalyzedGamesBundleType.byGrandmasterAndYear:
        if (getType() == AnalyzedGamesBundleType.byGrandmasterAndYear) {
          return (other as AnalyzedGamesBundleByGrandmasterAndYear).year.compareTo((this as AnalyzedGamesBundleByGrandmasterAndYear).year);
        } else {
          // Bundles by grandmaster and year come first
          return -1;
        }
    }
  }

  factory AnalyzedGamesBundle.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'byGrandmasterAndYear':
        return AnalyzedGamesBundleByGrandmasterAndYear.fromJson(json);
      default:
        throw ArgumentError('Unsupported bundle type.');
    }
  }

  Map<String, dynamic> toJson() {
    switch (this.getType()) {
      case AnalyzedGamesBundleType.byGrandmasterAndYear:
        return (this as AnalyzedGamesBundleByGrandmasterAndYear).toJson();
      default:
        throw ArgumentError('Unsupported bundle type.');
    }
  }
}

@JsonSerializable()
class AnalyzedGamesBundleByGrandmasterAndYear extends AnalyzedGamesBundle {
  final AnalyzedGamesBundleType type;
  final Player grandmaster;
  final int year;

  AnalyzedGamesBundleByGrandmasterAndYear({this.type = AnalyzedGamesBundleType.byGrandmasterAndYear, required this.grandmaster, required this.year});

  @override
  String getId() {
    return 'byGrandmasterAndYear_${grandmaster.fullName}_$year';
  }

  @override
  AnalyzedGamesBundleType getType() {
    return type;
  }

  @override
  String getFileName() {
    return '${grandmaster.fullName}_${year}_compressed';
  }

  @override
  String getDisplayName() {
    return year.toString();
  }

  @override
  String getInfoText() {
    return 'Enthält gewonnene Partien von ${grandmaster.getFirstAndLastName()} aus dem Jahr ${year.toString()}';
  }

  @override
  List<Object?> get props => [type, grandmaster, year];

  factory AnalyzedGamesBundleByGrandmasterAndYear.fromJson(Map<String, dynamic> json) => _$AnalyzedGamesBundleByGrandmasterAndYearFromJson(json);
  Map<String, dynamic> toJson() => _$AnalyzedGamesBundleByGrandmasterAndYearToJson(this);
}
