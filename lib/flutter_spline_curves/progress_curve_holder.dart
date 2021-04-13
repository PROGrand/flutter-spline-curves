import 'curve_editor.dart';
import 'functions/interpolated_function_base.dart';
import 'point2d.dart';

class ProgressCurveHolder extends CurveHolder {
  ProgressCurveHolder(InterpolatedFunctionBase function,
      {required this.progressFunction})
      : super(function);

  final InterpolatedFunctionBase progressFunction;

  @override
  void update(List<Point2D> points) {
    super.update(points);
    progressFunction.update(points);
  }
}
