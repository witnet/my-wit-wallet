import 'package:flutter/material.dart';
import 'package:witnet_wallet/theme/extended_theme.dart';
import 'package:witnet_wallet/theme/wallet_theme.dart';

class Customshape extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double height = size.height;
    double width = size.width;

    var path = Path();
    path.lineTo(0, height - 50);
    path.quadraticBezierTo(width / 2, height, width, height - 50);
    path.lineTo(width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class HeaderLayout extends StatelessWidget {
  final List<Widget>? widgetList;
  final AppBar? appBar;

  const HeaderLayout({
    this.widgetList,
    this.appBar,
  });

  Widget build(BuildContext context) {
    final extendedTheme = Theme.of(context).extension<ExtendedTheme>()!;
    final theme = Theme.of(context);

    return ClipPath(
        clipper: Customshape(),
        child: Container(
          height: 250,
          width: MediaQuery.of(context).size.width,
          color: extendedTheme.headerBackgroundColor,
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  Flexible(
                      child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: 50, maxWidth: MediaQuery.of(context).size.width * 0.2),
                    child: witnetEyeIcon(theme),
                  )),
              ]
            )
          ),
        ));
  }
}
