import '../point2d.dart';

List<Point2D> fixControlPoints(List<Point2D> controlPoints) {
  var points = controlPoints.map((e) => Point2D(e.x, e.y)).toList();

  points.sort((a, b) => a.x.compareTo(b.x));

  if (4 > points.length) {
    points.insert(
        0, Point2D(points.first.x - 0.00001, points.first.y - 0.00001));
    points.add(Point2D(points.last.x + 0.00001, points.last.y + 0.00001));
  }

  return points;
}
