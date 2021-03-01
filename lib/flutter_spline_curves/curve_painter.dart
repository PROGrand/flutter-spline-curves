import 'package:flutter/material.dart';
import 'functions/generic_function.dart';
import 'functions/interpolated_function.dart';
import 'point2d.dart';
import 'dart:ui';

final defaultLinearControlPoints = [Point2D(0, 0), Point2D(1, 1)];

class FunctionPainter extends CustomPainter {
  bool shouldUpdate = false;
  Paint _curvePaint = Paint();
  final double border;

  final GenericDoubleFunction function;

  FunctionPainter(this.function,
      {List<Point2D> points: const [],
      Color curveColor: Colors.red,
      Color pointsColor: Colors.transparent,
      double curveWidth: 3,
      double dotsSize: 5,
      this.border: 0}) {
    _curvePaint.color = curveColor;
    _curvePaint.strokeWidth = curveWidth;
    updatePoints(points);
  }

  void updatePoints(List<Point2D> points) {
    shouldUpdate = true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var points = <Point2D>[];
    for (var n = 0; n < 101; n++) {
      var x = n * (1.0 / 100);
      points.add(Point2D(x, function.value(x)));
    }

    var drawablePoints = pointsToOffsets(points, size);

    canvas.drawPoints(PointMode.polygon, drawablePoints, _curvePaint);
  }

  List<Offset> pointsToOffsets(List<Point2D> points, Size size) {
    var result = <Offset>[];
    for (var point in points) {
      // invert y to get the mathematical coordinate system
      result.add(Offset(point.x * (size.width - 2 * border) + border,
          (size.height - 2 * border) - point.y * (size.height - 2 * border) + border));
    }
    return result;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    if (shouldUpdate) {
      shouldUpdate = false;
      return true;
    }
    return shouldUpdate;
  }
}
