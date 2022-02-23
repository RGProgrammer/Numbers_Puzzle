import 'package:numbers_puzzle/custom/space_ship.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:vector_math/vector_math_64.dart' as math;

class AnimatedSpaceShip extends ImplicitlyAnimatedWidget {
  final math.Vector2 centerPosition;
  final void Function()? onBegin;
  final void Function()? onComplete;
  final void Function()? onTap;
  final ui.Image ship;
  final ui.Image thrust;
  final double height;
  final double width;
  final String text;

  const AnimatedSpaceShip(
      {Key? key,
      required this.centerPosition,
      required Duration duration,
      required this.ship,
      required this.thrust,
      this.height = 100,
      this.width = 100,
      Curve curve = Curves.easeOut,
      this.text = "",
      this.onBegin,
      this.onComplete,
      this.onTap})
      : super(key: key, duration: duration, curve: curve);
  @override
  AnimatedSpaceShipState createState() => AnimatedSpaceShipState();
}

class AnimatedSpaceShipState
    extends AnimatedWidgetBaseState<AnimatedSpaceShip> {
  Tween<double>? _verticalTween;
  Tween<double>? _horizontalTween;
  final Matrix4 _transform = Matrix4.identity();
  final math.Vector3 _position = math.Vector3(0.0, 0.0, 0.0);
  final math.Vector3 _actualPosition = math.Vector3(0.0, 0.0, 0.0);
  final math.Vector2 _direction = math.Vector2(0.0, 0.0);
  bool _showThrust = false;

  void _statusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      if (widget.onComplete != null) {
        widget.onComplete!.call();
      }
      _showThrust = false;
      _direction.setValues(0.0, 0.0);
    } else if (status == AnimationStatus.forward ||
        status == AnimationStatus.reverse) {
      if (widget.onBegin != null) {
        widget.onBegin!.call();
      }
      _showThrust = true;
    }
  }

  @override
  void initState() {
    super.initState();
    controller.addStatusListener(_statusListener);
  }

  @override
  Widget build(BuildContext context) {
    _actualPosition.setValues(_horizontalTween!.evaluate(animation),
        _verticalTween!.evaluate(animation), 0.0);
    _position.setValues(_actualPosition.x - widget.width / 2,
        _actualPosition.y - widget.height / 2, 0.0);
    _direction.setValues(_actualPosition.x - _horizontalTween!.begin!,
        _actualPosition.y - _verticalTween!.begin!);

    _transform
      ..setIdentity()
      ..translate(_position);
    return Container(
        transform: _transform,
        height: widget.height,
        width: widget.width,
        child: GestureDetector(
            onTap: widget.onTap,
            child: Stack(children: [
              SpaceShip(
                height: widget.height,
                width: widget.width,
                ship: widget.ship,
                thrust: widget.thrust,
                direction: _direction,
                showThrust: _showThrust,
              ),
              Center(
                  child: SizedBox(
                      height: widget.height * 0.291,
                      width: widget.width * 0.291,
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: FittedBox(
                          fit: BoxFit.fitHeight,
                          child: Text(
                            widget.text,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: "PixelFont",
                            ),
                          ),
                        ),
                      )))
            ])));
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _verticalTween = visitor(_verticalTween, widget.centerPosition.y,
            (dynamic value) => Tween<double>(begin: value as double))
        as Tween<double>?;
    _horizontalTween = visitor(_horizontalTween, widget.centerPosition.x,
            (dynamic value) => Tween<double>(begin: value as double))
        as Tween<double>?;
  }
}
