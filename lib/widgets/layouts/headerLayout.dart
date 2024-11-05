import 'package:flutter/material.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';

class HeaderLayout extends StatelessWidget {
  final List<Widget> navigationActions;
  final bool isDashboard;
  final Widget? icon;
  final double witnetLogoHeight = 90;

  const HeaderLayout({
    required this.navigationActions,
    this.icon,
    required this.isDashboard,
  });

  bool get isCreateWalletFlow => !isDashboard && navigationActions.length == 1;
  bool get isLoginPage => !isDashboard && navigationActions.length == 0;

  EdgeInsets navigationBarPadding() =>
      isLoginPage ? EdgeInsets.all(16) : EdgeInsets.all(16);

  Widget buildIcon(ThemeData theme) {
    return icon != null
        ? icon!
        : svgImage(name: 'myWitWallet-logo', height: witnetLogoHeight);
  }

  Widget buildDashboardHeader() {
    return Padding(
        padding: EdgeInsets.only(left: 16, right: 16),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: navigationActions.length > 1
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.start,
          children: navigationActions,
        ));
  }

  Widget buildDefaultHeader(
      {required ThemeData theme,
      required ExtendedTheme extendedTheme,
      required BuildContext context}) {
    Color? headerBgColor = theme.colorScheme.surface;
    return Container(
      height: HEADER_HEIGHT,
      width: MediaQuery.of(context).size.width,
      color: headerBgColor,
      child: Stack(alignment: AlignmentDirectional.center, children: [
        Positioned(
            top: -100,
            right: -60,
            child: svgThemeImage(theme, name: 'dots-bg', height: 230)),
        Positioned(child: buildIcon(theme)),
        Column(children: [
          Container(
              padding: navigationBarPadding(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: navigationActions.length > 1
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.start,
                children: navigationActions,
              )),
        ])
      ]),
    );
  }

  Widget build(BuildContext context) {
    final extendedTheme = Theme.of(context).extension<ExtendedTheme>()!;
    final theme = Theme.of(context);
    return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: isDashboard
                ? Border(
                    bottom: BorderSide(
                        width: 0.3, color: extendedTheme.txBorderColor!))
                : null),
        child: SafeArea(
            child: isDashboard
                ? buildDashboardHeader()
                : buildDefaultHeader(
                    theme: theme,
                    context: context,
                    extendedTheme: extendedTheme)));
  }
}
