import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numbers_puzzle/assistant/bloc/assistant_bloc.dart';
import 'package:numbers_puzzle/assistant/bloc/assistant_event.dart';
import 'package:numbers_puzzle/custom/animated_space_ship.dart';
import 'package:numbers_puzzle/models/models.dart';
import 'package:numbers_puzzle/models/utility.dart';
import 'package:numbers_puzzle/puzzle/puzzle.dart';
import 'package:numbers_puzzle/models/assets.dart';
import 'package:vector_math/vector_math_64.dart' as math;
import 'assistant/assistant_layout.dart';
import 'custom/space_background.dart';
import 'dart:ui' as ui;

import 'timer/bloc/timer_bloc.dart';

class PuzzleView extends StatefulWidget {
  const PuzzleView({Key? key}) : super(key: key);

  @override
  State<PuzzleView> createState() => _PuzzleViewState();
}

class _PuzzleViewState extends State<PuzzleView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocProvider(
            create: (context) => TimerBloc(
                  ticker: const Ticker(),
                ),
            child: BlocProvider(
                create: (context) => PuzzleBloc(4)
                  ..add(
                    const PuzzleInitialized(
                      shufflePuzzle: true,
                    ),
                  ),
                child: BlocProvider(
                    create: (context) =>
                        AssistantBloc()..add(const ResetToIdle()),
                    child: Stack(
                      children: [
                        const SpaceBackgroundWidget(),
                        LayoutBuilder(builder: (context, constraints) {
                          if (constraints.maxHeight > constraints.maxWidth) {
                            return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 10),
                                child: Column(children: [
                                  Expanded(flex: 3, child: _PuzzleHeader()),
                                  Expanded(flex: 6, child: _PuzzleCore()),
                                  const Spacer(flex: 1)
                                ]));
                          } else {
                            return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                child: Row(children: [
                                  Expanded(flex: 3, child: _PuzzleHeader()),
                                  Expanded(flex: 6, child: _PuzzleCore()),
                                  const Spacer(flex: 1)
                                ]));
                          }
                        }),
                        const AssistantLayout(),
                      ],
                    )))));
  }
}

class _PuzzleHeader extends StatefulWidget {
  @override
  __PuzzleHeaderState createState() => __PuzzleHeaderState();
}

class __PuzzleHeaderState extends State<_PuzzleHeader> {
  @override
  Widget build(BuildContext context) {
    final _timerState = context.select((TimerBloc bloc) => bloc.state);
    final _puzzleState = context.select((PuzzleBloc bloc) => bloc.state);

    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              color: Colors.black,
              padding: const EdgeInsets.all(2),
              child: Text(getTimeString(_timerState.secondsElapsed),
                  style: const TextStyle(
                      fontFamily: "PixelFont",
                      color: Colors.white,
                      fontSize: 40))),
          Container(
            height: 20,
          ),
          Container(
              color: Colors.black,
              padding: const EdgeInsets.all(2),
              child: Text(
                  "${_puzzleState.numberOfMoves}  Moves   |   ${_puzzleState.puzzle.tiles.length - 1} Tiles",
                  style: const TextStyle(
                      fontFamily: "PixelFont",
                      color: Colors.white,
                      fontSize: 26))),
        ]);
  }
}

class _PuzzleCore extends StatefulWidget {
  @override
  __PuzzleCoreState createState() => __PuzzleCoreState();
}

class __PuzzleCoreState extends State<_PuzzleCore> with WidgetsBindingObserver {
  final ui.Image _ship = Sprites.ship!;
  final ui.Image _thrust = Sprites.thrust!;
  bool _timerstarted = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (_timerstarted) {
      final timerbloc = context.read<TimerBloc>();
      if (state == AppLifecycleState.paused ) {
        timerbloc.add(const TimerStopped());
      } else if (state == AppLifecycleState.resumed) {
        timerbloc.add(const TimerStarted());
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _puzzleState = context.select((PuzzleBloc bloc) => bloc.state);
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Center(
          child: (AspectRatio(
              aspectRatio: 1,
              child: LayoutBuilder(builder: (context, contraints) {
                double _spriteSize = contraints.maxHeight / 4;

                return Stack(
                    children: _generateChildrenFromPuzzle(
                        _puzzleState, _spriteSize, contraints.biggest));
              }))),
        ));
  }

  math.Vector2 _positionToActualPosition(
      Size containerSize, Size spriteSize, int puzzleSize, Position position) {
    return math.Vector2(
        (containerSize.width / puzzleSize) * (position.x - 1) +
            spriteSize.width / 2,
        (containerSize.height / puzzleSize) * (position.y - 1) +
            spriteSize.height / 2);
  }

  List<Widget> _generateChildrenFromPuzzle(
      PuzzleState puzzleState, double spriteSize, Size containerSize) {
    List<Widget> _tiles = List.empty(growable: true);
    for (var tile in puzzleState.puzzle.tiles) {
      if (!tile.isWhitespace) {
        _tiles.add(
          AnimatedSpaceShip(
              key: Key("tile_${tile.value}"),
              onTap: puzzleState.puzzleStatus == PuzzleStatus.incomplete
                  ? () {
                      TimerBloc timerBloc = context.read<TimerBloc>();
                      if (!timerBloc.state.isRunning) {
                        timerBloc.add(const TimerStarted());
                        _timerstarted = true;
                      }
                      context.read<PuzzleBloc>().add(TileTapped(tile));
                    }
                  : null,
              height: spriteSize,
              width: spriteSize,
              text: tile.value.toString(),
              centerPosition: _positionToActualPosition(
                  containerSize,
                  Size(spriteSize, spriteSize),
                  puzzleState.puzzle.getDimension(),
                  tile.currentPosition),
              duration: const Duration(milliseconds: 500),
              ship: _ship,
              thrust: _thrust),
        );
      }
    }
    return _tiles;
  }
}
