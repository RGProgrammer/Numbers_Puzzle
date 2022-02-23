import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as math;

class SpaceBackground extends RenderBox {
  double? height;
  double? width;
  Color background;
  Gradient? gradient;
  Color stars;
  final List<math.Vector2> _vStars = List.empty(growable: true);
  final Paint _bgrPaint = Paint();
  final Paint _starsPaint = Paint();
  SpaceBackground(
      this.height, this.width, this.background, this.gradient, this.stars) {
    _starsPaint.color = stars;
  }
  @override
  bool get isRepaintBoundary => true;
  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    double finalHeight = constraints.biggest.height;
    double finalWidth = constraints.biggest.width;
    if (height != null) {
      finalHeight = finalHeight < height! ? finalHeight : height!;
    }
    if (width != null) {
      finalWidth = finalWidth < width! ? finalWidth : width!;
    }
    _vStars.clear();
    int numStars = finalHeight * finalWidth ~/ 1000;
    Random rand = Random();
    for (; numStars >= 0; numStars--) {
      _vStars.add(math.Vector2(
          rand.nextDouble() * finalWidth, rand.nextDouble() * finalHeight));
    }
    return Size(finalWidth, finalHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    Canvas canvas = context.canvas;

    if (gradient != null) {
      _bgrPaint.shader = ui.Gradient.linear(
          offset,
          Offset(offset.dx + size.width, offset.dy + size.height),
          gradient!.colors);
    } else {
      _bgrPaint.color = background;
    }

    canvas.save();
    canvas.drawRect(
        Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height),
        _bgrPaint);
    for (var vector in _vStars) {
      canvas.drawRect(
          Rect.fromLTWH(offset.dx + vector.x, offset.dy + vector.y, 4, 4),
          _starsPaint);
    }
    canvas.restore();
  }
}

class SpaceBackgroundWidget extends LeafRenderObjectWidget {
  final double? height;
  final double? width;
  final Color background;
  final Gradient? gradient;
  final Color stars;

  const SpaceBackgroundWidget(
      {Key? key,
      this.height,
      this.width,
      this.background = Colors.black,
      this.gradient,
      this.stars = Colors.white})
      : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return SpaceBackground(height, width, background, gradient, stars);
  }
}
