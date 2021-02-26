import 'package:flutter/widgets.dart';
import 'package:flutter_spline_curves/flutter_spline_curves/functions/generic_function.dart';

class FunctionCurve extends Curve {
  FunctionCurve(this.function);

  final GenericDoubleFunction function;

  @override
  double transformInternal(double t) {
    return function.value(t);
  }
}
