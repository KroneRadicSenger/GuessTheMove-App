import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/puzzle_bloc.dart';

typedef int PuzzleTimerGetTimePassedInMilliseconds();
typedef void PuzzleTimerPause();
typedef void PuzzleTimerResume();

class PuzzleTimerController {
  PuzzleTimerGetTimePassedInMilliseconds? getTimePassedInMilliseconds;
  PuzzleTimerPause? pause;
  PuzzleTimerResume? resume;

  void dispose() {
    this.getTimePassedInMilliseconds = null;
    this.pause = null;
    this.resume = null;
  }
}

class PuzzleTimer extends StatefulWidget {
  final PuzzleTimerController controller;

  const PuzzleTimer({Key? key, required this.controller}) : super(key: key);

  @override
  _PuzzleTimerState createState() => _PuzzleTimerState();
}

class _PuzzleTimerState extends State<PuzzleTimer> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    widget.controller.pause = _stopTimer;
    widget.controller.resume = _resumeTimer;
    widget.controller.getTimePassedInMilliseconds = () {
      return _stopwatch.elapsedMilliseconds;
    };

    WidgetsBinding.instance!.addPostFrameCallback((_) => _startTimer());
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PuzzleBloc, PuzzleState>(
      listenWhen: (previousState, state) {
        return (!(previousState is PuzzleGuessMove) && state is PuzzleGuessMove) || (previousState is PuzzleGuessMove && !(state is PuzzleGuessMove));
      },
      listener: (context, state) {
        if (state is PuzzleGuessMove && state.isNewPuzzle) {
          if (!mounted) {
            return;
          }
          setState(_startTimer);
          return;
        }

        if (state is PuzzleCorrectMove) {
          if (!mounted) {
            return;
          }
          setState(_stopTimer);
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timer),
          Container(width: 10),
          Text(_getElapsedTimeString()),
        ],
      ),
    );
  }

  void _startTimer() {
    _stopwatch.reset();
    _resumeTimer();
  }

  void _resumeTimer() {
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        if (_timer != null) {
          _timer!.cancel();
        }
        _stopwatch.reset();
        return;
      }
      setState(() {});
    });
  }

  void _stopTimer() {
    _stopwatch.stop();
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = null;
  }

  String _getElapsedTimeString() {
    final hundreds = (_stopwatch.elapsedMilliseconds / 10).truncate();
    final seconds = (hundreds / 100).truncate();
    final minutes = (seconds / 60).truncate();

    final minutesString = (minutes % 60).toString().padLeft(2, '0');
    final secondsString = (seconds % 60).toString().padLeft(2, '0');
    final hundredsString = (hundreds % 100).toString().padLeft(2, '0');

    return '$minutesString:$secondsString:$hundredsString';
  }
}
