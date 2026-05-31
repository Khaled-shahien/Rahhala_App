import 'package:flutter/material.dart';

class SoftArcNotchedShape extends NotchedShape {
  final double arcWidth;
  final double arcHeight;

  const SoftArcNotchedShape({
    this.arcWidth = 120,
    this.arcHeight = 22,
  });

  @override
  Path getOuterPath(Rect host, Rect? guest) {
    final Path path = Path();
    final double left = host.left;
    final double right = host.right;
    final double top = host.top;
    final double bottom = host.bottom;

    if (guest == null || guest.isEmpty) {
      return Path()..addRRect(RRect.fromRectXY(host, 22, 22));
    }

    final RRect r = RRect.fromRectXY(host, 22, 22);
    final Rect rect = r.outerRect;

    final double midX = rect.center.dx;

    final double notchHalf = arcWidth / 2;
    final double notchLeft = midX - notchHalf;
    final double notchRight = midX + notchHalf;

    path
      ..moveTo(left, bottom)
      ..lineTo(left, top + 22)
      ..quadraticBezierTo(left, top, left + 22, top)
      ..lineTo(notchLeft, top);

    path.quadraticBezierTo(
      midX,
      top - arcHeight,
      notchRight,
      top,
    );

    path
      ..lineTo(right - 22, top)
      ..quadraticBezierTo(right, top, right, top + 22)
      ..lineTo(right, bottom)
      ..close();

    return path;
  }
}
