import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:witnet_wallet/bloc/auth/auth_bloc.dart';
import 'package:witnet_wallet/bloc/auth/create_wallet/api_create_wallet.dart';
import 'package:witnet_wallet/screens/dashboard/dashboard_screen.dart';
import 'package:witnet_wallet/widgets/auto_size_text.dart';
import 'import_mnemonic_bloc.dart';
import 'package:witnet_wallet/bloc/crypto/crypto_bloc.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/util/witnet/wallet/wallet.dart';

class BuildWalletCard extends StatefulWidget {
  BuildWalletCard({Key? key}) : super(key: key);
  BuildWalletCardState createState() => BuildWalletCardState();
}

class BuildWalletCardState extends State<BuildWalletCard>
    with TickerProviderStateMixin {
  void onBack() =>
      BlocProvider.of<BlocImportMnemonic>(context).add(PreviousCardEvent());

  void onNext() {
    BlocProvider.of<BlocImportMnemonic>(context).add(NextCardEvent());
  }

  late TextEditingController _nameController;
  late TextEditingController _descController;

  String _password = '';
  bool _passwordsMatch = false;
  String _walletDescription = '';
  void setPassword(String password) {
    setState(() {
      _password = password;
    });
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descController = TextEditingController();
    ApiCreateWallet acw = Locator.instance<ApiCreateWallet>();
    // acw.printDebug();

    BlocProvider.of<BlocCrypto>(context).add(CryptoInitializeWalletEvent(
        walletDescription: acw.walletDescription!,
        walletName: acw.walletName,
        keyData: acw.seedData,
        seedSource: acw.seedSource,
        password: acw.password!));
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _descController.dispose();
  }

  Future<Map<String, dynamic>> _computeWalletData() async {
    final String walletName =
        Locator.instance.get<ApiCreateWallet>().walletName;
    final String? walletDescription =
        Locator.instance.get<ApiCreateWallet>().walletDescription;

    String mnemonic = Locator.instance.get<ApiCreateWallet>().seedData;
    Wallet wallet = await Wallet.fromMnemonic(
        name: walletName, description: walletDescription!, mnemonic: mnemonic);

    return {};
  }

  Widget buildWallet() {
    return BlocBuilder<BlocCrypto, CryptoState>(
      buildWhen: (previousState, state) {
        if (state is CryptoLoadedWalletState) {
          BlocProvider.of<BlocAuth>(context)
              .add(LoginEvent(password: state.password));
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => DashboardScreen()));
        }
        return true;
      },
      builder: (context, state) {
        final theme = Theme.of(context);
        print(state.runtimeType);
        if (state is CryptoInitializingWalletState) {
          return Column(children: [
            AutoSizeText(
              '${state.message}',
              maxLines: 1,
              minFontSize: 9,
            ),
            SpinKitCircle(
              color: theme.primaryColor,
            ),
          ]);
        } else {
          return Column(
            children: [
              Text('${state.runtimeType}'),
              Text('other'),
            ],
          );
        }
      },
    );
  }

  Widget _buildButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: ElevatedButton(
            onPressed: onBack,
            child: Text('Go back!'),
          ), // ElevatedButton
        ),
        Padding(
          padding: EdgeInsets.only(left: 5, top: 10),
          child: ElevatedButton(
            onPressed: _passwordsMatch ? onNext : null,
            child: Text('Confirm'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    final cardWidth = min(deviceSize.width * 0.95, 360.0);
    const cardPadding = 10.0;
    final textFieldWidth = cardWidth - cardPadding * 2;
    final theme = Theme.of(context);
    return FittedBox(
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 50,
              width: cardWidth,
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5.0),
                      topRight: Radius.circular(5.0))),
              child: Padding(
                padding: EdgeInsets.only(top: 1),
                child: Text(
                  'Building Wallet',
                  style: theme.textTheme.headline4,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                left: cardPadding,
                right: cardPadding,
                top: cardPadding + 10,
              ),
              width: cardWidth,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    buildWallet(),
                    _buildButtonRow(),
                    SizedBox(height: 10),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
