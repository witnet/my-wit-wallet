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
  Widget buildMainContent(BuildContext context, theme) {
    final extendedTheme = Theme.of(context).extension<ExtendedTheme>()!;
    if (slidingPanel == null) {
      return _buildMainLayout(context, theme, false);
    } else {
      return SlidingUpPanel(
          controller: panelController,
          color: extendedTheme.walletListBackgroundColor!,
          minHeight: 0,
          maxHeight: MediaQuery.of(context).size.height * 0.3,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8), topRight: Radius.circular(8)),
          panel: slidingPanel,
          body: _buildMainLayout(context, theme, true));
    }
  }

  Widget _buildMainLayout(BuildContext context, theme, bool panel) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
            floating: true,
            snap: true,
            pinned: true,
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            expandedHeight: dashboardActions != null ? 300 : 200,
            toolbarHeight: dashboardActions != null ? 300 : 200,
            flexibleSpace: headerLayout(context, theme)),
        SliverPadding(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: panel ? 70 : 0),
          sliver: SliverToBoxAdapter(
              child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 100,
                maxWidth: 600,
              ),
              child:
                  Column(mainAxisSize: MainAxisSize.max, children: widgetList),
            ),
          )),
        ),
      ],
    );
  }

  Widget headerLayout(context, theme) {
    if (slidingPanel == null) {
      return Container(
          child: HeaderLayout(
        navigationActions: navigationActions,
        dashboardActions: dashboardActions,
      ));
    } else {
      return HeaderLayout(
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
      );
    }
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: theme.backgroundColor,
          body: buildMainContent(context, theme),
          bottomNavigationBar: BottomAppBar(
            notchMargin: 8,
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.only(
                  left: 8, right: 8, bottom: actions.length > 0 ? 8 : 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: 100,
                        maxWidth: 600,
                      ),
                      child: Column(
                          mainAxisSize: MainAxisSize.max, children: actions),
                    ),
                  )
                ],
              ),
            ),
            color: theme.backgroundColor,
          ),
        ));
  }
}
