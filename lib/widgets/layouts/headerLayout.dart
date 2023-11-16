import 'package:flutter/material.dart';
import 'package:my_wit_wallet/util/get_window_width.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';

class Customshape extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double height = size.height;
    double width = size.width;

    var path = Path();
    double r = windowWidth * 0.08;
    // Avoid too curvy shape in wide screens
    double curveHeight = r > 90 ? 90 : r;
    path.lineTo(0, height - curveHeight);
    path.quadraticBezierTo(
        width * 0.5, height + curveHeight, width, height - curveHeight);
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
  final AppBar? appBar;
  final List<Widget> navigationActions;
  final Widget? dashboardActions;
  final double witnetLogoHeight = 70;

  const HeaderLayout({
    required this.navigationActions,
    this.dashboardActions,
    this.appBar,
  });

  bool isCreateWalletFlow() =>
      dashboardActions == null && navigationActions.length == 1;
  bool isLoginPage() =>
      dashboardActions == null && navigationActions.length == 0;

  EdgeInsets navigationBarPadding() =>
      isLoginPage() ? EdgeInsets.all(16) : EdgeInsets.all(8);

  Widget build(BuildContext context) {
    final extendedTheme = Theme.of(context).extension<ExtendedTheme>()!;
    final theme = Theme.of(context);
    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          colors: [
            theme.colorScheme.background,
            theme.colorScheme.background,
            theme.colorScheme.background,
            theme.colorScheme.background.withOpacity(0.7),
            theme.colorScheme.background.withOpacity(0.7),
            theme.colorScheme.background.withOpacity(0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0, 0.2, 0.6, 0.7, 0.95, 1],
        )),
        child: ClipPath(
            clipper: Customshape(),
            child: Container(
                color: extendedTheme.headerBackgroundColor,
                child: SafeArea(
                    child: Container(
                  height: dashboardActions != null
                      ? DASHBOARD_HEADER_HEIGTH
                      : HEADER_HEIGTH,
                  width: MediaQuery.of(context).size.width,
                  color: extendedTheme.headerBackgroundColor,
                  child: Column(children: [
                    Container(
                        padding: navigationBarPadding(),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: navigationActions.length > 1
                              ? MainAxisAlignment.spaceBetween
                              : MainAxisAlignment.start,
                          children: navigationActions,
                        )),
                    Container(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          Flexible(
                              child: ConstrainedBox(
                            constraints: BoxConstraints(
                                minWidth: 50,
                                maxWidth: dashboardActions != null
                                    ? MediaQuery.of(context).size.width * 0.9
                                    : MediaQuery.of(context).size.width * 0.3),
                            child: Column(
                              children: [
                                dashboardActions != null
                                    ? dashboardActions!
                                    : witnetEyeIcon(theme,
                                        height: witnetLogoHeight)
                              ],
                            ),
                          )),
                        ])),
                  ]),
                )))));
  }
}
