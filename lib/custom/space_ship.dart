import 'dart:math';
import 'package:numbers_puzzle/sprite/custom_sprite.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui' as ui;
import 'package:vector_math/vector_math_64.dart' as math;

class SpaceShip extends StatefulWidget {
  final double height;
  final double width;
  final Duration duration;
  final ui.Image ship;
  final ui.Image thrust;
  final bool showThrust;
  final math.Vector2? direction;

  const SpaceShip(
      {Key? key,
      required this.height,
      required this.width,
      this.duration = const Duration(milliseconds: 100),
      required this.ship,
      required this.thrust,
      this.showThrust = false,
      this.direction})
      : super(key: key);
  @override
  _SpaceShipState createState() => _SpaceShipState();
}

class _SpaceShipState extends State<SpaceShip> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: widget.height,
        width: widget.width,
        child: Stack(
          children: _constructChildren(Size(widget.width, widget.height)),
        ));
  }

  List<Widget> _constructChildren(Size size) {
    List<Widget> res = List.empty(growable: true);
    if (widget.showThrust) {
      if (widget.direction == null || widget.direction!.y > 0.0) {
        res.add(Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              key: const Key("0"),
              width: size.width / 2,
              height: size.height / 2,
              child: AnimatedCustomSpriteWidget(
                src: widget.thrust,
                tileSize: const Size(32, 32),
                duration: const Duration(milliseconds: 100),
                columnBegin: 0,
                columnEnd: 3,
                repeat: true,
                rotation: -pi / 2,
              ),
            )));
      }
      if (widget.direction == null || widget.direction!.y < 0.0) {
        res.add(Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              key: const Key("1"),
              width: size.width / 2,
              height: size.height / 2,
              child: AnimatedCustomSpriteWidget(
                src: widget.thrust,
                tileSize: const Size(32, 32),
                duration: const Duration(milliseconds: 100),
                columnBegin: 0,
                columnEnd: 3,
                repeat: true,
                rotation: pi / 2,
              ),
            )));
      }
      if (widget.direction == null || widget.direction!.x > 0.0) {
        res.add(Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              key: const Key("2"),
              width: size.width / 2,
              height: size.height / 2,
              child: AnimatedCustomSpriteWidget(
                src: widget.thrust,
                tileSize: const Size(32, 32),
                duration: const Duration(milliseconds: 100),
                columnBegin: 0,
                columnEnd: 3,
                repeat: true,
                rotation: pi,
              ),
            )));
      }
      if (widget.direction == null || widget.direction!.x < 0.0) {
        res.add(Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              key: const Key("3"),
              width: size.width / 2,
              height: size.height / 2,
              child: AnimatedCustomSpriteWidget(
                src: widget.thrust,
                tileSize: const Size(32, 32),
                duration: const Duration(milliseconds: 100),
                columnBegin: 0,
                columnEnd: 3,
                repeat: true,
              ),
            )));
      }
    }
    res.add(Align(
        alignment: Alignment.center,
        child: SizedBox(
          key: const Key("4"),
          width: size.width *3/4,
          height: size.height *3/4,
          child: AnimatedCustomSpriteWidget(
            src: widget.ship,
            tileSize: const Size(64, 64),
            duration: const Duration(milliseconds: 100),
            columnBegin: 0,
            columnEnd: 3,
            repeat: true,
            rotation: -pi / 2,
          ),
        )));
    return res;
  }
}
