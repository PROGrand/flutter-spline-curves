import 'package:flutter/widgets.dart';
import 'interpolated_function.dart';
import 'generic_function.dart';
import '../point2d.dart';

class CatmullRomSplineFabric extends GeneralDoubleFunctionFabric {
  @override
  GenericDoubleFunction makeFunction() {
    return CatmullRomSplineFunction(controlPoints);
  }
}

class CatmullRomSplinePointFabric extends GeneralFunctionFabric {
  @override
  GenericFunction makeFunction() {
    return CatmullRomSplinePointFunction(controlPoints);
  }
}

class CatmullRomSplineFunction extends InterpolatedFunction {
  CatmullRomSplineFunction(List<Point2D> controlPoints,
      {bool monotonic, bool clamped})
      : super(CatmullRomSplinePointFabric(),
            points: controlPoints, monotonic: monotonic, clamped: clamped);
}

class CatmullRomSplinePointFunction extends GenericFunction {
  CatmullRomSplinePointFunction(List<Point2D> controlPoints)
      : spline = CatmullRomSpline(controlPoints
            .map<Offset>((point) => Offset(point.x, point.y))
            .toList(growable: false));
  final CatmullRomSpline spline;

  @override
  Point2D value(double position) {
    var offset = spline.transform(position);
    return Point2D(offset.dx, offset.dy);
  }
}
