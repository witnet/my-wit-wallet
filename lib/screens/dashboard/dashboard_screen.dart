
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:witnet_wallet/bloc/auth/auth_bloc.dart';
import 'package:witnet_wallet/bloc/crypto/crypto_bloc.dart';
import 'package:witnet_wallet/bloc/explorer/explorer_bloc.dart';
import 'package:witnet_wallet/bloc/transactions/value_transfer/create_vtt_bloc.dart';
import 'package:witnet_wallet/bloc/transactions/value_transfer/vtt_status_bloc.dart';
import 'package:witnet_wallet/screens/preferences/preferences_screen.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/util/storage/database/db_wallet.dart';
import 'package:witnet_wallet/util/witnet/wallet/account.dart';
import 'package:witnet_wallet/widgets/fade_in.dart';
import 'package:witnet_wallet/widgets/round_button.dart';
import 'package:witnet_wallet/widgets/svg_widget.dart';
import 'package:witnet_wallet/widgets/witnet/balance_display.dart';
import 'package:witnet_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/create_vtt_dialog.dart';
import 'package:witnet_wallet/widgets/witnet/wallet/receive_dialog.dart';
import 'package:witnet_wallet/widgets/witnet/wallet/wallet_settings/wallet_settings_dialog.dart';
import '../../constants.dart';
import '../login/login_screen.dart';
import '../screen_transitions/fade_transition.dart';
import 'package:witnet_wallet/theme/colors.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'api_dashboard.dart';
import 'dashboard_bloc.dart';

const headerAniInterval = Interval(.1, .3, curve: Curves.easeOut);

class DashboardScreen extends StatefulWidget {
  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  Map<String, Account> externalAccounts = {};
  Map<String, Account> internalAccounts = {};

  late DbWallet? dbWallet;
  late AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    //BlocStatusVtt blocStatusVtt = BlocStatusVtt(UnknownHashState());
    //blocStatusVtt.add(CheckStatusEvent(transactionHash: 'a90a59d47f8b3a9c696e67b5c7591ebe244cd24421e9c0f24def1f9d5763051b'));
    // BlocProvider.of<BlocDashboard>(context).add(DashboardInitEvent(externalAccounts: {}, internalAccounts: {}));
  }

  Future<bool> _goToSettings(BuildContext context) {
    return Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (context) => PreferencePage(),
        ))
        .then((_) => true);
  }

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
        BlocProvider.of<BlocDashboard>(context).add(DashboardResetEvent());
        BlocProvider.of<BlocCrypto>(context).add(CryptoReadyEvent());
        BlocProvider.of<BlocAuth>(context).add(LogoutEvent());
      },
    );

    final title = Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Hero(
              tag: Constants.logoTag,
              child: SVGWidget(
                size: 30,
                title: '',
                img: 'favicon',
              ),
            ),
          ),
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
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return WalletSettingsDialog(
          dbWallet: dbWallet!,
        );
      },
    );
  }

  Future<void> _showCreateVTTDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CreateVTTDialogBox(dbWallet: dbWallet!,);
      },
    );
  }

  Future<void> _showReceiveDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return ReceiveDialogBox(dbWallet: dbWallet!,);
      },
    );
  }

  Widget _buildDashboardGrid(ThemeData themeData, DashboardState state) {
    final size = MediaQuery.of(context).size;

    ApiDashboard apiDashboard = Locator.instance<ApiDashboard>();

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            BalanceDisplay(_loadingController),
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
                    icon: Icon(FontAwesomeIcons.userCog),
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
      final theme = Theme.of(context);
    return BlocBuilder<BlocExplorer, ExplorerState>(builder: (context, state) {
      ApiDashboard apiDashboard = Locator.instance<ApiDashboard>();
      if (state is ReadyState) {

        this.dbWallet = apiDashboard.dbWallet;

        return Container();
      } else if (state is DataLoadingState) {

          dbWallet = apiDashboard.dbWallet;

        return Container();
      } else if (state is DataLoadedState) {

          dbWallet = apiDashboard.dbWallet;

        return Container();
      } else {
        return Container();
      }
    },
    );
  }

  Widget buildSyncButton() {
    return BlocConsumer<BlocExplorer,ExplorerState>(builder: (context, state) {
      final theme = Theme.of(context);


      if (state is ReadyState) {
        return Column(
          children: <Widget>[
            RoundButton(
              size: 40,
              icon: Icon(FontAwesomeIcons.sync),
              onPressed: () {
                BlocProvider.of<BlocExplorer>(context).add(SyncWalletEvent());
              },
              label: 'Sync',
              loadingController: _loadingController,
            ),
          ],
        );
      } else if (state is DataLoadingState) {
        return SpinKitCircle(
          color: theme.primaryColor,
        );
      } else if (state is DataLoadedState) {
        return Column(
          children: <Widget>[
            RoundButton(
              size: 40,
              icon: Icon(FontAwesomeIcons.sync),
              onPressed: () {
                BlocProvider.of<BlocExplorer>(context).add(SyncWalletEvent());
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
              icon: Icon(FontAwesomeIcons.sync),
              onPressed: () {
                BlocProvider.of<BlocExplorer>(context).add(SyncWalletEvent());
              },
              label: 'Sync',
              loadingController: _loadingController,
            ),
          ],
        );
      }
    }, listener: (context, state) {
      if (state is ReadyState){
        ApiDashboard apiDashboard = Locator.instance.get<ApiDashboard>();
       setState(() {
         dbWallet = apiDashboard.dbWallet;
       });
      }

    });
  }

  Widget _dashboardBuilder() {
    final theme = Theme.of(context);
    return BlocBuilder<BlocDashboard, DashboardState>(
        builder: (BuildContext context, DashboardState dashboardState) {
      switch (dashboardState.runtimeType) {
        case DashboardLoadingState:
          return _buildDashboardGrid(theme, dashboardState);
        case DashboardSynchronizedState:
          dbWallet = dashboardState.dbWallet;
          return _buildDashboardGrid(theme, dashboardState);
        case DashboardSynchronizingState:
        case DashboardReadyState:
          dbWallet = dashboardState.dbWallet;
          if(dbWallet != null){

          BlocProvider.of<BlocCreateVTT>(context).setDbWallet(dbWallet);
          }
          return _buildDashboardGrid(theme, dashboardState);
        default:
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
    return BlocBuilder<BlocAuth, AuthState>(
        buildWhen: (previousState, authState) {
      if (authState is LoggedOutState) {
        Navigator.pushReplacement(context, FadeRoute(page: LoginScreen()));
      }
      return true;
    }, builder: (BuildContext context, AuthState authState) {
          Widget _body;
      switch (authState.runtimeType) {
        case LoadingLogoutState:
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
        case LoggedInState:
          authState as LoggedInState;

          dbWallet = authState.wallet;
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
                      //_buildDashboardGrid(theme, authState),
                    ),
                  ],
                ),
              ],
            ),
          );
        break;
          default:
          _body =  Container(
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
          child: _body
        ),
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

