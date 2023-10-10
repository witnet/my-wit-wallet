import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:my_wit_wallet/bloc/explorer/explorer_bloc.dart';
import 'package:my_wit_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/util/showTxConnectionError.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/layouts/listen_fourth_button.dart';
import 'package:my_wit_wallet/widgets/snack_bars.dart';
import 'package:my_wit_wallet/widgets/wallet_type_label.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/theme/colors.dart';
import 'package:my_wit_wallet/widgets/identicon.dart';
import 'package:my_wit_wallet/widgets/layouts/headerLayout.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/app_lifecycle_overlay.dart';

class GoBackIntent extends Intent {
  const GoBackIntent();
}

class Layout extends StatefulWidget {
  final ScrollController? scrollController;
  final List<Widget> widgetList;
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
    this.scrollController,
  });

  @override
  LayoutState createState() => LayoutState();
}

class LayoutState extends State<Layout> with TickerProviderStateMixin {
  var isPanelClose;
  ScrollController defaultScrollController =
      ScrollController(keepScrollOffset: false);
  final panelController = PanelController();

  AppLocalizations get _localization => AppLocalizations.of(context)!;

  BlocListener<VTTCreateBloc, VTTCreateState> _vttListener(Widget child) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    return BlocListener<VTTCreateBloc, VTTCreateState>(
      listenWhen: (previousState, currentState) {
        if (showTxConnectionReEstablish(
            previousState.vttCreateStatus, currentState.vttCreateStatus)) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(buildErrorSnackbar(
            theme,
            _localization.connectionReestablished,
            extendedTheme.txValuePositiveColor,
            () => {
              if (mounted)
                {ScaffoldMessenger.of(context).hideCurrentMaterialBanner()}
            },
          ));
        }
        return true;
      },
      listener: (context, state) {
        if (state.vttCreateStatus == VTTCreateStatus.exception) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(buildErrorSnackbar(
              theme, _localization.connectionIssue, theme.colorScheme.error));
        }
      },
      child: child,
    );
  }

  BlocListener<ExplorerBloc, ExplorerState> _explorerListerner(Widget child) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    return BlocListener<ExplorerBloc, ExplorerState>(
      listenWhen: (previousState, currentState) {
        if (previousState.status == ExplorerStatus.error &&
            currentState.status != ExplorerStatus.error &&
            currentState.status != ExplorerStatus.dataloading &&
            currentState.status != ExplorerStatus.unknown) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(buildErrorSnackbar(
            theme,
            _localization.connectionReestablished,
            extendedTheme.txValuePositiveColor,
            () => {
              if (mounted)
                {ScaffoldMessenger.of(context).hideCurrentMaterialBanner()}
            },
          ));
        }
        return true;
      },
      listener: (context, state) {
        if (state.status == ExplorerStatus.error) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(buildErrorSnackbar(
              theme, _localization.connectionIssue, theme.colorScheme.error));
        }
      },
      child: child,
    );
  }

  Widget showWalletList(BuildContext context) {
    String walletId =
        Locator.instance.get<ApiDatabase>().walletStorage.currentWallet.id;
    return PaddedButton(
        padding: EdgeInsets.zero,
        label: '${_localization.showWalletList} button',
        text: _localization.showWalletList,
        type: ButtonType.iconButton,
        iconSize: 30,
        icon: Container(
          color: WitnetPallet.white,
          width: 28,
          height: 28,
          child: Identicon(seed: walletId, size: 8),
        ),
        onPressed: () => {
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
                  // If keyboard is open hide keyboard
                  FocusScope.of(context).unfocus(),
                  panelController.open(),
                  setState(() {
                    isPanelClose = panelController.isPanelClosed;
                  })
                }
            });
  }

  void hidePanelOnMobileIfKeyboard() {
    if ((Platform.isAndroid || Platform.isIOS) &&
        FocusScope.of(context).isFirstFocus &&
        panelController.isAttached &&
        panelController.isPanelOpen) {
      panelController.close();
    }
  }

  // Content displayed between header and bottom actions
  Widget buildMainContent(BuildContext context, theme) {
    final extendedTheme = Theme.of(context).extension<ExtendedTheme>()!;
    if (widget.slidingPanel == null) {
      return _buildMainLayout(context, theme, false);
    } else {
      // Hide panel if the mobile keyboard is open
      hidePanelOnMobileIfKeyboard();
      return SlidingUpPanel(
          controller: panelController,
          color: extendedTheme.walletListBackgroundColor!,
          minHeight: 0,
          maxHeight: MediaQuery.of(context).size.height * 0.3,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8), topRight: Radius.circular(8)),
          panel: widget.slidingPanel,
          body: GestureDetector(
              excludeFromSemantics: true,
              onTap: () {
                if (panelController.isPanelOpen) {
                  panelController.close();
                  Timer(Duration(milliseconds: 300), () {
                    setState(() {
                      isPanelClose = true;
                    });
                  });
                }
              },
              child: Padding(
                  child: _buildMainLayout(context, theme, true),
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom))));
    }
  }

  Widget _buildMainLayout(BuildContext context, theme, bool panel) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;

    return CustomScrollView(
      controller: widget.scrollController != null
          ? widget.scrollController
          : defaultScrollController,
      semanticChildCount: 1,
      slivers: [
        SliverAppBar(
            floating: true,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: extendedTheme.headerBackgroundColor,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
            ),
            snap: true,
            pinned: true,
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            expandedHeight: widget.dashboardActions != null
                ? DASHBOARD_HEADER_HEIGTH
                : HEADER_HEIGTH,
            toolbarHeight: widget.dashboardActions != null
                ? DASHBOARD_HEADER_HEIGTH
                : HEADER_HEIGTH,
            flexibleSpace: headerLayout(context, theme)),
        SliverPadding(
          padding: EdgeInsets.only(left: 16, right: 16),
          sliver: SliverToBoxAdapter(
              child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 100,
                maxWidth: 600,
              ),
              child: _vttListener(_explorerListerner(Column(
                  mainAxisSize: MainAxisSize.max,
                  children: widget.widgetList))),
            ),
          )),
        ),
      ],
    );
  }

  Widget headerLayout(context, theme) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    if (widget.slidingPanel == null) {
      return Container(
          child: HeaderLayout(
        navigationActions: widget.navigationActions,
        dashboardActions: widget.dashboardActions,
      ));
    } else {
      Wallet wallet =
          Locator.instance.get<ApiDatabase>().walletStorage.currentWallet;
      return HeaderLayout(
        navigationActions: [
          showWalletList(context),
          Expanded(
              child: Padding(
                  padding: EdgeInsets.only(left: 24, right: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Tooltip(
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: extendedTheme.tooltipBgColor,
                          ),
                          height: 50,
                          richMessage: TextSpan(
                            text: wallet.name,
                            style: theme.textTheme.bodyMedium,
                          ),
                          child: Text(wallet.name,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: extendedTheme.headerTextColor,
                                  fontSize: 16))),
                      SizedBox(
                          height:
                              wallet.walletType == WalletType.single ? 8 : 0),
                      WalletTypeLabel(label: wallet.walletType),
                    ],
                  ))),
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
            left: 16, right: 16, bottom: widget.actions.length > 0 ? 16 : 0),
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

  Widget buildOverlay(Widget child, {bool isBottomBar = false}) {
    return AppLifecycleOverlay(
      isBottomBar: isBottomBar,
      child: child,
    );
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navigator = Navigator.of(context);
    return Shortcuts(
        shortcuts: <ShortcutActivator, Intent>{
          LogicalKeySet(LogicalKeyboardKey.browserBack): const GoBackIntent(),
          LogicalKeySet(LogicalKeyboardKey.goBack): const GoBackIntent(),
          LogicalKeySet(
                  LogicalKeyboardKey.metaRight, LogicalKeyboardKey.arrowLeft):
              const GoBackIntent(),
          LogicalKeySet(
                  LogicalKeyboardKey.metaLeft, LogicalKeyboardKey.arrowLeft):
              const GoBackIntent(),
        },
        child: Actions(
            actions: {
              GoBackIntent: CallbackAction<GoBackIntent>(
                onInvoke: (GoBackIntent intent) => {
                  if (navigator.canPop())
                    {
                      navigator.pop(),
                      if (panelController.isPanelOpen) {panelController.close()}
                    }
                },
              )
            },
            child: FocusScope(
              autofocus: true,
              child: RawGestureDetector(
                  excludeFromSemantics: true,
                  gestures: <Type, GestureRecognizerFactory>{
                    FourthButtonTapGestureRecognizer:
                        GestureRecognizerFactoryWithHandlers<
                            FourthButtonTapGestureRecognizer>(
                      () => FourthButtonTapGestureRecognizer(),
                      (FourthButtonTapGestureRecognizer instance) {
                        instance
                          ..onTapDown = (TapDownDetails details) {
                            if (navigator.canPop()) {
                              navigator.pop();
                              if (panelController.isPanelOpen) {
                                panelController.close();
                              }
                            }
                          };
                      },
                    ),
                  },
                  child: Scaffold(
                      resizeToAvoidBottomInset: true,
                      backgroundColor: theme.colorScheme.background,
                      body: buildOverlay(buildMainContent(context, theme)),
                      bottomNavigationBar: isPanelClose == null || isPanelClose
                          ? buildOverlay(bottomBar(), isBottomBar: true)
                          : null)),
            )));
  }
}
