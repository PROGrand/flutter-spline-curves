import 'package:flutter/foundation.dart';

import 'fix_control_points.dart';
import 'monotonic.dart';
import '../point2d.dart';
import 'generic_function.dart';
import 'interpolated_function_base.dart';

final List<Point2D> default01points = [Point2D(0, 0), Point2D(1, 1)];

class InterpolatedFunction extends InterpolatedFunctionBase {

  InterpolatedFunction(
      GeneralFunctionFabric functionFabric,
      {int steps = 100,
      this.monotonic = true,
      required List<Point2D> points,
      bool clamped = true})
      : super(functionFabric, steps: steps, clamped: clamped) {
    update(points);
  }

  final bool monotonic;

  @override
  void update(List<Point2D> controlPoints) {
    var fixedControlPoints = fixControlPoints(controlPoints);
    functionFabric.setControlPoints(fixedControlPoints);
    interpolate();
    if (monotonic) {
      interpolatedPoints =
          removeNonMonotonic(fixedControlPoints, steps, interpolatedPoints);
    }
  }
}
