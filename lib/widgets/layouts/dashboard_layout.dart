import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/bloc/explorer/explorer_bloc.dart';
import 'package:my_wit_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'dart:math' as math;
import 'package:my_wit_wallet/screens/login/bloc/login_bloc.dart';
import 'package:my_wit_wallet/screens/receive_transaction/receive_tx_screen.dart';
import 'package:my_wit_wallet/screens/send_transaction/send_vtt_screen.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/screens/preferences/preferences_screen.dart';
import 'package:my_wit_wallet/widgets//wallet_list.dart';
import 'package:my_wit_wallet/widgets/layouts/layout.dart';
import 'package:my_wit_wallet/screens/login/view/login_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:my_wit_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';
import 'package:my_wit_wallet/util/extensions/string_extensions.dart';

import 'package:my_wit_wallet/shared/locator.dart';

const headerAniInterval = Interval(.1, .3, curve: Curves.easeOut);

class DashboardLayout extends StatefulWidget {
  final ScrollController? scrollController;
  final Widget dashboardChild;
  final List<Widget> actions;
  final Function(PaginationParams)? getPaginatedData;

  DashboardLayout(
      {required this.dashboardChild,
      required this.actions,
      this.getPaginatedData,
      this.scrollController});

  @override
  DashboardLayoutState createState() => DashboardLayoutState();
}

class DashboardLayoutState extends State<DashboardLayout>
    with TickerProviderStateMixin {
  Wallet? walletStorage;
  late Timer explorerTimer;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _goToSettings() async {
    BlocProvider.of<VTTCreateBloc>(context).add(ResetTransactionEvent());
    Navigator.pushReplacementNamed(context, PreferencePage.route);
  }

  Future<void> _showCreateVTTDialog() async {
    Navigator.pushReplacementNamed(context, CreateVttScreen.route);
  }

  Future<void> _showReceiveDialog() async {
    BlocProvider.of<VTTCreateBloc>(context).add(ResetTransactionEvent());
    Navigator.pushReplacementNamed(context, ReceiveTransactionScreen.route);
  }

  String? currentRoute() {
    return ModalRoute.of(context)?.settings.name ?? DashboardScreen.route;
  }

  Color? getButtonColorByRoute(route) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    return currentRoute() == route
        ? extendedTheme.headerDashboardActiveButton
        : extendedTheme.headerTextColor;
  }

  Widget _buildDashboardActions() {
    String currentRoute = ModalRoute.of(context)!.settings.name!;
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      PaddedButton(
        color: getButtonColorByRoute(CreateVttScreen.route),
        padding: EdgeInsets.all(0),
        text: 'Send',
        onPressed: currentRoute != CreateVttScreen.route
            ? _showCreateVTTDialog
            : () {},
        icon: Icon(
          FontAwesomeIcons.locationArrow,
          size: 18,
        ),
        type: 'vertical-icon',
      ),
      PaddedButton(
        color: getButtonColorByRoute(DashboardScreen.route),
        padding: EdgeInsets.all(0),
        text: 'History',
        onPressed: currentRoute != DashboardScreen.route
            ? () => {
                  BlocProvider.of<VTTCreateBloc>(context)
                      .add(ResetTransactionEvent()),
                  Navigator.pushReplacementNamed(
                      context, DashboardScreen.route),
                }
            : () {},
        icon: Icon(
          FontAwesomeIcons.wallet,
          size: 18,
        ),
        type: 'vertical-icon',
      ),
      PaddedButton(
        color: getButtonColorByRoute(ReceiveTransactionScreen.route),
        padding: EdgeInsets.all(0),
        text: 'Receive',
        onPressed: currentRoute != ReceiveTransactionScreen.route
            ? _showReceiveDialog
            : () {},
        icon: Transform.rotate(
            angle: 90 * math.pi / 90,
            child: Icon(
              FontAwesomeIcons.locationArrow,
              size: 18,
            )),
        type: 'vertical-icon',
      ),
    ]);
  }

  Widget _buildBalanceDisplay() {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    return BlocBuilder<DashboardBloc, DashboardState>(
        builder: (BuildContext context, DashboardState state) {
      Wallet currentWallet =
          Locator.instance.get<ApiDatabase>().walletStorage.currentWallet;
      Account currentAccount =
          Locator.instance.get<ApiDatabase>().walletStorage.currentAccount;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 16),
          Text(
            '${currentWallet.balanceNanoWit().availableNanoWit.toInt().standardizeWitUnits()} ${WitUnit.Wit.name}',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium,
          ),
          SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Flexible(
                child: Text(
              currentAccount.address.cropMiddle(18),
              overflow: TextOverflow.ellipsis,
              style: extendedTheme.monoRegularText!
                  .copyWith(color: theme.textTheme.headlineMedium!.color),
            )),
            Flexible(
                child: IconButton(
                    color: theme.textTheme.headlineSmall?.color,
                    padding: EdgeInsets.all(4),
                    constraints: BoxConstraints(),
                    iconSize: 12,
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: currentAccount.address));
                    },
                    icon: Icon(FontAwesomeIcons.copy))),
          ]),
        ],
      );
    });
  }

  Widget _buildDashboardHeader() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildBalanceDisplay(),
        SizedBox(height: 24),
        _buildDashboardActions(),
      ],
    );
  }

  List<Widget> _navigationActions() {
    String currentRoute = ModalRoute.of(context)!.settings.name!;
    return [
      MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            child: Icon(FontAwesomeIcons.gear,
                size: 30, color: getButtonColorByRoute(PreferencePage.route)),
            onTap: currentRoute != PreferencePage.route
                ? () => _goToSettings()
                : () {},
          )),
    ];
  }

  SnackBar buildSnackbar(String text, Color? color, [Function? action]) {
    final theme = Theme.of(context);
    return SnackBar(
      clipBehavior: Clip.none,
      action: action != null
          ? SnackBarAction(
              label: 'Dismiss',
              onPressed: () => action(),
              textColor: Colors.white,
            )
          : null,
      content: Text(text,
          textAlign: TextAlign.left,
          style: theme.textTheme.bodyMedium!.copyWith(color: Colors.white)),
      duration: Duration(hours: 1),
      behavior: SnackBarBehavior.floating,
      backgroundColor: color,
      elevation: 0,
    );
  }

  BlocListener<VTTCreateBloc, VTTCreateState> _vttListener(Widget child) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    return BlocListener<VTTCreateBloc, VTTCreateState>(
      listenWhen: (previousState, currentState) {
        if (previousState.vttCreateStatus == VTTCreateStatus.exception &&
            currentState.vttCreateStatus != VTTCreateStatus.exception) {
          scaffoldMessengerKey.currentState!.showSnackBar(buildSnackbar(
            'Connection reestablished!',
            extendedTheme.txValuePositiveColor,
            () =>
                scaffoldMessengerKey.currentState!.hideCurrentMaterialBanner(),
          ));
        }
        return true;
      },
      listener: (context, state) {
        if (state.vttCreateStatus == VTTCreateStatus.exception) {
          scaffoldMessengerKey.currentState!.showSnackBar(buildSnackbar(
              'myWitWallet is experiencing connection problems',
              theme.colorScheme.error));
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
            currentState.status != ExplorerStatus.unknown) {
          scaffoldMessengerKey.currentState!.showSnackBar(buildSnackbar(
            'Connection reestablished!',
            extendedTheme.txValuePositiveColor,
            () =>
                scaffoldMessengerKey.currentState!.hideCurrentMaterialBanner(),
          ));
        }
        return true;
      },
      listener: (context, state) {
        if (state.status == ExplorerStatus.error) {
          scaffoldMessengerKey.currentState!.showSnackBar(buildSnackbar(
              'myWitWallet is experiencing connection problems',
              theme.colorScheme.error));
        }
      },
      child: child,
    );
  }

  Widget _authBuilder() {
    final theme = Theme.of(context);
    return BlocListener<LoginBloc, LoginState>(
      listener: (BuildContext context, LoginState state) {
        if (state.status == LoginStatus.LoggedOut) {
          Navigator.pushReplacementNamed(context, LoginScreen.route);
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
          builder: (BuildContext context, LoginState loginState) {
        Widget _body;
        Widget? _walletList;
        switch (loginState.status) {
          case LoginStatus.LoggedOut:
            _body = Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SpinKitWave(
                  color: theme.primaryColor,
                ),
              ],
            );
            break;
          case LoginStatus.LoginSuccess:
            _walletList = WalletList();
            _body = _vttListener(_explorerListerner(widget.dashboardChild));
            break;
          default:
            _body = Column(
              children: <Widget>[],
            );
        }
        return Layout(
          scrollController: widget.scrollController,
          getPaginatedData: widget.getPaginatedData,
          navigationActions: _navigationActions(),
          dashboardActions: _buildDashboardHeader(),
          widgetList: [
            _body,
            if (widget.actions.length > 0)
              SizedBox(
                height: 80,
              ),
          ],
          actions: widget.actions,
          slidingPanel: _walletList,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child:
          ScaffoldMessenger(key: scaffoldMessengerKey, child: _authBuilder()),
    );
  }
}
