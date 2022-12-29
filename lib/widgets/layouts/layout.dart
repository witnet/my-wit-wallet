import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:witnet_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:witnet_wallet/theme/colors.dart';
import 'package:witnet_wallet/widgets/layouts/headerLayout.dart';
import 'package:witnet_wallet/theme/extended_theme.dart';
import 'package:witnet_wallet/theme/wallet_theme.dart';

final panelController = PanelController();

class Layout extends StatelessWidget {
  final List<Widget> widgetList;
  final AppBar? appBar;
  final List<Widget> actions;
  final List<Widget> navigationActions;
  final Widget? slidingPanel;
  final Widget? dashboardActions;

  const Layout({
    required this.widgetList,
    required this.actions,
    required this.navigationActions,
    this.dashboardActions,
    this.slidingPanel,
    this.appBar,
  });

  Widget showWalletList(BuildContext context) {
    return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          child: Container(
            color: WitnetPallet.white,
            width: 30,
            height: 30,
          ),
          onTap: () => {
            if (dashboardActions != null && actions.length > 0)
              {
                Navigator.pushReplacementNamed(context, DashboardScreen.route),
              }
            else
              {
                panelController.isPanelOpen
                    ? panelController.close()
                    : panelController.open()
              }
          },
        ));
  }
  // Content displayed between header and bottom actions
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
              HeaderLayout(
                navigationActions: navigationActions,
                dashboardActions: dashboardActions,
              ),
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
            ],
          ));
    } else {
      final theme = Theme.of(context);
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
            HeaderLayout(
              navigationActions: [
                showWalletList(context),
                Flexible(
                    child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 50,
                  ),
                  child: Column(
                    children: [smallWitnetEyeIcon(theme)],
                  ),
                )),
                ...navigationActions
              ],
              dashboardActions: dashboardActions,
            ),
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 600,
                ),
                child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(children: widgetList)),
              ),
            ),
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
      bottomNavigationBar: BottomAppBar(
        notchMargin: 8,
        child: Padding(padding: EdgeInsets.only(left: 8, right: 8, bottom: 8), child: 
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: actions,
        ),
        ),
        color: theme.backgroundColor,
      ),
    );
  }
}
