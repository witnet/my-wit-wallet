import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:my_wit_wallet/bloc/crypto/crypto_bloc.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/extensions/string_extensions.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:my_wit_wallet/screens/create_wallet/nav_action.dart';
import 'package:my_wit_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:my_wit_wallet/screens/login/bloc/login_bloc.dart';
import 'package:my_wit_wallet/screens/login/view/init_screen.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/animated_numeric_text.dart';
import 'package:my_wit_wallet/widgets/auto_size_text.dart';
import 'package:my_wit_wallet/widgets/layouts/dashboard_layout.dart';
import 'package:my_wit_wallet/widgets/snack_bars.dart';
import 'package:witnet/utils.dart';

typedef void VoidCallback(NavAction? value);
typedef void BooleanCallback(bool value);

class BuildWalletCard extends StatefulWidget {
  final Function nextAction;
  final Function prevAction;
  final Function hideButton;

  BuildWalletCard(
      {Key? key,
      required VoidCallback this.nextAction,
      required VoidCallback this.prevAction,
      required BooleanCallback this.hideButton})
      : super(key: key);

  BuildWalletCardState createState() => BuildWalletCardState();
}

class BuildWalletCardState extends State<BuildWalletCard>
    with TickerProviderStateMixin {
  late AnimationController _loadingController;
  late AnimationController _balanceController;
  int balance = 0;
  int previousBalance = 0;
  String walletId = '00000000';
  int currentAddressCount = 0;
  int currentTransactionCount = 0;
  static const headerAniInterval = Interval(.1, .3, curve: Curves.easeOut);

  bool get isHdWallet =>
      Locator.instance<ApiCreateWallet>().walletType == WalletType.hd;

  void prevAction() {
    CreateWalletType type =
        BlocProvider.of<CreateWalletBloc>(context).state.createWalletType;
    BlocProvider.of<CreateWalletBloc>(context).add(PreviousCardEvent(type));
  }

  void nextAction() {
    CreateWalletType type =
        BlocProvider.of<CreateWalletBloc>(context).state.createWalletType;
    BlocProvider.of<CreateWalletBloc>(context)
        .add(NextCardEvent(type, data: {}));
  }

  NavAction prev() {
    return NavAction(
      label: localization.backLabel,
      action: prevAction,
    );
  }

  NavAction next() {
    return NavAction(
      label: localization.continueLabel,
      action: nextAction,
    );
  }

  late TextEditingController _nameController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _balanceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _nameController = TextEditingController();
    _descController = TextEditingController();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.prevAction(prev));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.nextAction(next));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.hideButton(true));

    ApiCreateWallet acw = Locator.instance<ApiCreateWallet>();
    BlocProvider.of<CryptoBloc>(context).add(CryptoInitializeWalletEvent(
        walletType: acw.walletType,
        id: acw.walletName,
        walletName: acw.walletName,
        keyData: acw.seedData!,
        seedSource: acw.seedSource!,
        password: acw.password ?? ''));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _balanceController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  Widget initStatus(
      {required ThemeData theme,
      required int addressCount,
      required int startingBalance,
      required int balanceNanoWit,
      required int transactionCount,
      required String message}) {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(localization.buildWalletHeader,
              style: theme.textTheme.titleLarge),
        ],
      ),
      SizedBox(
        height: 20,
      ),
      Row(children: [
        Expanded(
            flex: 1,
            child: Text(
              localization.buildWallet01,
              style: theme.textTheme.bodyLarge,
            ))
      ]),
      SizedBox(
        height: 20,
      ),
    ]);
  }

  void initializeWalletEvent(CryptoReadyState state) {
    ApiCreateWallet acw = Locator.instance<ApiCreateWallet>();
    if (acw.walletName != '') {
      BlocProvider.of<CryptoBloc>(context).add(
        CryptoInitializeWalletEvent(
            walletType: acw.walletType,
            id: acw.walletName,
            walletName: acw.walletName,
            keyData: acw.seedData!,
            seedSource: acw.seedSource!,
            password: acw.password ?? ''),
      );
    }
  }

  void initializingWallet(CryptoInitializingWalletState state) {
    setState(() {
      _balanceController.reset();
      _balanceController.forward();
      previousBalance = balance;
      balance = state.balanceInfo.availableNanoWit;
      currentAddressCount = state.addressCount;
      currentTransactionCount = state.transactionCount;
    });
  }

  void cryptoLoadedWalletState(CryptoLoadedWalletState state) {
    Locator.instance<ApiCreateWallet>().clearFormData();
    setState(() {
      walletId = state.wallet.id;
    });
    BlocProvider.of<LoginBloc>(context)
        .add(LoginSubmittedEvent(password: state.password));
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

  Map<dynamic, Function> blocAction() {
    return {
      CryptoReadyState: initializeWalletEvent,
      CryptoInitializingWalletState: initializingWallet,
      CryptoLoadedWalletState: cryptoLoadedWalletState,
      CryptoExceptionState: showSnackBar,
    };
  }

  BlocListener _cryptoBlocListener() {
    return BlocListener<CryptoBloc, CryptoState>(
      listener: (BuildContext context, CryptoState state) {
        if (blocAction()[state.runtimeType] != null) {
          blocAction()[state.runtimeType]!(state);
        }
      },
      child: _cryptoBlocBuilder(),
    );
  }

  Widget _cryptoBlocBuilder() {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    return BlocBuilder<CryptoBloc, CryptoState>(
      builder: (context, state) {
        if (state is CryptoInitializingWalletState) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => widget.prevAction(null));
          WidgetsBinding.instance
              .addPostFrameCallback((_) => widget.nextAction(null));
          return Column(
            children: [
              initStatus(
                  theme: theme,
                  addressCount: state.addressCount,
                  startingBalance: previousBalance,
                  balanceNanoWit: state.balanceInfo.availableNanoWit,
                  transactionCount: state.transactionCount,
                  message: state.message),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                child: SpinKitWave(
                  color: theme.primaryColor,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(localization.buildWalletBalance,
                                  style: theme.textTheme.titleMedium),
                              SizedBox(
                                height: 8,
                              ),
                            ],
                          ),
                          Row(children: [
                            AnimatedNumericText(
                              initialValue: nanoWitToWit(previousBalance),
                              targetValue: nanoWitToWit(balance),
                              curve: Interval(0, .5, curve: Curves.easeOut),
                              controller: _balanceController,
                              style: theme.textTheme.bodyMedium!,
                            ),
                            SizedBox(width: 4),
                            Text('WIT', style: theme.textTheme.bodyMedium!),
                          ]),
                        ],
                      ))
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text(localization.transactionsFound,
                      style: theme.textTheme.titleMedium!),
                  AutoSizeText(
                    '$currentTransactionCount',
                    maxLines: 2,
                    minFontSize: 16,
                    style: theme.textTheme.bodyMedium!,
                  )
                ],
              ),
              if (isHdWallet)
                Row(
                  children: [
                    Text(
                      localization.exploredAddresses,
                      style: theme.textTheme.titleMedium,
                    ),
                    AnimatedIntegerText(
                        initialValue: currentAddressCount,
                        // TODO:targetValue: addressCount,
                        targetValue: currentAddressCount,
                        curve: Interval(0, .5, curve: Curves.easeOut),
                        controller: _balanceController,
                        style: theme.textTheme.bodyMedium!)
                  ],
                ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text(
                    localization.exploringAddress,
                    style: theme.textTheme.titleMedium!,
                  ),
                  Expanded(
                      flex: 1,
                      child: Text(
                          state.message.contains('wit1')
                              ? state.message.cropMiddle(18)
                              : state.message,
                          style: extendedTheme.monoMediumText)),
                ],
              ),
            ],
          );

          //initStatus(theme, 0, state.addressCount, state.balanceNanoWit, state.transactionCount, state.message);
        }
        if (state is CryptoLoadedWalletState) {
          return Column(children: [
            SizedBox(
              child: SpinKitWave(
                color: theme.primaryColor,
              ),
            ),
            AutoSizeText(
              '',
              maxLines: 1,
              minFontSize: 9,
            ),
          ]);
        } else if (state is CryptoReadyState) {
          return Column(
            children: [
              SizedBox(
                child: SpinKitWave(
                  color: theme.primaryColor,
                ),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              SpinKitCircle(
                color: theme.primaryColor,
              ),
            ],
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    var listenStatus = true;
    final cardWidth = min(deviceSize.width * 0.95, 360.0);
    return BlocListener<LoginBloc, LoginState>(
        listenWhen: (previous, current) {
          return listenStatus;
        },
        listener: (BuildContext context, LoginState state) {
          if (state.status == LoginStatus.LoginSuccess) {
            BlocProvider.of<CryptoBloc>(context).add(CryptoReadyEvent());
            listenStatus = false;
            Navigator.pushReplacement(
                context,
                CustomPageRoute(
                    builder: (BuildContext context) {
                      return DashboardScreen();
                    },
                    maintainState: false,
                    settings: RouteSettings(name: DashboardScreen.route)));
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: cardWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _cryptoBlocListener(),
                ],
              ),
            )
          ],
        ));
  }
}
