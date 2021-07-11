import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'points.g.dart';

const Points initialPoints = Points(0);

@JsonSerializable()
class Points extends Equatable {
  final int amount;

  const Points(this.amount);

  @override
  List<Object?> get props => [amount];

  Points add(final int increment) => Points(amount + increment);

  Points remove(final int decrement) => Points(amount - decrement);

  factory Points.fromJson(Map<String, dynamic> json) => _$PointsFromJson(json);

  Map<String, dynamic> toJson() => _$PointsToJson(this);
}
