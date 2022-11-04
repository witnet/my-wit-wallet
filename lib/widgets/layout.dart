import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:witnet_wallet/theme/colors.dart';
import 'package:witnet_wallet/widgets/headerLayout.dart';
import 'package:witnet_wallet/theme/extended_theme.dart';

final panelController = PanelController();

class Layout extends StatelessWidget {
  final List<Widget> widgetList;
  final AppBar? appBar;
  final List<Widget> actions;
  final List<Widget> headerActions;
  final double actionsSize;
  final Widget? slidingPanel;

  const Layout({
    required this.widgetList,
    required this.actions,
    required this.actionsSize,
    required this.headerActions,
    this.slidingPanel,
    this.appBar,
  });

  Widget showWalletList() {
    return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          child: Container(
            color: WitnetPallet.white,
            width: 30,
            height: 30,
          ),
          onTap: () => {
            panelController.isPanelOpen
                ? panelController.close()
                : panelController.open()
          },
        ));
  }

  Widget buildListView(context) {
    final extendedTheme = Theme.of(context).extension<ExtendedTheme>()!;
    if (slidingPanel == null) {
      return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            controller: ScrollController(),
            children: [
              HeaderLayout(headerActions: headerActions),
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: 100,
                    maxWidth: 600,
                  ),
                  child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(children: widgetList)),
                ),
              ),
              SizedBox(
                height: actionsSize,
              )
            ],
          ));
    } else {
      return SlidingUpPanel(
        controller: panelController,
        color: extendedTheme.walletListBackgroundColor!,
        minHeight: 0,
        maxHeight: MediaQuery.of(context).size.height * 0.3,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8), topRight: Radius.circular(8)),
        panel: slidingPanel,
        body: ListView(
          controller: ScrollController(),
          children: [
            HeaderLayout(headerActions: [showWalletList(), ...headerActions]),
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 100,
                  maxWidth: 600,
                ),
                child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(children: widgetList)),
              ),
            ),
            SizedBox(
              height: actionsSize,
            )
          ],
        ),
      );
    }
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: appBar,
      resizeToAvoidBottomInset: false,
      backgroundColor: theme.backgroundColor,
      body: buildListView(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: actionsSize,
        alignment: Alignment.bottomCenter,
        constraints: BoxConstraints(minWidth: 100, maxWidth: 600),
        color: theme.backgroundColor,
        padding: EdgeInsets.only(left: 16, bottom: 8, right: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: actions,
        ),
      ),
    );
  }
}
