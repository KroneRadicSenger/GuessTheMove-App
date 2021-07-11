import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:guess_the_move/model/points.dart';
import 'package:guess_the_move/repository/dao/points_dao.dart';
import 'package:meta/meta.dart';
import 'package:sembast/sembast.dart';

part 'points_event.dart';
part 'points_state.dart';

class PointsBloc extends Bloc<PointsEvent, PointsState> {
  final Database? database;
  final int? initialPoints;

  PointsBloc({this.database, this.initialPoints}) : super(initialPoints == null ? PointsInitial() : PointsState(Points(initialPoints)));

  @override
  Stream<PointsState> mapEventToState(
    PointsEvent event,
  ) async* {
    if (event is PointsReset) {
      const newPoints = Points(0);
      await PointsDao().update(newPoints);
      yield PointsState(newPoints);
    } else if (event is PointsLoadInitiated) {
      yield PointsState(await PointsDao().get());
    } else if (event is AddPoints) {
      final newPoints = state.points.add(event.pointsToAdd);
      await PointsDao(database: database).update(newPoints);
      yield PointsState(newPoints);
    } else if (event is RemovePoints) {
      final newPoints = state.points.remove(event.pointsToRemove);
      await PointsDao(database: database).update(newPoints);
      yield PointsState(newPoints);
    }
  }
}
