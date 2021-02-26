import 'package:flutter/widgets.dart';
import 'generic_function.dart';
import '../point2d.dart';

final List<Point2D> default01points = [Point2D(0, 0), Point2D(1, 1)];

abstract class InterpolatedFunctionBase extends GenericDoubleFunction {
  InterpolatedFunctionBase(this.functionFabric,
      {this.steps = 100, this.clamped = true});

  GeneralFunctionFabric functionFabric;
  final int steps;
  final bool clamped;

  List<Point2D> interpolatedPoints = [Point2D(0, 0), Point2D(1, 1)];

  List<Point2D> getInterpolatedPoints() {
    return interpolatedPoints;
  }

  void interpolate() {
    var baseFunc = functionFabric.makeFunction();

    var func;

    if (clamped) {
      func = (x) {
        var point = baseFunc.value(x);
        return Point2D(point.x.clamp(0.0, 1.0), point.y.clamp(0.0, 1.0));
      };
    } else {
      func = (x) {
        return baseFunc.value(x);
      };
    }

    interpolatedPoints.clear();

    for (int n = 0; n < steps + 1; n++) {
      var dx = n * (1.0 / steps);
      interpolatedPoints.add(func(dx));
    }
  }

  // linear approximation of the spline function for given value
  @override
  double value(double position) {
    var interpolatedPoints = getInterpolatedPoints();
    if (position < 0) position = 0;
    if (position > 1) position = 1;
    //
    if (position == 0) return interpolatedPoints.first.y;
    if (position == 1) return interpolatedPoints.last.y;

    // find the first point where x > position
    var index = 1;
    for (var i = 1; i < interpolatedPoints.length; i++) {
      if (position < interpolatedPoints[i].x) {
        index = i;
        break;
      }
    }

    // if (0 == index) {
    //   print('test');
    // }
    //
    // if (1 == interpolatedPoints.length) {
    //   print('test2');
    // }

    // linear between this and previous point
    var k = (interpolatedPoints[index].y - interpolatedPoints[index - 1].y) /
        (interpolatedPoints[index].x - interpolatedPoints[index - 1].x);
    var n = interpolatedPoints[index].y - k * interpolatedPoints[index].x;
    var result = k * position + n;

    if (result < 0) result = 0;
    if (result > 1) result = 1;
    return result;
  }

  @override
  void update(List<Point2D> controlPoints){}
}
