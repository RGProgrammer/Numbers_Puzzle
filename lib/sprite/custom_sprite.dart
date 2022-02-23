import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:vector_math/vector_math_64.dart';
import 'dart:ui' as ui;

class SpriteRender extends RenderBox {
  ui.Image src;
  Size tileSize;
  int _numRow = 1;
  int get numRow => _numRow;
  int _numColumns = 1;
  int get numColumns => _numColumns;
  late int _currentRow;
  int get currentRow => _currentRow;
  set currentRow(int value) {
    if (value >= 0 && value < _numRow) {
      _currentRow = value;
      markNeedsPaint();
    }
  }

  late int _currentColumn;
  int get currentColumn => _currentColumn;
  set currentColumn(int value) {
    if (value >= 0 && value < _numColumns) {
      _currentColumn = value;
      markNeedsPaint();
    }
  }

  final Paint _paintObject = Paint();
  double _scale = 1.0;
  double _rotate = 0.0;
  final Matrix4 _transform = Matrix4.identity();

  SpriteRender(
      {required this.src,
      required this.tileSize,
      int column = 0,
      int row = 0,
      double rotation = 0.0})
      : super() {
    _numRow = src.height ~/ tileSize.height;
    _numColumns = src.width ~/ tileSize.width;
    _currentColumn = column;
    _currentRow = row;
    _rotate = rotation;
  }
  @override
  bool get isRepaintBoundary => true;
  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    _scale = min(constraints.biggest.width / tileSize.width,
        constraints.biggest.height / tileSize.height);
    _transform.setIdentity();
    _transform.scale(_scale);
    _transform.translate(tileSize.width / 2, tileSize.height / 2);
    _transform.rotate(Vector3(0.0, 0.0, 1.0), _rotate);
    _transform.translate(-tileSize.width / 2, -tileSize.height / 2);
    return constraints.biggest;
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    bool hitTarget = false;

    if (size.contains(position)) {
      hitTarget = true;
      result.add(BoxHitTestEntry(this, position));
    }
    return hitTarget;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    Canvas canvas = context.canvas;
    canvas.save();

    canvas.transform(_transform.storage);
    canvas.drawImageRect(
        src,
        Rect.fromLTWH(_currentColumn * tileSize.width,
            _currentRow * tileSize.height, tileSize.width, tileSize.height),
        Rect.fromLTWH(offset.dx, offset.dy, tileSize.width, tileSize.height),
        _paintObject);

    canvas.restore();
  }
}

class CustomSpriteWidget extends LeafRenderObjectWidget {
  final ui.Image source;
  final Size tileSize;
  final int column;
  final int row;
  final double? height;
  final double? width;
  final double rotation;
  const CustomSpriteWidget(
      {Key? key,
      required this.source,
      required this.tileSize,
      this.column = 0,
      this.row = 0,
      this.height,
      this.width,
      this.rotation = 0.0})
      : super(key: key);

  @override
  SpriteRender createRenderObject(BuildContext context) {
    return SpriteRender(
        src: source,
        tileSize: tileSize,
        column: column,
        row: row,
        rotation: rotation);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderObject renderObject) {
    renderObject as SpriteRender
      ..currentColumn = column
      ..currentRow = row;
  }
}

class AnimatedCustomSpriteWidget extends StatefulWidget {
  final ui.Image src;
  final Size tileSize;
  final Duration duration;
  final int columnBegin;
  final int columnEnd;
  final bool repeat;
  final bool reverse;
  final double rotation;
  const AnimatedCustomSpriteWidget({
    Key? key,
    required this.src,
    required this.tileSize,
    this.columnBegin = 0,
    this.columnEnd = 0,
    this.duration = const Duration(milliseconds: 100),
    this.repeat = false,
    this.reverse = false,
    this.rotation = 0.0,
  }) : super(key: key);
  @override
  _AnimatedCustomSpriteWidgetState createState() =>
      _AnimatedCustomSpriteWidgetState();
}

class _AnimatedCustomSpriteWidgetState extends State<AnimatedCustomSpriteWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = IntTween(begin: widget.columnBegin, end: widget.columnEnd)
        .animate(_controller);
    if (widget.repeat) {
      _controller.repeat(reverse: widget.reverse);
    } else {
      if (widget.reverse) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, _) {
          return CustomSpriteWidget(
            source: widget.src,
            tileSize: widget.tileSize,
            row: 0,
            column: _animation.value,
            rotation: widget.rotation,
          );
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
