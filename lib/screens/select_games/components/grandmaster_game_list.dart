import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/horizontal_list.dart';
import 'package:guess_the_move/components/titled_container.dart';
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/model/analyzed_games_bundle.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/model/player.dart';
import 'package:guess_the_move/repository/analyzed_games_repository.dart';
import 'package:guess_the_move/screens/select_games/components/grandmaster_game.dart';
import 'package:guess_the_move/screens/select_games/components/grandmaster_game_bundle_selection.dart';
import 'package:guess_the_move/screens/select_games/components/grandmaster_games_loading_indicator.dart';
import 'package:guess_the_move/screens/select_games/components/search_games_modal_contents.dart';
import 'package:guess_the_move/theme/theme.dart';

class GrandmasterGameList extends StatefulWidget {
  final Player grandmaster;
  final GameModeEnum gameMode;
  final List<AnalyzedGamesBundle> analyzedGamesBundlesForGrandmaster;
  final AnalyzedGamesBundle selectedBundle;
  final FilterOptions? filterOptions;
  final Function(AnalyzedGamesBundle) onSelectBundle;
  final Function(FilterOptions) onUpdateFilterOptions;

  GrandmasterGameList(
      {required this.grandmaster,
      required this.gameMode,
      required this.analyzedGamesBundlesForGrandmaster,
      required this.selectedBundle,
      required this.filterOptions,
      required this.onSelectBundle,
      required this.onUpdateFilterOptions,
      Key? key})
      : super(key: key);

  @override
  _GrandmasterGameListState createState() => _GrandmasterGameListState();
}

class _GrandmasterGameListState extends State<GrandmasterGameList> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  bool _showScrollToTopButton = false;

  @override
  void initState() {
    _tabController = TabController(length: widget.analyzedGamesBundlesForGrandmaster.length, vsync: this);
    super.initState();

    _tabController.addListener(() {
      widget.onSelectBundle(widget.analyzedGamesBundlesForGrandmaster[_tabController.index]);
    });

    //_scrollController.addListener(() => _handleScroll(_scrollController));
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<UserSettingsBloc, UserSettingsState>(
        builder: (context, state) {
          return Stack(
            children: [
              _buildPageContents(state),
              if (_showScrollToTopButton) _buildScrollBackToTopButton(state),
            ],
          );
        },
      );

  // TODO Sort by Date ascending or descending?

  Widget _buildPageContents(final UserSettingsState state) {
    return NestedScrollView(
      physics: BouncingScrollPhysics(),
      controller: _scrollController,
      headerSliverBuilder: (context, value) {
        return [
          SliverToBoxAdapter(
            child: TitledContainer.multipleChildren(
              title: 'Finde die Züge von \n${widget.grandmaster.getFirstAndLastName()}',
              showBackArrow: true,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: GrandmasterGameBundleSelection(
                    gameMode: widget.gameMode,
                    bundles: widget.analyzedGamesBundlesForGrandmaster,
                    controller: _tabController,
                  ),
                ),
                if (widget.filterOptions != null && widget.filterOptions!.hasAnyFilter())
                  Container(
                    margin: const EdgeInsets.only(top: 15),
                    child: _buildEnabledFilters(state),
                  ),
              ],
            ),
          ),
        ];
      },
      body: TabBarView(
        physics: BouncingScrollPhysics(),
        controller: _tabController,
        children: widget.analyzedGamesBundlesForGrandmaster
            .map(
              (b) => Container(
                margin: EdgeInsets.symmetric(vertical: 15),
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: _buildTabContents(b, state),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildTabContents(final AnalyzedGamesBundle bundle, final UserSettingsState state) {
    final isTabSelected = widget.analyzedGamesBundlesForGrandmaster[_tabController.index] == bundle;

    if (isTabSelected || isAnalyzedGamesBundleLoaded(bundle)) {
      return FutureBuilder(
        future: loadAnalyzedGamesInBundle(bundle),
        builder: (BuildContext context, AsyncSnapshot<List<AnalyzedGame>> snapshot) {
          if (!snapshot.hasData) {
            return GrandmasterGamesLoadingIndicator(userSettingsState: state);
          }

          final allGamesInBundle = snapshot.data!;
          allGamesInBundle.sort((a, b) => b.gameInfo.date.millisecondsSinceEpoch.compareTo(a.gameInfo.date.millisecondsSinceEpoch));

          return NotificationListener<UserScrollNotification>(
            child: ListView(
              physics: BouncingScrollPhysics(),
              children: _buildFilteredGrandmasterGamesInBundle(state, allGamesInBundle),
            ),
            onNotification: (notification) {
              _handleScroll(notification);
              return true;
            },
          );
        },
      );
    }

    return GrandmasterGamesLoadingIndicator(userSettingsState: state);
  }

  Widget _buildEnabledFilters(final UserSettingsState state) {
    return HorizontalList(
      height: 30,
      margin: const EdgeInsets.only(bottom: 10),
      elements: [
        if (widget.filterOptions!.hasOpponentFilter())
          _buildEnabledFilter(
            state,
            widget.filterOptions!.selectedOpponent!,
            () => widget.onUpdateFilterOptions(widget.filterOptions!.removeOpponentFilter()),
          ),
        if (widget.filterOptions!.hasOpeningFilter())
          _buildEnabledFilter(
            state,
            widget.filterOptions!.selectedOpening!,
            () => widget.onUpdateFilterOptions(widget.filterOptions!.removeOpeningFilter()),
          ),
        if (widget.filterOptions!.hasEventFilter())
          _buildEnabledFilter(
            state,
            widget.filterOptions!.selectedEvent!,
            () => widget.onUpdateFilterOptions(widget.filterOptions!.removeEventFilter()),
          ),
        if (widget.filterOptions!.hasDateFilter())
          _buildEnabledFilter(
            state,
            germanDateTimeFormatShort.format(widget.filterOptions!.selectedDate!),
            () => widget.onUpdateFilterOptions(widget.filterOptions!.removeDateFilter()),
          ),
        if (widget.filterOptions!.hasGrandmasterELORangeFilter())
          _buildEnabledFilter(
            state,
            'GM ELO: ${widget.filterOptions!.selectedGrandmasterELORange!.start.toInt()} - ${widget.filterOptions!.selectedGrandmasterELORange!.end.toInt()}',
            () => widget.onUpdateFilterOptions(widget.filterOptions!.removeGrandmasterELORangeFilter()),
          ),
        if (widget.filterOptions!.hasOpponentELORangeFilter())
          _buildEnabledFilter(
            state,
            'Gegner ELO: ${widget.filterOptions!.selectedOpponentELORange!.start.toInt()} - ${widget.filterOptions!.selectedOpponentELORange!.end.toInt()}',
            () => widget.onUpdateFilterOptions(widget.filterOptions!.removeOpponentELORangeFilter()),
          ),
      ],
    );
  }

  Widget _buildEnabledFilter(final UserSettingsState state, final String value, final Function() onTap) {
    return Container(
      decoration: BoxDecoration(
        color: appTheme(context, state.userSettings.themeMode).cardBackgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value),
            IconButton(
              padding: EdgeInsets.zero,
              alignment: Alignment.centerRight,
              splashColor: Colors.black,
              iconSize: 18,
              icon: Icon(Icons.clear, color: appTheme(context, state.userSettings.themeMode).textColor),
              onPressed: onTap,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFilteredGrandmasterGamesInBundle(final UserSettingsState state, final List<AnalyzedGame> allGamesInBundle) {
    final filteredGames = _filterGames(allGamesInBundle);

    final List<Widget> list = filteredGames
        .map((analyzedGame) =>
            Row(children: [Expanded(child: GrandmasterGame(gameMode: widget.gameMode, analyzedGame: analyzedGame, analyzedGameOriginBundle: widget.selectedBundle))]))
        .toList();

    list.insert(
      0,
      Row(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            child: Text('${filteredGames.length} Spiel${filteredGames.length == 1 ? '' : 'e'}'),
          ),
        ],
      ),
    );

    return list;
  }

  Widget _buildScrollBackToTopButton(final UserSettingsState state) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 25),
        child: ElevatedButton(
          onPressed: _handleScrollToTop,
          style: ElevatedButton.styleFrom(
            primary: appTheme(context, state.userSettings.themeMode).gameModeThemes[widget.gameMode]!.accentColor,
          ),
          child: Icon(Icons.keyboard_arrow_up, color: appTheme(context, state.userSettings.themeMode).scaffoldBackgroundColor),
        ),
      ),
    );
  }

  List<AnalyzedGame> _filterGames(final List<AnalyzedGame> allGames) {
    var filteredGames = allGames;
    if (widget.filterOptions != null) {
      if (widget.filterOptions!.hasOpponentFilter()) {
        filteredGames = filteredGames
            .where((game) => (widget.grandmaster != game.whitePlayer ? game.whitePlayer : game.blackPlayer).getFirstAndLastName() == widget.filterOptions!.selectedOpponent!)
            .toList();
      }
      if (widget.filterOptions!.hasOpeningFilter()) {
        filteredGames = filteredGames.where((game) => game.gameAnalysis.opening.name == widget.filterOptions!.selectedOpening!).toList();
      }
      if (widget.filterOptions!.hasEventFilter()) {
        filteredGames = filteredGames.where((game) => game.gameInfo.event == widget.filterOptions!.selectedEvent!).toList();
      }
      if (widget.filterOptions!.hasDateFilter()) {
        filteredGames = filteredGames.where((game) => game.gameInfo.date == widget.filterOptions!.selectedDate!).toList();
      }
      if (widget.filterOptions!.hasGrandmasterELORangeFilter()) {
        filteredGames = filteredGames.where((game) {
          if (game.gameAnalysis.grandmasterSide == GrandmasterSide.white) {
            return game.whitePlayerRating != '-' &&
                int.parse(game.whitePlayerRating) >= widget.filterOptions!.selectedGrandmasterELORange!.start.toInt() &&
                int.parse(game.whitePlayerRating) <= widget.filterOptions!.selectedGrandmasterELORange!.end.toInt();
          } else {
            return game.blackPlayerRating != '-' &&
                int.parse(game.blackPlayerRating) >= widget.filterOptions!.selectedGrandmasterELORange!.start.toInt() &&
                int.parse(game.blackPlayerRating) <= widget.filterOptions!.selectedGrandmasterELORange!.end.toInt();
          }
        }).toList();
      }
      if (widget.filterOptions!.hasOpponentELORangeFilter()) {
        filteredGames = filteredGames.where((game) {
          if (game.gameAnalysis.grandmasterSide == GrandmasterSide.white) {
            return game.blackPlayerRating != '-' &&
                int.parse(game.blackPlayerRating) >= widget.filterOptions!.selectedOpponentELORange!.start.toInt() &&
                int.parse(game.blackPlayerRating) <= widget.filterOptions!.selectedOpponentELORange!.end.toInt();
          } else {
            return game.whitePlayerRating != '-' &&
                int.parse(game.whitePlayerRating) >= widget.filterOptions!.selectedOpponentELORange!.start.toInt() &&
                int.parse(game.whitePlayerRating) <= widget.filterOptions!.selectedOpponentELORange!.end.toInt();
          }
        }).toList();
      }
    }
    return filteredGames;
  }

  void _handleScroll(final UserScrollNotification notification) {
    if (_showScrollToTopButton && notification.metrics.pixels <= 50) {
      setState(() {
        _showScrollToTopButton = false;
      });
    } else if (!_showScrollToTopButton && notification.direction == ScrollDirection.forward && notification.metrics.pixels > 50) {
      setState(() {
        _showScrollToTopButton = true;
      });
    }
  }

  void _handleScrollToTop() {
    _scrollController.animateTo(0, duration: Duration(milliseconds: 500), curve: Curves.easeIn).then((_) {
      setState(() {
        _showScrollToTopButton = false;
      });
    });
  }
}
