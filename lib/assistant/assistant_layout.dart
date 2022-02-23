import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numbers_puzzle/assistant/bloc/assistant_bloc.dart';
import 'package:numbers_puzzle/assistant/bloc/assistant_event.dart';
import 'package:numbers_puzzle/assistant/bloc/assistant_state.dart'
    as assistant;
import 'package:numbers_puzzle/custom/space_ship.dart';
import 'package:numbers_puzzle/models/assets.dart';
import 'package:numbers_puzzle/models/utility.dart';
import 'package:numbers_puzzle/puzzle/bloc/puzzle_bloc.dart';
import 'package:numbers_puzzle/sprite/custom_sprite.dart';

import 'dart:ui' as ui;

import 'package:numbers_puzzle/timer/timer.dart';

class AssistantLayout extends StatefulWidget {
  const AssistantLayout({Key? key}) : super(key: key);

  @override
  _AssistantLayoutState createState() => _AssistantLayoutState();
}

class _AssistantLayoutState extends State<AssistantLayout> {
  final ui.Image? _assistant = Sprites.assistant;

  @override
  Widget build(BuildContext context) {
    final _assistantState = context.select((AssistantBloc bloc) => bloc.state);
    final _timerState = context.select((TimerBloc bloc) => bloc.state);
    final _puzzleState = context.select((PuzzleBloc bloc) => bloc.state);
    final _puzzleSize = _puzzleState.puzzle.getDimension();

    return Stack(children: [
      Container(
          color: (_assistantState.current != assistant.State.idle)
              ? Colors.black.withAlpha(200)
              : null),
      LayoutBuilder(builder: (context, constraints) {
        return Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
                flex: 15,
                child: (_assistantState.current == assistant.State.idle)
                    ? Container()
                    : LayoutBuilder(builder: (context, constraints) {
                        return Container(
                            margin: const EdgeInsets.fromLTRB(10, 50, 10, 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.yellow,
                              border:
                                  Border.all(color: Colors.orange, width: 5),
                            ),
                            child: _puzzleState.puzzle.isComplete()
                                ? _generateCongratsDialog(
                                    _timerState.secondsElapsed,
                                    _puzzleState.numberOfMoves)
                                : _assistantState.current ==
                                        assistant.State.helpSeggestions
                                    ? _generateHelpDialog()
                                    : _generateTutorialDialog(_puzzleSize));
                      })),
            //
            Expanded(
                flex: 3,
                child: Container(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              alignment: Alignment.center,
                              margin: const EdgeInsets.all(5),
                              padding: const EdgeInsets.all(2),
                              color: Colors.black,
                              height: 30,
                              child: (_assistantState.current ==
                                      assistant.State.idle)
                                  ? const FittedBox(
                                      fit: BoxFit.fitHeight,
                                      child: Text("Click Me\nif you need\nHelp",
                                          maxLines: 4,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontFamily: "PixelFont",
                                              color: Colors.white)),
                                    )
                                  : const FittedBox(
                                      fit: BoxFit.fitHeight,
                                      child: Text("Click me\n To Dismiss \n",
                                          maxLines: 4,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontFamily: "PixelFont",
                                              color: Colors.white)),
                                    )),
                          Container(
                              height: 100,
                              width: 100,
                              padding: const EdgeInsets.all(5),
                              child: GestureDetector(
                                onTap: () {
                                  final assistantBloc =
                                      context.read<AssistantBloc>();
                                  final timerBloc = context.read<TimerBloc>();
                                  if (assistantBloc.state.current ==
                                      assistant.State.idle) {
                                    timerBloc.add(const TimerStopped());
                                    assistantBloc.add(const ShowHelp());
                                  } else {
                                    timerBloc.add(const TimerStarted());
                                    assistantBloc.add(const ResetToIdle());
                                  }
                                },
                                child: CustomSpriteWidget(
                                  source: _assistant!,
                                  tileSize: const Size(64, 64),
                                  column: _assistantState.current ==
                                          assistant.State.idle
                                      ? 1
                                      : 0,
                                ),
                              ))
                        ])))
          ],
        );
      })
    ]);
  }

  Widget _generateSortedPuzzle(int size) {
    return LayoutBuilder(builder: (context, constraints) {
      double _spriteSize = min(constraints.maxHeight, constraints.maxWidth) / 4;
      List<Row> rows = List.generate(
          size,
          (rowIndex) => Row(
                mainAxisSize: MainAxisSize.max,
                children: List.generate(
                    size,
                    (columnIndex) => (size * rowIndex + columnIndex + 1) !=
                            size * size
                        ? SizedBox(
                            height: _spriteSize,
                            width: _spriteSize,
                            child: Stack(children: [
                              SpaceShip(
                                height: _spriteSize,
                                width: _spriteSize,
                                ship: Sprites.ship,
                                thrust: Sprites.thrust,
                              ),
                              Center(
                                  child: SizedBox(
                                      height: _spriteSize * 0.291,
                                      width: _spriteSize * 0.291,
                                      child: Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: FittedBox(
                                          fit: BoxFit.fitHeight,
                                          child: Text(
                                            (size * rowIndex + columnIndex + 1)
                                                .toString(),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontFamily: "PixelFont",
                                            ),
                                          ),
                                        ),
                                      )))
                            ]),
                          )
                        : SizedBox(
                            height: _spriteSize,
                            width: _spriteSize,
                          )),
              ));
      return AspectRatio(
          aspectRatio: 1,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: rows,
          ));
    });
  }

  Widget _generateCongratsDialog(int time, int moves) {
    return Column(
      key: const Key("key_congrats"),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Congratulations",
            style: TextStyle(
                fontFamily: "PixelFont", fontSize: 22, color: Colors.black)),
        Text("Solved in ${getTimeString(time)}",
            style: const TextStyle(
                fontFamily: "PixelFont", fontSize: 22, color: Colors.black)),
        Text("and in $moves moves",
            style: const TextStyle(
                fontFamily: "PixelFont", fontSize: 22, color: Colors.black)),
        Container(
          height: 10,
        ),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.orange),
          ),
          onPressed: () {
            context
                .read<PuzzleBloc>()
                .add(const PuzzleInitialized(shufflePuzzle: true));
            context.read<TimerBloc>().add(const TimerReset());
            context.read<AssistantBloc>().add(const ResetToIdle());
          },
          child: const Text("Shuffle",
              style: TextStyle(
                  fontFamily: "PixelFont", fontSize: 22, color: Colors.white)),
        )
      ],
    );
  }

  Widget _generateHelpDialog() {
    return Column(
      key: const Key("key_help"),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("How can I help you?",
            style: TextStyle(
                fontFamily: "PixelFont", fontSize: 22, color: Colors.black)),
        Container(
          height: 10,
        ),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.orange),
          ),
          onPressed: () {
            context.read<AssistantBloc>().add(const ShowTutorial());
          },
          child: const Text("Tutorial",
              style: TextStyle(
                  fontFamily: "PixelFont", fontSize: 22, color: Colors.white)),
        ),
        Container(
          height: 5,
        ),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.orange),
          ),
          onPressed: () {
            context
                .read<PuzzleBloc>()
                .add(const PuzzleInitialized(shufflePuzzle: true));
            context.read<TimerBloc>().add(const TimerReset());
            context.read<AssistantBloc>().add(const ResetToIdle());
          },
          child: const Text("Shuffle",
              style: TextStyle(
                  fontFamily: "PixelFont", fontSize: 22, color: Colors.white)),
        )
      ],
    );
  }

  Widget _generateTutorialDialog(int size) {
    return Column(
        key: const Key("key_tutorial"),
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Expanded(
              flex: 1,
              child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                      "You need to move the space ships around \nuntil they are sorted",
                      //overflow: TextOverflow.visible,
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: "PixelFont",
                          fontSize: 22,
                          color: Colors.black)))),
          Expanded(
              flex: 7,
              child: SizedBox.expand(
                  child: Center(child: _generateSortedPuzzle(size)))),
          const Expanded(
              flex: 1,
              child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                      "You have to do it in the shortest amount of time",
                      style: TextStyle(
                          fontFamily: "PixelFont",
                          fontSize: 22,
                          color: Colors.black),
                      textAlign: TextAlign.center))),
          Expanded(
              flex: 1,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.orange),
                ),
                onPressed: () {
                  context.read<AssistantBloc>().add(const ShowHelp());
                },
                child: const Text("Ok",
                    style: TextStyle(
                        fontFamily: "PixelFont",
                        fontSize: 22,
                        color: Colors.white)),
              )),
        ]);
  }
}
