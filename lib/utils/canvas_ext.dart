import 'package:flutter/material.dart';

extension CanvasXDrawNonOverlapCircles on Canvas {
  void drawCirclesAlongPath(
    Paint paint,
    List<Offset> positions,
    double radius,
    Offset lastNode,
  ) {
    if (positions.length < 2) {
      return;
    }
    Set<Offset> drawnPositions = {};
    drawCircle(positions.first, radius, paint);
    drawnPositions.add(positions.first);
    for (int i = 1; i <= positions.length - 1; i++) {
      Offset center = positions[i];
      Offset prevCenter = positions[i - 1];

      double distance = (center - prevCenter).distanceSquared;
      int steps = (distance / radius * 2).ceil();

      for (int step = 1; step <= steps; step++) {
        double t = step / steps;
        Offset interpolatedCenter =
            Offset.lerp(prevCenter, center, t.clamp(0, 1))!;

        bool isOverlapping = drawnPositions.any((existingPosition) {
          double distance = (interpolatedCenter - existingPosition).distance;
          return distance < radius * 2;
        });
        if (!isOverlapping) {
          final lastCircle = (lastNode - interpolatedCenter);
          final lastOverlaps = lastCircle.distance <= radius;
          if (lastOverlaps) {
            Offset tangent = lastNode - drawnPositions.last;
            if (tangent.distance != 0) {
              tangent = tangent / tangent.distance;
            }
            double perpendicularSlope = -1 / tangent.direction;

            Offset point1 = lastNode -
                Offset(
                  radius * 2,
                  radius * 2 * perpendicularSlope,
                );
            Offset point2 = lastNode +
                Offset(
                  radius * 2,
                  radius * 2 * perpendicularSlope,
                );

// Create a path for the semicircle
            final Path semiCirclePath = Path();
            semiCirclePath.moveTo(point1.dx, point1.dy);
            semiCirclePath.arcToPoint(
              point2,
              radius: Radius.circular(radius * 2),
              clockwise: perpendicularSlope.isNegative,
            );
            save();
            clipPath(semiCirclePath);
            drawCircle(interpolatedCenter, radius, paint);
            restore();
          } else {
            drawCircle(interpolatedCenter, radius, paint);
          }
          drawnPositions.add(interpolatedCenter);
        }
      }
    }
  }
}
