import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:witnet_wallet/bloc/crypto/crypto_bloc.dart';
import 'package:witnet_wallet/bloc/explorer/explorer_bloc.dart';
import 'package:witnet_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:witnet_wallet/screens/login/bloc/login_bloc.dart';
import 'package:witnet_wallet/widgets/PaddedButton.dart';
import 'package:witnet_wallet/screens/preferences/preferences_screen.dart';
import 'package:witnet_wallet/shared/api_database.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/widgets//wallet_list.dart';
import 'package:witnet_wallet/widgets/layout.dart';
import 'package:witnet_wallet/widgets/round_button.dart';
import 'package:witnet_wallet/widgets/witnet/balance_display.dart';
import 'package:witnet_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/create_vtt_dialog.dart';
import 'package:witnet_wallet/widgets/witnet/wallet/receive_dialog.dart';
import 'package:witnet_wallet/widgets/witnet/wallet/wallet_settings/wallet_settings_dialog.dart';
import '../../../bloc/explorer/explorer_bloc.dart';
import '../../login/view/login_screen.dart';
import '../../screen_transitions/fade_transition.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../api_dashboard.dart';
import '../bloc/dashboard_bloc.dart';
import 'package:witnet_wallet/theme/extended_theme.dart';

import 'package:witnet_wallet/util/storage/database/account.dart';
import 'package:witnet_wallet/util/storage/database/wallet_storage.dart';
import 'package:witnet_wallet/screens/login/view/login_screen.dart';
import 'package:witnet_wallet/screens/screen_transitions/fade_transition.dart';
import 'package:witnet_wallet/screens/dashboard/api_dashboard.dart';
import 'package:witnet_wallet/screens/dashboard/bloc/dashboard_bloc.dart';

const headerAniInterval = Interval(.1, .3, curve: Curves.easeOut);

class DashboardScreen extends StatefulWidget {
  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  Map<String, Account> externalAccounts = {};
  Map<String, Account> internalAccounts = {};

  late WalletStorage? walletStorage;
  late AnimationController _loadingController;
  late AnimationController _balanceController;
  List<String>? walletList;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _balanceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _loadingController.forward();
    _balanceController.forward();
  }

  /// _goToSettings
  /// [BuildContext] context
  Future<bool> _goToSettings() {
    return Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (context) => PreferencePage(),
        ))
        .then((_) => true);
  }

  //Log out
  void _logOut() {
    BlocProvider.of<DashboardBloc>(context).add(DashboardResetEvent());
    BlocProvider.of<CryptoBloc>(context).add(CryptoReadyEvent());
    BlocProvider.of<LoginBloc>(context).add(LoginLogoutEvent());
  }

  Future<void> _showWalletSettingsDialog() async {
    ApiDashboard apiDashboard = Locator.instance<ApiDashboard>();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return WalletSettingsDialog(
          walletStorage: apiDashboard.walletStorage!,
        );
      },
    );
  }

  Future<void> _showCreateVTTDialog() async {
    ApiDashboard apiDashboard = Locator.instance<ApiDashboard>();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CreateVTTDialogBox(
          walletStorage: apiDashboard.walletStorage!,
        );
      },
    );
  }

  Future<void> _showReceiveDialog() async {
    ApiDatabase db = Locator.instance<ApiDatabase>();
    WalletStorage walletStorage = await db.loadWalletsDatabase();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return ReceiveDialogBox(
          walletStorage: walletStorage,
        );
      },
    );
  }

  Widget _buildDashboardGrid(ThemeData themeData, DashboardState state) {
    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );
    final extendedTheme = Theme.of(context).extension<ExtendedTheme>()!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildBalanceDisplay(),
        RoundButton(
          size: 40,
          icon: Icon(FontAwesomeIcons.arrowUp),
          onPressed: _showCreateVTTDialog,
          label: 'Send',
          loadingController: _loadingController,
        ),
        RoundButton(
          size: 40,
          icon: Icon(FontAwesomeIcons.arrowDown),
          onPressed: _showReceiveDialog,
          label: 'Receive',
          loadingController: _loadingController,
        ),
        RoundButton(
          size: 40,
          icon: Icon(FontAwesomeIcons.userCog),
          onPressed: _showWalletSettingsDialog,
          label: 'Settings',
          loadingController: _loadingController,
        ),
        buildSyncButton(),
        // WalletList(),
        // TransactionHistory(themeData: themeData, externalAccounts: externalAccounts, internalAccounts: internalAccounts,),
      ],
    );
  }

  void _setWallet(WalletStorage dbWallet) {
    this.walletStorage = dbWallet;
  }

  Widget explorerWatcher() {
    return BlocBuilder<ExplorerBloc, ExplorerState>(
      builder: (context, state) {
        ApiDashboard apiDashboard = Locator.instance<ApiDashboard>();
        if (state.status == ExplorerStatus.ready) {
          //this.dbWallet = apiDashboard.dbWallet;
          return Container();
        } else if (state.status == ExplorerStatus.dataloaded) {
          walletStorage = apiDashboard.walletStorage;
          return Container();
        } else {
          return Container();
        }
      },
    );
  }

  Widget buildSyncButton() {
    return BlocConsumer<ExplorerBloc, ExplorerState>(builder: (context, state) {
      final theme = Theme.of(context);

      if (state.status == ExplorerStatus.ready) {
        return Column(
          children: <Widget>[
            RoundButton(
              size: 40,
              icon: Icon(FontAwesomeIcons.circle),
              onPressed: () {
                BlocProvider.of<ExplorerBloc>(context)
                    .add(SyncWalletEvent(ExplorerStatus.dataloading));
              },
              label: 'Sync',
              loadingController: _loadingController,
            ),
          ],
        );
      } else if (state.status == ExplorerStatus.dataloading) {
        return SpinKitCircle(
          color: theme.primaryColor,
        );
      } else if (state.status == ExplorerStatus.dataloaded) {
        return Column(
          children: <Widget>[
            RoundButton(
              size: 40,
              icon: Icon(FontAwesomeIcons.circle),
              onPressed: () {
                BlocProvider.of<ExplorerBloc>(context)
                    .add(SyncWalletEvent(ExplorerStatus.dataloading));
              },
              label: 'Sync',
              loadingController: _loadingController,
            ),
          ],
        );
      } else {
        return Column(
          children: <Widget>[
            RoundButton(
              size: 40,
              icon: Icon(FontAwesomeIcons.circle),
              onPressed: () {
                BlocProvider.of<ExplorerBloc>(context)
                    .add(SyncWalletEvent(ExplorerStatus.dataloading));
              },
              label: 'Sync',
              loadingController: _loadingController,
            ),
          ],
        );
      }
    }, listener: (context, state) {
      if (state.status == ExplorerStatus.ready) {
        ApiDashboard apiDashboard = Locator.instance.get<ApiDashboard>();
        setState(() {
          walletStorage = apiDashboard.walletStorage;
        });
      }
    });
  }

  Widget _buildBalanceDisplay() {
    return BlocConsumer<ExplorerBloc, ExplorerState>(builder: (context, state) {
      return BalanceDisplay(_balanceController);
    }, listener: (context, state) {
      if (state.status == ExplorerStatus.ready) {
        ApiDashboard apiDashboard = Locator.instance.get<ApiDashboard>();
        setState(() {
          BlocProvider.of<DashboardBloc>(context).add(DashboardLoadEvent());
          walletStorage = state.walletStorage;
          apiDashboard.setWallets(walletStorage);

          _balanceController.reset();
          _balanceController.forward();
        });
      }
    });
  }

  Widget _dashboardBuilder() {
    final theme = Theme.of(context);
    return BlocBuilder<DashboardBloc, DashboardState>(
        builder: (BuildContext context, DashboardState state) {
      if (state.status == DashboardStatus.Loading) {
        return _buildDashboardGrid(theme, state);
      } else if (state.status == DashboardStatus.Synchronized) {
        walletStorage = state.walletStorage;
        return _buildDashboardGrid(theme, state);
      } else if (state.status == DashboardStatus.Synchronizing) {
        return SpinKitWave(
          color: theme.primaryColor,
        );
      } else if (state.status == DashboardStatus.Ready) {
        walletStorage = state.walletStorage;
        if (walletStorage != null) {
          BlocProvider.of<VTTCreateBloc>(context).setWallets(walletStorage);
        }
        return _buildDashboardGrid(theme, state);
      } else {
        return SpinKitWave(
          color: theme.primaryColor,
        );
      }
    });
  }

  List<Widget> _headerActions() {
    return [
      Row(children: [
        PaddedButton(
            padding: EdgeInsets.only(bottom: 8),
            text: 'Log out',
            type: 'text',
            enabled: true,
            onPressed: () => _logOut()),
        PaddedButton(
          padding: EdgeInsets.only(bottom: 8),
          text: 'Settings',
          type: 'text',
          enabled: true,
          onPressed: () => _goToSettings(),
        ),
      ]),
    ];
  }

  Widget _authBuilder() {
    final theme = Theme.of(context);
    // TODO: LoggedOutState
    // TODO: LoadingLogoutState
    // TODO: LoggedInState

    return BlocBuilder<LoginBloc, LoginState>(
        buildWhen: (previousState, loginState) {
      if (loginState.status == LoginStatus.LoggedOut) {
        Navigator.pushReplacement(context, FadeRoute(page: LoginScreen()));
      }
      return true;
    }, builder: (BuildContext context, LoginState loginState) {
      Widget _body;
      switch (loginState.status) {
        case LoginStatus.LoggedOut:
          _body = Stack(
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SpinKitWave(
                    color: theme.primaryColor,
                  ),
                ],
              ),
            ],
          );
          break;
        case LoginStatus.LoginSuccess:
          //authState as LoggedInState;

          _body = Stack(
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    child: _dashboardBuilder(),
                  ),
                ],
              ),
            ],
          );
          break;
        default:
          _body = Stack(
            children: <Widget>[
              Column(
                children: <Widget>[],
              ),
            ],
          );
      }
      return Layout(
        headerActions: _headerActions(),
        widgetList: [
          _body,
        ],
        actions: [],
        slidingPanel: WalletList(),
        actionsSize: 0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: _authBuilder(),
    );
  }
}
