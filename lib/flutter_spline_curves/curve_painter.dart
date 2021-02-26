import 'package:flutter/material.dart';
import 'functions/generic_function.dart';
import 'functions/interpolated_function.dart';
import 'point2d.dart';
import 'dart:ui';

final defaultLinearControlPoints = [Point2D(0, 0), Point2D(1, 1)];

class FunctionPainter extends CustomPainter {
  bool shouldUpdate = false;
  Paint _curvePaint = Paint();
  Paint _pointsPaint = Paint();
  List<Point2D> _points = defaultLinearControlPoints;

  final GenericDoubleFunction function;

  FunctionPainter(
    this.function, {
    List<Point2D> points: const [],
    Color curveColor: Colors.red,
    Color pointsColor: Colors.transparent,
    double curveWidth: 3,
    double dotsSize: 5,
  }) {
    _curvePaint.color = curveColor;
    _curvePaint.strokeWidth = curveWidth;
    _pointsPaint.color = pointsColor;
    _pointsPaint.strokeWidth = dotsSize;
    updatePoints(points);
  }

  void updatePoints(List<Point2D> points) {
    _points = points;
    if (_points.length <= 2) {
      _points = defaultLinearControlPoints;
    }

    shouldUpdate = true;
  }

  List<Point2D> getPoints() {
    return _points;
  }

  @override
  void paint(Canvas canvas, Size size) {

    var points = <Point2D>[];
    for (var n = 0; n < 101; n++) {
      var x = n * (1.0 / 100);
      points.add(Point2D(x, function.value(x)));
    }

    // get points as drawable offsets
    var drawablePoints = pointsToOffsets(points, size);

    // draw curve
    canvas.drawPoints(PointMode.polygon, drawablePoints, _curvePaint);
  }

  List<Offset> pointsToOffsets(List<Point2D> points, Size size) {
    var result = <Offset>[];
    for (var point in points) {
      // invert y to get the mathematical coordinate system
      result.add(
          Offset(point.x * size.width, size.height - point.y * size.height));
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
