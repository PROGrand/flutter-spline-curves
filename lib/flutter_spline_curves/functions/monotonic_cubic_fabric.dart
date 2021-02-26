import 'dart:math';
import 'generic_function.dart';
import '../point2d.dart';

class MonotonicCubeSplineFabric extends GeneralFunctionFabric {
  @override
  GenericFunction makeFunction() {
    return MonotonicCubeSplineFunction(List.unmodifiable(controlPoints));
  }
}

class MonotonicCubeSplineFunction extends GenericFunction {
  MonotonicCubeSplineFunction(List<Point2D> controlPoints)
      : function = MonotonicCube(controlPoints).makeFunction();
  final Function function;

  @override
  Point2D value(double position) => Point2D(position, function(position));
}


class MonotonicCube {
  MonotonicCube(this.controlPoints);

  final List<Point2D> controlPoints;

  Function makeFunction() {
    var length = controlPoints.length;

    if (length == 0) {
      return (x) {
        return 0;
      };
    }
    if (length == 1) {
      var result = controlPoints.first.y;
      return (x) {
        return result;
      };
    }

    var indexes = <int>[];
    for (var i = 0; i < length; i++) {
      indexes.add(i);
    }
    indexes.sort((a, b) => controlPoints[a].x.compareTo(controlPoints[b].x));

    var list = <Point2D>[];

    // Impl: Unary plus properly converts values to numbers
    for (var i = 0; i < length; i++) {
      list.add(controlPoints[indexes[i]]);
    }

    // Get consecutive differences and slopes
    var dys = <double>[], dxs = <double>[], ms = <double>[];
    for (var i = 0; i < length - 1; i++) {
      var element0 = list[i];
      var element1 = list[i + 1];
      var dx = element1.x - element0.x, dy = element1.y - element0.y;
      dxs.add(dx);
      dys.add(dy);
      ms.add(dy / dx);
    }

    // Get degree-1 coefficients
    var c1s = <double>[];
    c1s.add(ms[0]);

    for (var i = 0; i < dxs.length - 1; i++) {
      var m = ms[i], mNext = ms[i + 1];
      if (m * mNext <= 0) {
        c1s.add(0);
      } else {
        var dx = dxs[i], dxNext = dxs[i + 1], common = dx + dxNext;
        c1s.add(3 * common / ((common + dxNext) / m + (common + dx) / mNext));
      }
    }
    c1s.add(ms[ms.length - 1]);

    // Get degree-2 and degree-3 coefficients
    var c2s = [], c3s = [];
    for (var i = 0; i < c1s.length - 1; i++) {
      var c1 = c1s[i],
          m = ms[i],
          invDx = 1 / dxs[i],
          common = c1 + c1s[i + 1] - m - m;
      c2s.add((m - c1 - common) * invDx);
      c3s.add(common * invDx * invDx);
    }

    // Return interpolant function
    return (x) {
      // The rightmost point in the dataset should give an exact result
      var i = list.length - 1;
      var listIth = list[i];
      if (x == listIth.x) {
        return listIth.y;
      }

      // Search for the interval x is in, returning the corresponding y if x is one of the original xs
      var low = 0, mid, high = c3s.length - 1;
      while (low <= high) {
        mid = (0.5 * (low + high)).floor();
        var listMid = list[mid];
        var xHere = listMid.x;
        if (xHere < x) {
          low = mid + 1;
        } else if (xHere > x) {
          high = mid - 1;
        } else {
          return listMid.y;
        }
      }

      i = max(0, high);

      // Interpolate
      listIth = list[i];
      var diff = x - listIth.x, diffSq = diff * diff;
      return listIth.y +
          c1s[i] * diff +
          c2s[i] * diffSq +
          c3s[i] * diff * diffSq;
    };
  }
}
