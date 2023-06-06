import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:witnet/utils.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:my_wit_wallet/screens/login/bloc/login_bloc.dart';
import 'package:my_wit_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:my_wit_wallet/theme/colors.dart';
import 'package:my_wit_wallet/widgets/animated_numeric_text.dart';
import 'package:my_wit_wallet/widgets/auto_size_text.dart';
import 'package:my_wit_wallet/bloc/crypto/crypto_bloc.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/screens/create_wallet/nav_action.dart';

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
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.hideButton(true));

    ApiCreateWallet acw = Locator.instance<ApiCreateWallet>();
    BlocProvider.of<CryptoBloc>(context).add(CryptoInitializeWalletEvent(
        id: acw.walletName,
        walletName: acw.walletName,
        walletDescription: acw.walletDescription,
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
          Text("Address discovery", style: theme.textTheme.titleLarge),
        ],
      ),
      SizedBox(
        height: 20,
      ),
      Row(children: [
        Expanded(
            flex: 1,
            child: Text(
              "The different addresses in your wallet are being scanned for existing transactions and balance. This will normally take less than 1 minute.",
              style: theme.textTheme.bodyLarge,
            ))
      ]),
      SizedBox(
        height: 20,
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
                  walletDescription: acw.walletDescription,
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
    final theme = Theme.of(context);
    final accentColor = theme.primaryColor;
    final bgMat = createMaterialColor(accentColor);
    final linearGradient = LinearGradient(colors: [
      bgMat.shade700,
      bgMat.shade600,
      bgMat.shade500,
      bgMat.shade400,
    ]).createShader(Rect.fromLTWH(0.0, 0.0, 100.0, 78.0));
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
                  balanceNanoWit: state.availableNanoWit,
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
                              Text("Balance:",
                                  style: theme.textTheme.bodyLarge),
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
                              style: theme.textTheme.bodyLarge!.copyWith(
                                fontWeight: FontWeight.bold,
                                foreground: Paint()..shader = linearGradient,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text('wit',
                                style: theme.textTheme.bodyLarge!.copyWith(
                                  foreground: Paint()..shader = linearGradient,
                                )),
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
                  Text('Transactions found: ',
                      style: theme.textTheme.bodyLarge!),
                  AutoSizeText(
                    '$currentTransactionCount',
                    maxLines: 2,
                    minFontSize: 16,
                    style: theme.textTheme.bodyLarge!.copyWith(
                      foreground: Paint()..shader = linearGradient,
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  AutoSizeText(
                    'Explored addresses: ',
                    maxLines: 2,
                    minFontSize: 16,
                  ),
                  AnimatedIntegerText(
                    initialValue: currentAddressCount,
                    // TODO:targetValue: addressCount,
                    targetValue: currentAddressCount,
                    curve: Interval(0, .5, curve: Curves.easeOut),
                    controller: _balanceController,
                    style: theme.textTheme.bodyLarge!.copyWith(
                      foreground: Paint()..shader = linearGradient,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text('Exploring address: ',
                      style: theme.textTheme.bodyLarge!),
                  Expanded(
                    flex: 1,
                    child: Text(state.message,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge!.copyWith(
                          foreground: Paint()..shader = linearGradient,
                        )),
                  ),
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
