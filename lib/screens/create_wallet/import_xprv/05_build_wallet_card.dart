
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:witnet_wallet/bloc/auth/auth_bloc.dart';
import 'package:witnet_wallet/bloc/auth/create_wallet/api_create_wallet.dart';
import 'package:witnet_wallet/bloc/crypto/crypto_bloc.dart';
import 'package:witnet_wallet/screens/dashboard/dashboard_screen.dart';
import 'package:witnet_wallet/shared/locator.dart';

import 'import_xprv_bloc.dart';
class BuildWalletCard extends StatefulWidget {
  BuildWalletCard({Key? key}) : super(key: key);
  BuildWalletCardState createState() => BuildWalletCardState();
}

class BuildWalletCardState extends State<BuildWalletCard>  with TickerProviderStateMixin {
  void onBack() => BlocProvider.of<BlocImportXprv>(context).add(PreviousCardEvent());


  void onNext() {

    BlocProvider.of<BlocImportXprv>(context).add(NextCardEvent());
  }

  late TextEditingController _nameController;
  late TextEditingController _descController;

  String _password = '';
  bool _passwordsMatch = false;
  String _walletDescription = '';
  void setPassword(String password){
    setState(() {
      _password = password;
    });
  }
  @override
  void initState(){
    super.initState();
    _nameController = TextEditingController();
    _descController = TextEditingController();
    ApiCreateWallet acw = Locator.instance<ApiCreateWallet>();
    acw.printDebug();

    BlocProvider.of<BlocCrypto>(context).add(
        CryptoInitializeWalletEvent(
            walletDescription: acw.walletDescription!,
            walletName: acw.walletName,
            keyData: acw.seedData,
            seedSource: acw.seedSource,
            password: acw.password!));
  }
  @override
  void dispose(){
    super.dispose();
    _nameController.dispose();
    _descController.dispose();
  }


  Widget buildWallet(){
    return BlocBuilder<BlocCrypto, CryptoState>(buildWhen: (previousState, state) {
      if (state is CryptoLoadedWalletState) {

        BlocProvider.of<BlocAuth>(context).add(LoginEvent(password: state.password));
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => DashboardScreen()));
      }
      return true;
    },
      builder: (context, state) {
        final theme = Theme.of(context);
        if (state is CryptoInitializingWalletState) {
          return SpinKitCircle(color: theme.primaryColor,);
        }else if (state is CryptoLoadedWalletState){
          return Text(state.wallet.masterXprv.address.address);
        } else {
          return Column(children: [
            Text('${state.runtimeType}'),
            Text('other'),
          ],);
        }
      },
    );
  }

  Widget _buildButtonRow(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10),
          child:
          ElevatedButton(
            onPressed: onBack,
            child: Text('Go back!'),
          ), // ElevatedButton
        ),
        Padding(
          padding: EdgeInsets.only(left: 5, top: 10),
          child:
          ElevatedButton(
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
              decoration: BoxDecoration(color: theme.primaryColor,

                  borderRadius: BorderRadius.only(topLeft: Radius.circular(5.0), topRight: Radius.circular(5.0))),
              child: Padding(
                padding: EdgeInsets.only(top: 1),
                child: Text('Building Wallet',
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
                  ]
              ),
            ),
          ],
        ),
      ),
    );
  }
}