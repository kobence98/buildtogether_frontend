import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class MainBackground extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var path = Path();
    var paint = Paint();

    path.moveTo(0,size.height*0.05);
    path.quadraticBezierTo(size.width*0.10, size.height*0.05, size.width*0.20, size.height*0.09);
    path.quadraticBezierTo(size.width*0.30, size.height*0.15, size.width*0.50, size.height*0.13);
    path.quadraticBezierTo(size.width*0.60, size.height*0.13, size.width*0.70, size.height*0.17);
    path.quadraticBezierTo(size.width*0.80, size.height*0.23, size.width, size.height*0.21);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    var rect = Offset.zero & size;

    paint.color = CupertinoColors.systemYellow;
    canvas.drawRect(
      rect,
      paint
    );

    paint.color = Colors.black;
    canvas.drawPath(path, paint);

    Path pathBelow = Path();
    pathBelow.moveTo(0,size.height*0.80);
    pathBelow.quadraticBezierTo(size.width*0.10, size.height*0.80, size.width*0.20, size.height*0.84);
    pathBelow.quadraticBezierTo(size.width*0.30, size.height*0.90, size.width*0.50, size.height*0.88);
    pathBelow.quadraticBezierTo(size.width*0.60, size.height*0.88, size.width*0.70, size.height*0.92);
    pathBelow.quadraticBezierTo(size.width*0.80, size.height*0.98, size.width, size.height*0.96);
    pathBelow.lineTo(size.width, size.height);
    pathBelow.lineTo(0, size.height);
    pathBelow.close();

    paint.color = CupertinoColors.systemYellow;
    canvas.drawPath(pathBelow, paint);

  }

  @override
  SemanticsBuilderCallback get semanticsBuilder {
    return (Size size) {
      var rect = Offset.zero & size;
      var width = size.shortestSide * 0.4;
      rect = const Alignment(0.8, -0.9).inscribe(Size(width, width), rect);
      return [
        CustomPainterSemantics(
          rect: rect,
          properties: SemanticsProperties(
            label: 'MainBackground',
            textDirection: TextDirection.ltr,
          ),
        ),
      ];
    };
  }

  @override
  bool shouldRepaint(MainBackground oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(MainBackground oldDelegate) => false;
}
