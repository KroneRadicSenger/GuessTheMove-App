import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/find_the_grandmaster_moves_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/header.dart';
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/model/user_settings.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/chessboard_model.dart';
import 'package:guess_the_move/screens/game_modes/components/game_layout.dart';
import 'package:guess_the_move/theme/theme.dart';

class FindTheGrandmasterMovesGameContents extends StatefulWidget {
  final ChessBoardController chessBoardController;
  final Widget ingameHeader;

  FindTheGrandmasterMovesGameContents({Key? key, required this.chessBoardController, required this.ingameHeader}) : super(key: key);

  @override
  _FindTheGrandmasterMovesGameContentsState createState() => _FindTheGrandmasterMovesGameContentsState();
}

class _FindTheGrandmasterMovesGameContentsState extends State<FindTheGrandmasterMovesGameContents> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) => BlocBuilder<FindTheGrandmasterMovesBloc, FindTheGrandmasterMovesState>(
        builder: (context, state) => BlocBuilder<UserSettingsBloc, UserSettingsState>(
          builder: (context, userSettingsState) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              state is FindTheGrandmasterMovesIngameState ? widget.ingameHeader : Header(),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: appTheme(context, userSettingsState.userSettings.themeMode).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(30.0),
                      topRight: const Radius.circular(30.0),
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(.2), offset: Offset(0, -3), blurRadius: 4, spreadRadius: 0),
                    ],
                  ),
                  child: _buildContents(state, userSettingsState),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildContents(final FindTheGrandmasterMovesState state, final UserSettingsState userSettingsState) {
    return Padding(
      padding: EdgeInsets.fromLTRB(scaffoldPaddingHorizontal, 20, scaffoldPaddingHorizontal, 0),
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: BouncingScrollPhysics(),
        child: GameLayout(
          scrollController: _scrollController,
          chessBoardController: widget.chessBoardController,
          hidePlayerNames: false,
        ),
      ),
    );
  }
}
