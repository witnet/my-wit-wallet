import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:witnet/utils.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:witnet_wallet/screens/login/bloc/login_bloc.dart';
import 'package:witnet_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:witnet_wallet/theme/colors.dart';
import 'package:witnet_wallet/widgets/animated_numeric_text.dart';
import 'package:witnet_wallet/widgets/auto_size_text.dart';
import 'package:witnet_wallet/bloc/crypto/crypto_bloc.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/screens/create_wallet/nav_action.dart';

typedef void VoidCallback(NavAction? value);

class BuildWalletCard extends StatefulWidget {
  final Function nextAction;
  final Function prevAction;
  BuildWalletCard({
    Key? key,
    required VoidCallback this.nextAction,
    required VoidCallback this.prevAction,
  }) : super(key: key);
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
  void prevAction() {
    WalletType type =
        BlocProvider.of<CreateWalletBloc>(context).state.walletType;
    BlocProvider.of<CreateWalletBloc>(context).add(PreviousCardEvent(type));
  }

  void nextAction() {
    WalletType type =
        BlocProvider.of<CreateWalletBloc>(context).state.walletType;
    BlocProvider.of<CreateWalletBloc>(context)
        .add(NextCardEvent(type, data: {}));
  }

  NavAction prev() {
    return NavAction(
      label: 'Back',
      action: prevAction,
    );
  }

  NavAction next() {
    return NavAction(
      label: 'Continue',
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
    ApiCreateWallet acw = Locator.instance<ApiCreateWallet>();
    BlocProvider.of<CryptoBloc>(context).add(CryptoInitializeWalletEvent(
        id: acw.walletName,
        walletName: acw.walletName,
        walletDescription: acw.walletDescription!,
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
    final accentColor = theme.primaryColor;
    final bgMat = createMaterialColor(accentColor);
    final linearGradient = LinearGradient(colors: [
      bgMat.shade700,
      bgMat.shade600,
      bgMat.shade500,
      bgMat.shade400,
    ]).createShader(Rect.fromLTWH(0.0, 0.0, 100.0, 78.0));
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        AnimatedNumericText(
          initialValue: nanoWitToWit(previousBalance),
          targetValue: nanoWitToWit(balance),
          curve: Interval(0, .5, curve: Curves.easeOut),
          controller: _balanceController,
          style: theme.textTheme.bodyLarge!,
        ),
        SizedBox(width: 5),
        Text(
          'wit',
          style: theme.textTheme.bodyLarge!,
        ),
      ]),
      SizedBox(
        height: 20,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              flex: 1,
              child: Row(
                children: [
                  AutoSizeText('Total addresses:  ',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      minFontSize: 9,
                      style: theme.textTheme.bodyLarge!.copyWith(
                        foreground: Paint()..shader = linearGradient,
                      )),
                  AnimatedIntegerText(
                    initialValue: currentAddressCount,
                    targetValue: addressCount,
                    curve: Interval(0, .5, curve: Curves.easeOut),
                    controller: _balanceController,
                    style: theme.textTheme.bodyLarge!.copyWith(
                      foreground: Paint()..shader = linearGradient,
                    ),
                  ),
                ],
              )),
          Expanded(
            flex: 1,
            child: AutoSizeText('Transactions: $transactionCount',
                textAlign: TextAlign.center,
                maxLines: 1,
                minFontSize: 9,
                style: theme.textTheme.bodyLarge!.copyWith(
                  foreground: Paint()..shader = linearGradient,
                )),
          )
        ],
      ),
      SizedBox(
        height: 20,
      ),
      Row(
        children: [
          Expanded(
            flex: 1,
            child: AutoSizeText('Current Address: $message',
                maxLines: 2,
                minFontSize: 14,
                style: theme.textTheme.bodyLarge!.copyWith(
                  foreground: Paint()..shader = linearGradient,
                )),
          ),
        ],
      ),
      SizedBox(
        height: 40,
      ),
    ]);
  }

  BlocListener _cryptoBlocListener() {
    return BlocListener<CryptoBloc, CryptoState>(
      listener: (BuildContext context, CryptoState state) {
        if (state is CryptoReadyState) {
          ApiCreateWallet acw = Locator.instance<ApiCreateWallet>();
          if (acw.walletName != '') {
            BlocProvider.of<CryptoBloc>(context).add(
              CryptoInitializeWalletEvent(
                  id: acw.walletName,
                  walletName: acw.walletName,
                  walletDescription: acw.walletDescription!,
                  keyData: acw.seedData!,
                  seedSource: acw.seedSource!,
                  password: acw.password ?? ''),
            );
          }
        }

        if (state is CryptoInitializingWalletState) {
          setState(() {
            _balanceController.reset();
            _balanceController.forward();
            previousBalance = balance;
            balance = state.availableNanoWit;
            currentAddressCount = state.addressCount;
            currentTransactionCount = state.transactionCount;
          });
        } else if (state is CryptoLoadedWalletState) {
          Locator.instance<ApiCreateWallet>().clearFormData();
          setState(() {
            walletId = state.wallet.id;
          });
          BlocProvider.of<LoginBloc>(context)
              .add(LoginSubmittedEvent(password: state.password));
        }
      },
      child: _cryptoBlocBuilder(),
    );
  }

  Widget _cryptoBlocBuilder() {
    return BlocBuilder<CryptoBloc, CryptoState>(
      builder: (context, state) {
        final theme = Theme.of(context);
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
                  balanceNanoWit: state.availableNanoWit,
                  transactionCount: state.transactionCount,
                  message: state.message),
              SizedBox(
                child: SpinKitWave(
                  color: theme.primaryColor,
                ),
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
            Navigator.pushReplacementNamed(context, DashboardScreen.route);
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
