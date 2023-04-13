import 'dart:async';
import 'package:flutter/material.dart';
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
  final ScrollController? scrollController;
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
    this.scrollController,
  });

  @override
  LayoutState createState() => LayoutState();
}

class LayoutState extends State<Layout> with TickerProviderStateMixin {
  var isPanelClose;
  ScrollController defaultScrollController =
      ScrollController(keepScrollOffset: false);
  bool showPanel = true;

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
    if (widget.slidingPanel == null) {
      return _buildMainLayout(context, theme, false);
    } else {
      return _buildMainLayoutWithSlidingPanel(context, theme, true);
    }
  }

  Widget _buildMainLayoutWithSlidingPanel(BuildContext context, theme, bool panel) {
    final extendedTheme = Theme.of(context).extension<ExtendedTheme>()!;
    return SlidingUpPanel(
      controller: panelController,
      color: extendedTheme.walletListBackgroundColor!,
      minHeight: 0,
      maxHeight: MediaQuery.of(context).size.height * 0.3,
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8), topRight: Radius.circular(8)),
      panel: widget.slidingPanel,
      body: _buildMainLayout(context, theme, panel),
    );
  }

  Widget _buildMainLayout(BuildContext context, theme, bool panel) {
    final theme = Theme.of(context);
    return Scaffold(body: Scaffold(
        backgroundColor: theme.colorScheme.background,
        body: CustomScrollView(
          controller: widget.scrollController != null
          ? widget.scrollController
          : defaultScrollController,
          slivers: [
            SliverAppBar(
                floating: true,
                snap: true,
                pinned: true,
                elevation: 0,
                automaticallyImplyLeading: false,
                backgroundColor: theme.colorScheme.background,
                expandedHeight: widget.dashboardActions != null ? 300 : 200,
                toolbarHeight: widget.dashboardActions != null ? 300 : 200,
                flexibleSpace: headerLayout(context, theme)),
            SliverPadding(
              padding: EdgeInsets.only(
                  left: 16, right: 16, bottom: panel ? 70 : 100),
              sliver: SliverToBoxAdapter(
                  child: Center(
                child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: 100,
                      maxWidth: 600,
                    ),
                    child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: widget.widgetList)),
              )),
            ),
          ],
        ),
        persistentFooterButtons: [
          isPanelClose == null || isPanelClose
              ? bottomBar()
              : SizedBox(
                  height: 0,
                )
        ]));
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
    final theme = Theme.of(context);
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
          children: widget.actions,
        ),
      ),
      color: theme.colorScheme.background,
    );
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: buildMainContent(context, theme));
  }
}
