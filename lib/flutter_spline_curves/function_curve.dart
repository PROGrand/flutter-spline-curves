import 'package:flutter/widgets.dart';

import 'functions/generic_function.dart';

class FunctionCurve extends Curve {
  FunctionCurve(this.function);

  final GenericDoubleFunction function;

  @override
  double transformInternal(double t) {
    return function.value(t);
  }
}
