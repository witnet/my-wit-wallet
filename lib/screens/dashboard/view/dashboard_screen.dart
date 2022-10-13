import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:witnet_wallet/bloc/crypto/crypto_bloc.dart';
import 'package:witnet_wallet/bloc/explorer/explorer_bloc.dart';
import 'package:witnet_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:witnet_wallet/screens/login/bloc/login_bloc.dart';
import 'package:witnet_wallet/screens/preferences/preferences_screen.dart';
import 'package:witnet_wallet/shared/api_database.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/widgets/fade_in.dart';
import 'package:witnet_wallet/widgets/round_button.dart';
import 'package:witnet_wallet/widgets/witnet/balance_display.dart';
import 'package:witnet_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/create_vtt_dialog.dart';
import 'package:witnet_wallet/widgets/witnet/wallet/receive_dialog.dart';
import 'package:witnet_wallet/widgets/witnet/wallet/wallet_settings/wallet_settings_dialog.dart';

import 'package:witnet_wallet/util/storage/database/account.dart';
import 'package:witnet_wallet/util/storage/database/wallet_storage.dart';
import 'package:witnet_wallet/screens/login/view/login_screen.dart';
import 'package:witnet_wallet/screens/screen_transitions/fade_transition.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
  Future<bool> _goToSettings(BuildContext context) {
    return Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (context) => PreferencePage(),
        ))
        .then((_) => true);
  }

  /// _buildAppBar
  /// [ThemeData] theme
  AppBar _buildAppBar(ThemeData theme) {
    final menuBtn = IconButton(
      color: theme.primaryColor,
      icon: const Icon(FontAwesomeIcons.bars),
      onPressed: () => _goToSettings(context),
    );

    final logoutButton = IconButton(
      icon: const Icon(FontAwesomeIcons.userLock),
      color: theme.primaryColor,
      onPressed: () {
        BlocProvider.of<DashboardBloc>(context).add(DashboardResetEvent());
        BlocProvider.of<CryptoBloc>(context).add(CryptoReadyEvent());
        BlocProvider.of<LoginBloc>(context).add(LoginLogoutEvent());
      },
    );

    final title = Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(width: 20),
        ],
      ),
    );

    return AppBar(
      leading: FadeIn(
        controller: _loadingController,
        offset: .3,
        curve: headerAniInterval,
        fadeDirection: FadeDirection.startToEnd,
        duration: Duration(milliseconds: 300),
        child: menuBtn,
      ),
      actions: <Widget>[
        FadeIn(
          controller: _loadingController,
          offset: .3,
          curve: headerAniInterval,
          fadeDirection: FadeDirection.endToStart,
          duration: Duration(milliseconds: 300),
          child: logoutButton,
        ),
      ],
      title: title,
      backgroundColor: theme.primaryColor.withOpacity(.1),
      elevation: 0,
      iconTheme: theme.iconTheme,
      toolbarTextStyle: theme.textTheme.bodyText2,
      titleTextStyle: theme.textTheme.headline6,
    );
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildBalanceDisplay(),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                icon: Icon(FontAwesomeIcons.userGear),
                onPressed: _showWalletSettingsDialog,
                label: 'Settings',
                loadingController: _loadingController,
              ),
              buildSyncButton(),
            ],
          ),
        ),
        // TransactionHistory(themeData: themeData, externalAccounts: externalAccounts, internalAccounts: internalAccounts,),
      ],
    );
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
              icon: Icon(FontAwesomeIcons.arrowsRotate),
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
              icon: Icon(FontAwesomeIcons.arrowsRotate),
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
              icon: Icon(FontAwesomeIcons.arrowsRotate),
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
        return SizedBox(
          child: SpinKitWave(
            color: theme.primaryColor,
          ),
        );
      } else if (state.status == DashboardStatus.Ready) {
        walletStorage = state.walletStorage;
        if (walletStorage != null) {
          BlocProvider.of<VTTCreateBloc>(context).setWallets(walletStorage);
        }
        return _buildDashboardGrid(theme, state);
      } else {
        return SizedBox(
          child: SpinKitWave(
            color: theme.primaryColor,
          ),
        );
      }
    });
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
          _body = Container(
            width: double.infinity,
            height: double.infinity,
            color: theme.canvasColor.withOpacity(.9),
            child: Stack(
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      child: SpinKitWave(
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
          break;
        case LoginStatus.LoginSuccess:
          //authState as LoggedInState;

          _body = Container(
            width: double.infinity,
            height: double.infinity,
            color: theme.primaryColor.withOpacity(.1),
            child: Stack(
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      child: _dashboardBuilder(),
                    ),
                  ],
                ),
              ],
            ),
          );
          break;
        default:
          _body = Container(
            width: double.infinity,
            height: double.infinity,
            color: theme.primaryColor.withOpacity(.1),
            child: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ],
            ),
          );
      }

      return Scaffold(
        appBar: _buildAppBar(theme),
        resizeToAvoidBottomInset: false,
        body: new GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: _body),
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
