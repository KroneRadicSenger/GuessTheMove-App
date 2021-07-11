enum GameModeEnum { findTheGrandmasterMoves, timeBattle, survivalMode, puzzleMode }

String getGameModeName(final GameModeEnum gameMode) {
  switch (gameMode) {
    case GameModeEnum.findTheGrandmasterMoves:
      return 'Finde die Züge des Großmeisters';
    case GameModeEnum.timeBattle:
      return 'Spiele gegen die Zeit';
    case GameModeEnum.survivalMode:
      return 'Spiele um dein Überleben';
    case GameModeEnum.puzzleMode:
      return 'Puzzle lösen';
  }
}

String getGameModeShortName(final GameModeEnum gameMode) {
  switch (gameMode) {
    case GameModeEnum.findTheGrandmasterMoves:
      return 'GM-Züge finden';
    case GameModeEnum.timeBattle:
      return 'Zeitdruck';
    case GameModeEnum.survivalMode:
      return 'Überleben';
    case GameModeEnum.puzzleMode:
      return 'Puzzle';
  }
}
