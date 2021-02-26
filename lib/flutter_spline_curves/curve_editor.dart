import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'functions/interpolated_function_base.dart';
import 'curve_painter.dart';
import 'point2d.dart';

final defaultPointWidget = ClipRRect(
  borderRadius: BorderRadius.circular(10.0),
  child: Container(
    width: 30.0,
    height: 30.0,
    color: Colors.blue,
  ),
);

final defaultStartingPointWidget = ClipRRect(
  borderRadius: BorderRadius.circular(10.0),
  child: Container(
    width: 30.0,
    height: 30.0,
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
  final List<Point2D> _points;
  final Color curveColor;
  final double curveWidth;
  final Widget pointWidget;
  final Widget startingPointWidget;
  final double pointWidgetSize;

  CurveEditor({
    Key key,
    @required this.curveHolder,
    List<Point2D> points,
    this.curveColor = Colors.red,
    this.curveWidth = 3,
    Widget pointWidget,
    Widget startingPointWidget,
    this.pointWidgetSize = 30,
  })  : pointWidget = pointWidget ?? defaultPointWidget,
        startingPointWidget = startingPointWidget ?? defaultStartingPointWidget,
        _points = points ?? [],
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CurveEditorState(curveHolder, _points);
  }
}

class CurveEditorState extends State<CurveEditor> {
  List<Point2D> points;
  FunctionPainter painter;
  final CurveHolder curveHolder;

  CurveEditorState(
      this.curveHolder, List<Point2D> points) {
    this.points = points;
    this.painter = FunctionPainter(curveHolder.function, points: this.points);
  }


  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: painter,
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          // add points
          var stackedWidgets = <Widget>[];

          var pointIndex = 0;
          for (var point in points) {
            var xPosition =
                point.x * constraints.maxWidth - widget.pointWidgetSize / 2;

            stackedWidgets.add(Positioned(
                left: xPosition,
                top: constraints.maxHeight -
                    point.y * constraints.maxHeight -
                    widget.pointWidgetSize / 2,
                child: buildGestureDetector(pointIndex++, constraints)));
          }

          // add gesture detector for adding new points
          stackedWidgets.add(Positioned.fill(child: GestureDetector(
            onTapUp: (TapUpDetails details) {
              RenderBox getBox = context.findRenderObject();
              Offset localOffset = getBox.globalToLocal(details.globalPosition);

              // only add if no point is within 4*r=2*pointWidgetSize
              var pointTapped = false;

              if (points.length <= maxPoints) {
                setState(() {
                  points.insert(1, Point2D(
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

  Widget buildGestureDetector(
      int pointIndex, BoxConstraints constraints) {

    return RawGestureDetector(
      child: Container(
          width: widget.pointWidgetSize,
          height: widget.pointWidgetSize,
          child: isFixed(pointIndex) ? widget.startingPointWidget : widget.pointWidget),
      gestures: <Type, GestureRecognizerFactory>{
        CustomPanGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<CustomPanGestureRecognizer>(
          () => CustomPanGestureRecognizer(
              onPanDown: (details) => true,
              onPanUpdate: (details) {
                setState(() {
                  var point = points[pointIndex];
                  var dx = isFixed(pointIndex) ? 0 : details.delta.dx;
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
              onPanEnd: (details) {},
              onTap: (details) {
                if (!isFixed(pointIndex)) {
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
                                  points.removeAt(pointIndex);
                                  updatePoints();
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      });
                }
              }),
          (CustomPanGestureRecognizer instance) {},
        ),
      },
    );
  }

  void updatePoints() {
    curveHolder.update(points);
    painter.updatePoints(points);
  }

  void setup(List<Point2D> points) {
    setState(() {
      this.points = points;
      updatePoints();
    });
  }

  isFixed(int pointIndex) => 0 == pointIndex || points.length - 1 == pointIndex;
}

class CustomPanGestureRecognizer extends OneSequenceGestureRecognizer {
  final Function onPanDown;
  final Function onPanUpdate;
  final Function onPanEnd;
  final Function onTap;
  double len;

  Offset _startPanPosition;

  CustomPanGestureRecognizer(
      {@required this.onPanDown,
      @required this.onPanUpdate,
      @required this.onPanEnd,
      @required this.onTap});

  @override
  void addPointer(PointerEvent event) {
    if (onPanDown(event)) {
      len = 0;
      _startPanPosition = event.position;
      startTrackingPointer(event.pointer);
      resolve(GestureDisposition.accepted);
    } else {
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent) {
      var dx = event.position.dx - _startPanPosition.dx;
      var dy = event.position.dy - _startPanPosition.dy;
      len += sqrt(dx * dx + dy * dy);
      onPanUpdate(event);
    }
    if (event is PointerUpEvent) {
      onPanEnd(event);

      if (len < 3) {
        onTap(event);
      }
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  String get debugDescription => 'customPan';

  @override
  void didStopTrackingLastPointer(int pointer) {}
}
