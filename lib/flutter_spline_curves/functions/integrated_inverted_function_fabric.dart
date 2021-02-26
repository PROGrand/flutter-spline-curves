import 'dart:math';

import '../point2d.dart';
import 'generic_function.dart';
import 'interpolated_function.dart';

class IntegratedInvertedFunctionFabric extends GeneralDoubleFunctionFabric {
  IntegratedInvertedFunctionFabric(this.functionFabric);

  final GeneralFunctionFabric functionFabric;

  @override
  GenericDoubleFunction makeFunction() {
    return IntegratedInvertedFunction(functionFabric, points: controlPoints);
  }

  @override
  void setControlPoints(List<Point2D> controlPoints) {
    functionFabric.setControlPoints(controlPoints);
    super.setControlPoints(controlPoints);
  }
}

class IntegratedInvertedFunction extends InterpolatedFunction {
  IntegratedInvertedFunction(GeneralFunctionFabric functionFabric,
      {List<Point2D> points, bool monotonic, bool clamped})
      : super(functionFabric, points: points, monotonic: monotonic, clamped: clamped);

  void interpolate() {
    //var base = InterpolatedFunction(functionFabric, points: functionFabric.controlPoints, steps: steps);
    var base = functionFabric.makeFunction();
    integrate(base);
  }

  void integrate(GenericFunction f) {
    const subSteps = 10;
    var dX = 1.0 / (steps * subSteps);
    var sum = 0.0;
    var x = 0.0, xPrev = 0.0;
    var maxSum = 0.0;

    interpolatedPoints.clear();

    for (var n = 0; n < steps; n++) {
      var xx = xPrev;
      for (int m = 0; m < subSteps; m++) {
        var V = f.value(x);

        if (0 != V.y) {
          sum += (V.x - xPrev) / V.y;
        }

        xPrev = V.x;

        x += dX;
      }
      interpolatedPoints.add(Point2D(sum, xx));
      maxSum = max(maxSum, sum);
    }

    interpolatedPoints.add(Point2D(sum, 1));

    if (0 != maxSum) {
      for (var n = 0; n < steps + 1; n++) {
        var interpolatedPoint = interpolatedPoints[n];
        interpolatedPoint.setLocation(
            interpolatedPoint.x / maxSum, interpolatedPoint.y);
      }
    }
  }

  double abs(double d) {
    return d > 0 ? d : -d;
  }
}
