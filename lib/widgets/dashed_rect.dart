import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:witnet_wallet/theme/extended_theme.dart';
import 'dart:math' as math;

import 'package:witnet_wallet/widgets/PaddedButton.dart';

typedef void VoidCallback();

class DashedRect extends StatelessWidget {
  final Color color;
  final double strokeWidth;
  final double gap;
  final bool blur;
  final bool showEye;
  final String text;
  final VoidCallback? updateBlur;
  DashedRect(
      {this.color = Colors.black,
      this.updateBlur,
      this.strokeWidth = 1.0,
      this.blur = false,
      this.showEye = false,
      this.gap = 5.0,
      this.text = ''});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    return Container(
        child: Padding(
      padding: EdgeInsets.all(strokeWidth / 2),
      child: CustomPaint(
        painter:
            DashRectPainter(color: color, strokeWidth: strokeWidth, gap: gap),
        child: Column(children: [
          Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                text,
                style: blur
                    ? TextStyle(
                        fontSize: theme.textTheme.headline2!.fontSize,
                        fontWeight: theme.textTheme.headline2!.fontWeight,
                        foreground: Paint()
                          ..style = PaintingStyle.fill
                          ..color = theme.textTheme.headline2!.color!
                          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6))
                    : theme.textTheme.headline2,
              )),
          showEye
              ? Padding(
                  padding: EdgeInsets.all(8),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: PaddedButton(
                      padding: EdgeInsets.all(0),
                      color: extendedTheme.inputIconColor,
                      text: '',
                      onPressed: () => updateBlur!(),
                      icon: !blur
                          ? Icon(Icons.remove_red_eye)
                          : Icon(Icons.visibility_off),
                      type: 'vertical-icon',
                    ),
                  ))
              : SizedBox(height: 0),
        ]),
      ),
    ));
  }
}

class DashRectPainter extends CustomPainter {
  double strokeWidth;
  Color color;
  double gap;

  DashRectPainter(
      {this.strokeWidth = 5.0, this.color = Colors.red, this.gap = 5.0});

  @override
  void paint(Canvas canvas, Size size) {
    Paint dashedPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double x = size.width;
    double y = size.height;

    Path _topPath = getDashedPath(
      a: math.Point(0, 0),
      b: math.Point(x, 0),
      gap: gap,
    );

    Path _rightPath = getDashedPath(
      a: math.Point(x, 0),
      b: math.Point(x, y),
      gap: gap,
    );

    Path _bottomPath = getDashedPath(
      a: math.Point(0, y),
      b: math.Point(x, y),
      gap: gap,
    );

    Path _leftPath = getDashedPath(
      a: math.Point(0, 0),
      b: math.Point(0.001, y),
      gap: gap,
    );

    canvas.drawPath(_topPath, dashedPaint);
    canvas.drawPath(_rightPath, dashedPaint);
    canvas.drawPath(_bottomPath, dashedPaint);
    canvas.drawPath(_leftPath, dashedPaint);
  }

  Path getDashedPath({
    required math.Point<double> a,
    required math.Point<double> b,
    required gap,
  }) {
    Size size = Size(b.x - a.x, b.y - a.y);
    Path path = Path();
    path.moveTo(a.x, a.y);
    bool shouldDraw = true;
    math.Point currentPoint = math.Point(a.x, a.y);

    num radians = math.atan(size.height / size.width);

    num dx = math.cos(radians) * gap < 0
        ? math.cos(radians) * gap * -1
        : math.cos(radians) * gap;

    num dy = math.sin(radians) * gap < 0
        ? math.sin(radians) * gap * -1
        : math.sin(radians) * gap;

    while (currentPoint.x <= b.x && currentPoint.y <= b.y) {
      shouldDraw
          ? path.lineTo(currentPoint.x.toDouble(), currentPoint.y.toDouble())
          : path.moveTo(currentPoint.x.toDouble(), currentPoint.y.toDouble());
      shouldDraw = !shouldDraw;
      currentPoint = math.Point(
        currentPoint.x + dx,
        currentPoint.y + dy,
      );
    }
    return path;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
