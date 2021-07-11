import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chess/chess.dart' as chess;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/utils/show_alert_dialog.dart';
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/model/live_analysis_response.dart';
import 'package:guess_the_move/model/user_settings.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/chess_board.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/chessboard_model.dart';
import 'package:guess_the_move/screens/game_modes/components/game_pawn_or_mate_score.dart';
import 'package:guess_the_move/screens/game_modes/components/game_winning_chance.dart';
import 'package:guess_the_move/screens/game_modes/components/live_analysis/components/game_live_analysis_results.dart';
import 'package:guess_the_move/screens/game_modes/components/live_analysis/components/game_move_history.dart';
import 'package:guess_the_move/services/live_analysis_endpoint.dart';
import 'package:guess_the_move/theme/theme.dart';
import 'package:http/http.dart' as http;

class GameLiveAnalysisContents extends StatefulWidget {
  final GameModeEnum gameMode;
  final AnalyzedGame analyzedGame;
  final AnalyzedMove analyzedMove;
  final UserSettingsState userSettingsState;
  final ChessBoardController gameChessboardController;

  const GameLiveAnalysisContents(
      {Key? key, required this.gameMode, required this.analyzedGame, required this.analyzedMove, required this.userSettingsState, required this.gameChessboardController})
      : super(key: key);

  @override
  _GameLiveAnalysisContentsState createState() => _GameLiveAnalysisContentsState();
}

class _GameLiveAnalysisContentsState extends State<GameLiveAnalysisContents> {
  final ChessBoardController _chessBoardController = ChessBoardController();
  final ScrollController _scrollController = ScrollController();

  final StreamController<chess.Chess> _boardStreamController = StreamController<chess.Chess>.broadcast();
  final StreamController<EvaluatedMove?> _evaluatedMoveStreamController = StreamController<EvaluatedMove?>.broadcast();
  final StreamController<LiveAnalysisResponse?> _liveAnalysisResponseStreamController = StreamController<LiveAnalysisResponse>.broadcast();

  bool _boardFlipped = false;
  bool _isInitialized = false;
  bool _fetchingAnalysisData = false;
  bool _noMovePlayedYet = false;
  bool _liveAnalysisActivated = true;
  String? _errorMessage;

  chess.Chess? _boardBefore;
  chess.Chess? _newBoard;
  ChessMove? _movePlayed;

  @override
  void initState() {
    this._boardFlipped = _mustBoardBeFlipped(
      widget.userSettingsState.userSettings.boardRotation,
    );

    final AnalyzedMove? lastMovePlayed = (widget.analyzedMove.ply == 0) ? null : widget.analyzedGame.gameAnalysis.analyzedMoves[widget.analyzedMove.ply - 1];

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _boardStreamController.add(_chessBoardController.getLibraryBoard!());
      _evaluatedMoveStreamController.add(lastMovePlayed?.actualMove);
      _isInitialized = true;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var chessBoardWidth = screenWidth - (2 * scaffoldPaddingHorizontal);
    var chessBoardSize = chessBoardWidth - (chessBoardWidth % 8);

    return Padding(
      padding: EdgeInsets.fromLTRB(scaffoldPaddingHorizontal, 0, scaffoldPaddingHorizontal, 0),
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildScoreAndFlipBoardHeader(),
            ChessBoard(
              size: chessBoardSize,
              lightSquareColor: appTheme(context, widget.userSettingsState.userSettings.themeMode).gameModeThemes[widget.gameMode]!.chessBoardLightSquareColor,
              darkSquareColor: appTheme(context, widget.userSettingsState.userSettings.themeMode).gameModeThemes[widget.gameMode]!.chessBoardDarkSquareColor,
              highlightSquareColor: Colors.lightGreenAccent.withOpacity(0.5),
              markDragMoveToSquaresColor: Colors.black.withOpacity(0.3),
              textColor: appTheme(context, widget.userSettingsState.userSettings.themeMode).textColor,
              whitePlayer: widget.analyzedGame.whitePlayer,
              blackPlayer: widget.analyzedGame.blackPlayer,
              flipped: _boardFlipped,
              dragToMakeMove: !_fetchingAnalysisData,
              controller: _chessBoardController,
              postInitialize: _initializeChessboard,
              onBoardChange: (final chess.Chess? boardBefore, final chess.Chess newBoard, final ChessMove? movePlayed) {
                _boardBefore = boardBefore;
                _newBoard = newBoard;
                _movePlayed = movePlayed;
                _analyseCurrentMove();
              },
            ),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: appTheme(context, widget.userSettingsState.userSettings.themeMode).cardBackgroundColor,
                  ),
                  margin: const EdgeInsets.only(top: 10),
                  child: IconButton(
                    icon: Icon(
                      CupertinoIcons.refresh_bold,
                      size: 18,
                    ),
                    onPressed: _onTapReset,
                  ),
                ),
                Expanded(child: Container()),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: appTheme(context, widget.userSettingsState.userSettings.themeMode).cardBackgroundColor,
                  ),
                  margin: const EdgeInsets.only(top: 10),
                  child: ButtonBar(
                    buttonPadding: EdgeInsets.zero,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          CupertinoIcons.chevron_left_2,
                          size: 18,
                        ),
                        onPressed: _onTapGoToStart,
                      ),
                      IconButton(
                        icon: Icon(
                          CupertinoIcons.chevron_left,
                          size: 18,
                        ),
                        onPressed: _onTapBackwardArrow,
                      ),
                      IconButton(
                        icon: Icon(
                          CupertinoIcons.chevron_right,
                          size: 18,
                        ),
                        onPressed: _onTapForwardArrow,
                      ),
                      IconButton(
                        icon: Icon(
                          CupertinoIcons.chevron_right_2,
                          size: 18,
                        ),
                        onPressed: _onTapGoToEnd,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: GameLiveAnalysisResults(
                gameMode: widget.gameMode,
                userSettingsState: widget.userSettingsState,
                liveAnalysisResponseStream: _liveAnalysisResponseStreamController.stream,
                fetchingLiveAnalysisResponse: _fetchingAnalysisData,
                noMovePlayedYet: _noMovePlayedYet,
                liveAnalysisActivated: _liveAnalysisActivated,
                onLiveAnalysisSwitchChanged: _onLiveAnalysisSwitchChange,
                errorMessage: _errorMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreAndFlipBoardHeader() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        StreamBuilder(
          stream: _evaluatedMoveStreamController.stream,
          builder: (final BuildContext context, final AsyncSnapshot<EvaluatedMove?> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Container();
              case ConnectionState.waiting:
                return Container();
              case ConnectionState.active:
              case ConnectionState.done:
                if (widget.userSettingsState.userSettings.moveEvaluationNotation == MoveEvaluationNotationEnum.pawnScore) {
                  final signedCpOrMateScore = snapshot.hasData ? snapshot.data!.signedCPScore : '+0.0';
                  return GamePawnOrMateScore(signedCpOrMateScore: signedCpOrMateScore);
                }
                final gmExpectation = snapshot.hasData ? snapshot.data!.gmExpectation : 0.5;
                return GameWinningChance(
                  grandmasterSide: widget.analyzedGame.gameAnalysis.grandmasterSide,
                  playerSide: GrandmasterSide.white,
                  gmExpectation: gmExpectation,
                );
            }
          },
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 10, right: 15),
            child: GameMoveHistory(
              gameMode: widget.gameMode,
              boardStream: _boardStreamController.stream,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 5),
          width: 20,
          height: 20,
          child: IconButton(
            icon: Icon(CupertinoIcons.arrow_up_arrow_down),
            padding: EdgeInsets.zero,
            iconSize: 20,
            onPressed: () => setState(() => _boardFlipped = !_boardFlipped),
          ),
        ),
      ],
    );
  }

  void _onLiveAnalysisSwitchChange(final bool newValue) {
    setState(() => _liveAnalysisActivated = newValue);

    if (newValue) {
      _analyseCurrentMove();
    } else {
      _fetchingAnalysisData = false;
    }
  }

  Future<void> _analyseCurrentMove() async {
    if (!_isInitialized || !_liveAnalysisActivated) {
      return;
    }

    if (_boardBefore == null) {
      setState(() {
        _errorMessage = null;
        _fetchingAnalysisData = false;
        _noMovePlayedYet = true;
      });
      return;
    }

    Future.delayed(Duration(milliseconds: 100), () async {
      setState(() {
        _fetchingAnalysisData = true;
        _noMovePlayedYet = false;
      });

      _boardStreamController.add(_newBoard!);

      final grandmasterSide = widget.analyzedGame.gameAnalysis.grandmasterSide.toString().split('.').last;
      final boardBeforeMoveFen = _boardBefore!.fen;
      final boardAfterMoveFen = _newBoard!.fen;
      final movePlayedSan = _movePlayed?.sanMove;
      // We do not want to detect game changer moves explicitly
      final lastOpponentMoveWasBlunder = false.toString();

      var queryParameters = {
        'grandmasterSide': grandmasterSide,
        'boardBeforeMoveFen': boardBeforeMoveFen,
        'boardAfterMoveFen': boardAfterMoveFen,
        'movePlayedSan': movePlayedSan,
        'lastOpponentMoveWasBlunder': lastOpponentMoveWasBlunder,
      };

      final endpointUri = getLiveAnalysisEndpoint(queryParameters);

      try {
        if (!mounted) {
          return;
        }

        final response = await http.get(endpointUri).timeout(const Duration(seconds: 15));

        if (!_liveAnalysisActivated) {
          return;
        }

        if (response.statusCode == 200) {
          final responseBody = response.body;
          final json = jsonDecode(responseBody);
          final liveAnalysisResponse = LiveAnalysisResponse.fromJson(json);
          _evaluatedMoveStreamController.add(liveAnalysisResponse.evaluatedMove);
          _liveAnalysisResponseStreamController.add(liveAnalysisResponse);
        } else {
          showAlertDialog(context, 'Fehler', 'Die Anfrage konnte nicht erfolgreich durchgeführt werden (Status Code: ${response.statusCode}). Bitte versuche es später eneut.');
        }

        setState(() {
          _errorMessage = null;
        });
      } on TimeoutException catch (_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _errorMessage = 'Die Anfrage hat zu lange gedauert. Bitte überprüfe deine Internetverbindung oder versuche es später erneut.';
        });
      } on SocketException catch (_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _errorMessage = 'Server nicht erreichbar. Bitte überprüfe deine Internetverbindung oder versuche es später erneut.';
        });
      } finally {
        if (mounted) {
          setState(() {
            _fetchingAnalysisData = false;
          });
        }
      }
    });
  }

  void _onTapReset() {
    if (_fetchingAnalysisData) {
      return;
    }
    _chessBoardController.reset!();
    _initializeChessboard();
  }

  void _initializeChessboard() {
    _isInitialized = false;
    for (var i = 0; i < widget.gameChessboardController.getMoveHistory!().moves.length; i++) {
      if (i == widget.gameChessboardController.getMoveHistory!().moves.length - 1) {
        _isInitialized = true;
      }
      final move = widget.gameChessboardController.getMoveHistory!().moves[i];
      _chessBoardController.makeMove!(move.sanMove);
    }
  }

  void _onTapGoToStart() {
    if (_fetchingAnalysisData) {
      return;
    }
    _isInitialized = false;
    while (_chessBoardController.hasPrevious!()) {
      _chessBoardController.backward!();
    }
    setState(() {
      _isInitialized = true;
      _noMovePlayedYet = true;
    });
  }

  void _onTapBackwardArrow() {
    if (_fetchingAnalysisData) {
      return;
    }
    if (_chessBoardController.hasPrevious!()) {
      _chessBoardController.backward!();
    }
  }

  void _onTapForwardArrow() {
    if (_fetchingAnalysisData) {
      return;
    }
    if (_chessBoardController.hasNext!()) {
      _chessBoardController.forward!();
    }
  }

  void _onTapGoToEnd() {
    if (_fetchingAnalysisData) {
      return;
    }
    _isInitialized = false;
    while (_chessBoardController.hasNext!()) {
      if (_chessBoardController.getNextPly!() == _chessBoardController.getMoveHistory!().moves.length - 1) {
        _isInitialized = true;
      }
      _chessBoardController.forward!();
    }
    _isInitialized = true;
  }

  bool _mustBoardBeFlipped(final BoardRotationEnum boardRotation) {
    return boardRotation == BoardRotationEnum.grandmaster && widget.analyzedGame.gameAnalysis.grandmasterSide == GrandmasterSide.black;
  }
}
