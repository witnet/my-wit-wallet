import 'dart:async';
import 'package:my_wit_wallet/globals.dart' as globals;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_wit_wallet/bloc/crypto/crypto_bloc.dart';
import 'package:my_wit_wallet/screens/login/view/init_screen.dart';
import 'package:my_wit_wallet/screens/send_transaction/send_vtt_screen.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/auto_updater_overlay.dart';
import 'package:my_wit_wallet/bloc/explorer/explorer_bloc.dart';
import 'package:my_wit_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/util/panel.dart';
import 'package:my_wit_wallet/util/showTxConnectionError.dart';
import 'package:my_wit_wallet/widgets/layouts/listen_fourth_button.dart';
import 'package:my_wit_wallet/widgets/snack_bars.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/modals/general_error_modal.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
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
  final List<Widget> topNavigation;
  final Widget? slidingPanel;
  final Widget? dashboardActions;
  final Widget? bottomNavigation;

  const Layout({
    required this.widgetList,
    required this.actions,
    required this.topNavigation,
    this.bottomNavigation,
    this.dashboardActions,
    this.slidingPanel,
    this.scrollController,
  });

  @override
  LayoutState createState() => LayoutState();
}

final panelController = PanelController();

class LayoutState extends State<Layout> with TickerProviderStateMixin {
  ScrollController defaultScrollController =
      ScrollController(keepScrollOffset: false);
  bool get isUpdateCheckerEnabled => Platform.isMacOS || Platform.isLinux;
  bool get isDashboard => widget.dashboardActions != null;
  bool get isBottomBar =>
      (globals.isPanelClose == null || globals.isPanelClose!);

  @override
  void initState() {
    super.initState();
    PanelUtils().setCloseState();
  }

  BlocListener<VTTCreateBloc, VTTCreateState> _vttListener(Widget child) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    return BlocListener<VTTCreateBloc, VTTCreateState>(
      listenWhen: (previousState, currentState) {
        if (showTxConnectionReEstablish(
            previousState.vttCreateStatus, currentState.vttCreateStatus,
            message: previousState.message)) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(buildErrorSnackbar(
            theme: theme,
            text: localization.connectionReestablished,
            color: extendedTheme.txValuePositiveColor,
            action: () => {
              if (mounted)
                {ScaffoldMessenger.of(context).hideCurrentMaterialBanner()}
            },
          ));
        }
        return true;
      },
      listener: (context, state) {
        if (state.vttCreateStatus == VTTCreateStatus.explorerException) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(buildErrorSnackbar(
              theme: theme,
              text: localization.connectionIssue,
              log: state.message,
              color: theme.colorScheme.error));
        } else if (state.vttCreateStatus == VTTCreateStatus.exception) {
          ScaffoldMessenger.of(context).clearSnackBars();
          buildGeneralExceptionModal(
            theme: theme,
            context: context,
            error: localization.vttException,
            message: localization.vttException,
            errorMessage: state.message,
            iconName: 'general-warning',
            originRouteName: CreateVttScreen.route,
            originRoute: CreateVttScreen(),
          );
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
            theme: theme,
            text: localization.connectionReestablished,
            color: extendedTheme.txValuePositiveColor,
            action: () => {
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
              theme: theme,
              text: localization.connectionIssue,
              log: state.errorMessage,
              color: theme.colorScheme.error));
        }
      },
      child: child,
    );
  }

  void showSnackBar(CryptoExceptionState state) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(buildErrorSnackbar(
        theme: theme,
        text: localization.cryptoException,
        log: state.errorMessage,
        color: theme.colorScheme.error));
    Timer(Duration(seconds: 4), () {
      ScaffoldMessenger.of(context).clearSnackBars();
      Navigator.pushReplacementNamed(context, InitScreen.route);
    });
  }

  BlocListener<CryptoBloc, CryptoState> _cryptoListener(Widget child) {
    return BlocListener<CryptoBloc, CryptoState>(
      listener: (BuildContext context, CryptoState state) {
        if (state.runtimeType == CryptoExceptionState) {
          showSnackBar(state as CryptoExceptionState);
        }
      },
      child: child,
    );
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
          onPanelClosed: () => {
                Timer(Duration(milliseconds: 300),
                    () => setState(() => PanelUtils().setCloseState()))
              },
          body: GestureDetector(
              excludeFromSemantics: true,
              onTap: () => PanelUtils().close(),
              child: Padding(
                  child: _buildMainLayout(context, theme, true),
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom +
                          kBottomNavigationBarHeight +
                          24))));
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
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: extendedTheme.headerBackgroundColor,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
            ),
            pinned: true,
            elevation: 0,
            surfaceTintColor: theme.colorScheme.surface.withOpacity(0.0),
            automaticallyImplyLeading: false,
            scrolledUnderElevation: 0,
            backgroundColor: theme.colorScheme.surface.withOpacity(0.0),
            expandedHeight:
                isDashboard ? DASHBOARD_HEADER_HEIGTH : HEADER_HEIGTH,
            toolbarHeight:
                isDashboard ? DASHBOARD_HEADER_HEIGTH : HEADER_HEIGTH,
            flexibleSpace: headerLayout(context, theme)),
        SliverPadding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 24),
          sliver: SliverToBoxAdapter(
              child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 100,
                maxWidth: 600,
              ),
              child: _cryptoListener(_vttListener(_explorerListerner(
                  Column(mainAxisSize: MainAxisSize.max, children: [
                ...widget.widgetList,
              ])))),
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
        navigationActions: widget.topNavigation,
        dashboardActions: widget.dashboardActions,
      ));
    } else {
      return HeaderLayout(
        navigationActions: [...widget.topNavigation],
        dashboardActions: widget.dashboardActions,
      );
    }
  }

  Widget dashboardBottomBar() {
    final theme = Theme.of(context);
    return BottomAppBar(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 60,
        color: theme.colorScheme.surface,
        notchMargin: 5,
        child: widget.bottomNavigation);
  }

  Widget bottomBar() {
    return BottomSheet(
        onClosing: () => {},
        elevation: 0,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: widget.actions.length > 0 ? 16 : 0),
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
                    child: Column(mainAxisSize: MainAxisSize.max, children: [
                      ...widget.actions,
                      SizedBox(
                        height: MediaQuery.of(context).viewPadding.bottom > 0
                            ? MediaQuery.of(context).viewPadding.bottom
                            : 0,
                      )
                    ]),
                  ),
                )
              ],
            ),
          );
        });
  }

  Widget buildOverlay(Widget child, {bool isBottomBar = false}) {
    return AppLifecycleOverlay(
      isBottomBar: isBottomBar,
      child: child,
    );
  }

  PopScope buildMainScaffold() {
    final theme = Theme.of(context);
    return PopScope(
        // Prevents the page from being popped by the system
        canPop: false,
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: theme.colorScheme.surface,
            body: buildOverlay(buildMainContent(context, theme)),
            bottomNavigationBar: isBottomBar
                ? buildOverlay(isDashboard ? dashboardBottomBar() : bottomBar(),
                    isBottomBar: true)
                : null));
  }

  Widget build(BuildContext context) {
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
                  if (navigator.canPop() &&
                      ModalRoute.of(context)!.settings.name! !=
                          InitScreen.route)
                    {
                      navigator.pop(),
                      if (panelController.isAttached &&
                          panelController.isPanelOpen)
                        {panelController.close()}
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
                  child: isUpdateCheckerEnabled
                      ? AutoUpdate(child: buildMainScaffold())
                      : buildMainScaffold()),
            )));
  }
}
