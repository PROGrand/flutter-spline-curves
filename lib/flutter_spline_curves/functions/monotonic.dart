import '../point2d.dart';

List<Point2D> removeNonMonotonic(
    List<Point2D> controlPoints, int steps, List<Point2D> points) {
  var xVals = <double>[];
  for (var point in points) {
    xVals.add(point.x);
  }
  var offset = 0;

  var mPerSegment = (steps ~/ controlPoints.length);

  for (var i = 0; i < (controlPoints.length - 1); i++) {
    var intervalStart = (((i - offset) * mPerSegment) + offset);
    for (var j = intervalStart; j < (intervalStart + mPerSegment); j++) {
      if (points[j].x > points[j + 1].x) {
        for (var g = 0; g < (mPerSegment - 1); g++) {
          points.remove(intervalStart + 1);
        }
        offset += 1;
        break;
      }
    }
  }
  for (var i = 1; i < points.length; i++) {
    while ((i < points.length) && (points[i - 1].x >= points[i].x)) {
      points.removeAt(i);
    }
  }
  var x = List<double>.filled(points.length, 0);
  var i = 0;
  for (var point in points) {
    x[i++] = point.x;
  }
  return points;
}
