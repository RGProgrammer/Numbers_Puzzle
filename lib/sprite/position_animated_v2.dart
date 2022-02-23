import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math_64.dart' as math;

class AnimatedPositionV2 extends ImplicitlyAnimatedWidget {
  final Widget? child;
  final math.Vector2 centerPosition;
  final void Function()? onBegin;
  final void Function()? onComplete;
  const AnimatedPositionV2(
      {Key? key,
      this.child,
      required this.centerPosition,
      required Duration duration,
      Curve curve = Curves.easeOut,
      this.onBegin,
      this.onComplete})
      : super(key: key, duration: duration, curve: curve);
  @override
  AnimatedPositionV2State createState() => AnimatedPositionV2State();
}

class AnimatedPositionV2State
    extends AnimatedWidgetBaseState<AnimatedPositionV2> {
  Tween<double>? _verticalTween;
  Tween<double>? _horizontalTween;
  final Matrix4 _transform = Matrix4.identity();
  final math.Vector3 _position = math.Vector3(0.0, 0.0, 0.0);

  void _statusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      if (widget.onComplete != null) {
        widget.onComplete!.call();
      }
    } else if (status == AnimationStatus.forward ||
        status == AnimationStatus.reverse) {
      if (widget.onBegin != null) {
        widget.onBegin!.call();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    controller.addStatusListener(_statusListener);
  }

  @override
  Widget build(BuildContext context) {
   
    _position.setValues(_horizontalTween!.evaluate(animation) ,
        _verticalTween!.evaluate(animation), 0.0);
    _transform
      ..setIdentity()
      ..translate(_position);
    return Container(
      transform: _transform,
      child: widget.child,
    );
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
