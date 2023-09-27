import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:my_wit_wallet/theme/colors.dart';
import 'package:my_wit_wallet/globals.dart' as globals;

class AppLifecycleOverlay extends StatefulWidget {
  const AppLifecycleOverlay({
    Key? key,
    required this.child,
    this.isBottomBar = false,
  }) : super(key: key);

  final Widget child;
  final bool isBottomBar;

  @override
  State<AppLifecycleOverlay> createState() => _AppLifecycleState();
}

class _AppLifecycleState extends State<AppLifecycleOverlay>
    with WidgetsBindingObserver {
  bool shouldBlur = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!globals.biometricsAuthInProgress) {
      setState(() {
        shouldBlur = state == AppLifecycleState.inactive ||
            state == AppLifecycleState.paused;
      });
    } else {
      setState(() {
        shouldBlur = false;
      });
    }
    globals.avoidBiometrics = shouldBlur;
  }

  @override
  Widget build(BuildContext context) {
    Widget overlayBackground = Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: WitnetPallet.darkBlue2,
    );
    if (shouldBlur) {
      FocusScope.of(context).unfocus();
      if (widget.isBottomBar) {
        return overlayBackground;
      }
      return Overlay(initialEntries: <OverlayEntry>[
        OverlayEntry(
            builder: (BuildContext context) => Stack(
                  children: [
                    widget.child,
                    BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: overlayBackground),
                  ],
                ))
      ]);
    }

    return widget.child;
  }
}
