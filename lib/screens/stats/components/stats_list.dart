import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/titled_container.dart';
import 'package:guess_the_move/screens/stats/components/find_the_grandmaster_move_stats_group.dart';
import 'package:guess_the_move/screens/stats/components/puzzle_mode_stats_group.dart';
import 'package:guess_the_move/screens/stats/components/survival_stats_group.dart';
import 'package:guess_the_move/screens/stats/components/time_battle_stats_group.dart';
import 'package:guess_the_move/screens/stats/components/time_frame_selector.dart';

import 'diagrams/stats_diagram.dart';

class StatsList extends StatefulWidget {
  final String initialTimeFrame;

  const StatsList({Key? key, this.initialTimeFrame = 'Insgesamt'}) : super(key: key);

  @override
  _StatsListState createState() => _StatsListState();
}

class _StatsListState extends State<StatsList> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> timeFrameSelectors = ['Insgesamt', 'Heute', 'Woche', 'Monat', 'Jahr'];

  @override
  void initState() {
    _tabController = TabController(length: timeFrameSelectors.length, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<UserSettingsBloc, UserSettingsState>(builder: (context, userSettingsState) {
        return NestedScrollView(
          headerSliverBuilder: (context, value) {
            return [
              SliverToBoxAdapter(
                child: TitledContainer(
                  title: 'Statistiken',
                  child: Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: TimeFrameSelection(
                      timeFrames: timeFrameSelectors,
                      controller: _tabController,
                    ),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            physics: BouncingScrollPhysics(),
            controller: _tabController,
            children: timeFrameSelectors
                .map(
                  (t) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: ListView(
                      children: [
                        SizedBox(height: 20),
                        StatsDiagram(selectedTimeFrame: t),
                        SizedBox(height: 20),
                        FindTheGrandmasterMoveStatsGroup(
                          selectedTimeFrame: t,
                        ),
                        SizedBox(height: 20),
                        TimeBattleStatsGroup(selectedTimeFrame: t),
                        SizedBox(height: 20),
                        SurvivalStatsGroup(selectedTimeFrame: t),
                        SizedBox(height: 20),
                        PuzzleModeStatsGroup(selectedTimeFrame: t),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        );
      });
}
