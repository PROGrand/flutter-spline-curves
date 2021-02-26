import 'package:flutter/material.dart';
import 'function_curve.dart';
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

final defaultStartingPointWidget = ClipRRect(
  borderRadius: BorderRadius.circular(10.0),
  child: Container(
    width: 20.0,
    height: 20.0,
    color: Colors.greenAccent,
  ),
);

final maxPoints = 12;

abstract class CurveHolder {
  CurveHolder(this.function);

  final InterpolatedFunctionBase function;

  void update(List<Point2D> points) {
    function.update(points);
  }
}

class CurveEditor extends StatefulWidget {
  final CurveHolder curveHolder;
  final List<Point2D> points;
  final List<Point2D> fixedPoints;
  final Color curveColor;
  final double curveWidth;
  final Widget pointWidget;
  final Widget startingPointWidget;
  final double pointWidgetSize;

  CurveEditor({
    Key key,
    @required this.curveHolder,
    @required this.points,
    List<Point2D> fixedPoints,
    this.curveColor = Colors.red,
    this.curveWidth = 3,
    Widget pointWidget,
    Widget startingPointWidget,
    this.pointWidgetSize = 20,
  })  : pointWidget = pointWidget ?? defaultPointWidget,
        startingPointWidget = startingPointWidget ?? defaultStartingPointWidget,
        fixedPoints = List.unmodifiable(fixedPoints ?? []);

  @override
  State<StatefulWidget> createState() {
    return _CurveEditorState(curveHolder, points);
  }
}

class _CurveEditorState extends State<CurveEditor> {
  List<Point2D> points;
  FunctionPainter painter;
  final CurveHolder curveHolder;

  _CurveEditorState(this.curveHolder, List<Point2D> points) {
    this.points = points;
    this.painter = FunctionPainter(curveHolder.function, points: this.points);
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
          // add points
          var stackedWidgets = <Widget>[];
          for (var point in points) {
            var isFixed = -1 != widget.fixedPoints.indexOf(point);

            var xPosition =
                point.x * constraints.maxWidth - widget.pointWidgetSize / 2;

            stackedWidgets.add(Positioned(
                left: xPosition,
                top: constraints.maxHeight -
                    point.y * constraints.maxHeight -
                    widget.pointWidgetSize / 2,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      var dx = isFixed ? 0 : details.delta.dx;
                      var dy = details.delta.dy;

                      var newX = (point.x * constraints.maxWidth + dx) /
                          constraints.maxWidth;

                      var newY = (point.y * constraints.maxHeight - dy) /
                          constraints.maxHeight;

                      if (-widget.pointWidgetSize / 2 <= newX &&
                          newX <= 1 + widget.pointWidgetSize / 2 &&
                          0 <= newY &&
                          newY <= 1) {
                        point.setLocation(newX, newY);
                        updatePoints();
                      }
                    });
                  },
                  onTap: () {
                    print('tap');
                  },
                  child: Container(
                      width: widget.pointWidgetSize,
                      height: widget.pointWidgetSize,
                      child: isFixed
                          ? widget.startingPointWidget
                          : widget.pointWidget),
                )));
          }

          // add gesture detector for adding new points
          stackedWidgets.add(Positioned.fill(child: GestureDetector(
            onTapUp: (TapUpDetails details) {
              RenderBox getBox = context.findRenderObject();
              Offset localOffset = getBox.globalToLocal(details.globalPosition);

              // only add if no point is within 4*r=2*pointWidgetSize
              var canAdd = true;
              var pointTapped = false;

              for (var point in points) {
                var isFixed = -1 != widget.fixedPoints.indexOf(point);

                var x =
                    point.x * constraints.maxWidth - widget.pointWidgetSize / 2;
                var y = point.y * constraints.maxHeight -
                    widget.pointWidgetSize / 2;

                if ((localOffset.dx - x).abs() < widget.pointWidgetSize * 2 &&
                    (constraints.maxHeight - localOffset.dy - y).abs() <
                        widget.pointWidgetSize * 2) {
                  canAdd = false;

                  // show remove dialog
                  // if (!(point.x == 0 && point.y == 0) &&
                  //     !(point.x == 1 && point.y == 1)) {
                  if (!isFixed) {
                    pointTapped = true;
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: new Text("Remove point?"),
                            actions: <Widget>[
                              new TextButton(
                                child: new Text("Close"),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              new TextButton(
                                child: new Text("Remove"),
                                onPressed: () {
                                  setState(() {
                                    points.remove(point);
                                    updatePoints();
                                  });
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        });
                  }

                  break;
                }
              }

              if (canAdd && points.length <= maxPoints) {
                setState(() {
                  points.add(Point2D(
                      localOffset.dx / constraints.maxWidth,
                      (constraints.maxHeight - localOffset.dy) /
                          constraints.maxHeight));
                  updatePoints();
                });
              } else if (points.length >= maxPoints && !pointTapped) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Max number of points ($maxPoints) reached.'),
                  duration: Duration(seconds: 1),
                ));
              }
            },
          )));

          return Stack(
            children: stackedWidgets,
          );
        }));
  }

  void updatePoints() {
    curveHolder.update(points);
    painter.updatePoints(points);
  }
}
