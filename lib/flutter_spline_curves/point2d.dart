class Point2D {
  late double x;
  late double y;

  Point2D(double x, double y) {
    this.x = x;
    this.y = y;
  }

  void setLocation(double x, double y) {
    this.x = x;
    this.y = y;
  }

  void copyLocation(Point2D point) {
    this.x = point.x;
    this.y = point.y;
  }

  @override
  bool operator ==(Object other) {
    if (other is Point2D) {
      return x == other.x && y == other.y;
    }

    return false;
  }

  @override
  int get hashCode => x.hashCode & y.hashCode;

}
