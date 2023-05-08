import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:witnet_wallet/shared/api_database.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/theme/colors.dart';
import 'package:witnet_wallet/widgets/identicon.dart';
import 'package:witnet_wallet/widgets/layouts/headerLayout.dart';
import 'package:witnet_wallet/theme/extended_theme.dart';
import 'package:witnet_wallet/theme/wallet_theme.dart';

final panelController = PanelController();

class Layout extends StatefulWidget {
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

  @override
  LayoutState createState() => LayoutState();
}

class LayoutState extends State<Layout> with TickerProviderStateMixin {
  var isPanelClose;

  Widget showWalletList(BuildContext context) {
    String walletId =
        Locator.instance.get<ApiDatabase>().walletStorage.currentWallet.id;
    return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          child: Container(
            color: WitnetPallet.white,
            width: 30,
            height: 30,
            child: Identicon(seed: walletId, size: 8),
          ),
          onTap: () => {
            if (panelController.isPanelOpen)
              {
                panelController.close(),
                Timer(Duration(milliseconds: 300), () {
                  setState(() {
                    isPanelClose = true;
                  });
                }),
              }
            else
              {
                panelController.open(),
                setState(() {
                  isPanelClose = panelController.isPanelClosed;
                })
              }
          },
        ));
  }

  // Content displayed between header and bottom actions
  Widget buildMainContent(BuildContext context, theme) {
    final extendedTheme = Theme.of(context).extension<ExtendedTheme>()!;
    if (widget.slidingPanel == null) {
      return _buildMainLayout(context, theme, false);
    } else {
      return SlidingUpPanel(
          controller: panelController,
          color: extendedTheme.walletListBackgroundColor!,
          minHeight: 0,
          maxHeight: MediaQuery.of(context).size.height * 0.3,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8), topRight: Radius.circular(8)),
          panel: widget.slidingPanel,
          body: Padding(
              child: _buildMainLayout(context, theme, true),
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom)));
    }
  }

  Widget _buildMainLayout(BuildContext context, theme, bool panel) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
            floating: true,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: extendedTheme.headerBackgroundColor,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.dark,
            ),
            snap: true,
            pinned: true,
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            expandedHeight: widget.dashboardActions != null ? 300 : 200,
            toolbarHeight: widget.dashboardActions != null ? 300 : 200,
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
              child: Column(
                  mainAxisSize: MainAxisSize.max, children: widget.widgetList),
            ),
          )),
        ),
      ],
    );
  }

  Widget headerLayout(context, theme) {
    if (widget.slidingPanel == null) {
      return Container(
          child: HeaderLayout(
        navigationActions: widget.navigationActions,
        dashboardActions: widget.dashboardActions,
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
          ...widget.navigationActions
        ],
        dashboardActions: widget.dashboardActions,
      );
    }
  }

  Widget bottomBar() {
    return BottomAppBar(
      notchMargin: 8,
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.only(
            left: 8, right: 8, bottom: widget.actions.length > 0 ? 8 : 0),
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
                    mainAxisSize: MainAxisSize.max, children: widget.actions),
              ),
            )
          ],
        ),
      ),
      color: Colors.transparent,
    );
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: theme.colorScheme.background,
            body: buildMainContent(context, theme),
            bottomNavigationBar:
                isPanelClose == null || isPanelClose ? bottomBar() : null));
  }
}
