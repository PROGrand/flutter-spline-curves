import 'package:flutter/material.dart';
import 'functions/generic_function.dart';
import 'functions/interpolated_function_base.dart';
import 'functions/interpolated_function.dart';
import 'curve_painter.dart';
import 'point2d.dart';

final defaultPointWidget = ClipRRect(
  borderRadius: BorderRadius.circular(10.0),
  child: Container(
    width: 20.0,
    height: 20.0,
    color: Colors.blue,
  ),
);

final maxPoints = 12;

class FunctionPreview extends StatefulWidget {

  final GenericDoubleFunction function;
  final Color curveColor;
  final double curveWidth;

  FunctionPreview({
    Key key,
    @required this.function,
    this.curveColor = Colors.red,
    this.curveWidth = 3,
  });

  @override
  State<StatefulWidget> createState() {
    return _FunctionPreviewState(function);
  }
}

class _FunctionPreviewState extends State<FunctionPreview> {
  FunctionPainter painter;
  final GenericDoubleFunction function;

  _FunctionPreviewState(this.function) {
    this.painter = FunctionPainter(function);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: painter,
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          var stackedWidgets = <Widget>[];
          return Stack(
            children: stackedWidgets,
          );
        }));
  }
}
