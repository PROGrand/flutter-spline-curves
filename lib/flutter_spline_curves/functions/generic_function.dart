import '../point2d.dart';

/// Non-monotonic functions class.
abstract class GenericFunction {
  Point2D value(double position);

  void update(List<Point2D> controlPoints){}
}

abstract class GenericDoubleFunction {
  double value(double position);

  void update(List<Point2D> controlPoints){}
}

abstract class GeneralFunctionFabric {
  GenericFunction makeFunction();

  List<Point2D> controlPoints;

  void setControlPoints(List<Point2D> controlPoints) {
    this.controlPoints = controlPoints;
  }
}

abstract class GeneralDoubleFunctionFabric {
  GenericDoubleFunction makeFunction();

  List<Point2D> controlPoints;

  void setControlPoints(List<Point2D> controlPoints) {
    this.controlPoints = controlPoints;
  }
}
