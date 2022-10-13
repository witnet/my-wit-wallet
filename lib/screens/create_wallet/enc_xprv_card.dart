import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet/utils.dart';
import 'package:witnet/witnet.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:witnet_wallet/widgets/witnet/password_input.dart';
import 'package:witnet_wallet/shared/locator.dart';

class EnterEncryptedXprvCard extends StatefulWidget {
  EnterEncryptedXprvCard({Key? key}) : super(key: key);

  EnterXprvCardState createState() => EnterXprvCardState();
}

class EnterXprvCardState extends State<EnterEncryptedXprvCard>
    with TickerProviderStateMixin {
  String xprv = '';
  String _password = '';
  bool useStrongPassword = false;
  void setPassword(String password) {
    setState(() {
      _password = password;
    });
  }

  FocusNode passwordInputFocusNode = FocusNode();
  late TextEditingController passwordInputTextController;

  final TextEditingController textController = TextEditingController();
  int numLines = 0;
  bool _xprvVerified = false;
  bool xprvVerified() => _xprvVerified;

  @override
  void initState() {
    super.initState();

    passwordInputTextController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    passwordInputTextController.dispose();
  }

  Widget _buildConfirmField() {
    return SizedBox(
      child: Padding(
        padding: EdgeInsets.all(3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              keyboardType: TextInputType.multiline,
              maxLines: 4,
              controller: textController,
              onChanged: (String e) {
                setState(() {
                  xprv = textController.value.text;
                  numLines = '\n'.allMatches(e).length + 1;
                });
              },
              decoration: new InputDecoration(
                  labelText: 'Encrypted XPRV',
                  border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(10.0))),
            ),
            SizedBox(
              height: 10,
            ),

            //Text
          ],
        ),
      ),
    );
  }

  void onBack() {
    WalletType type = BlocProvider.of<CreateWalletBloc>(context).state.walletType;
    BlocProvider.of<CreateWalletBloc>(context).add(PreviousCardEvent(type));
  }

  void onNext() {
    Locator.instance<ApiCreateWallet>().setSeed(xprv, 'encryptedXprv');
    WalletType type = BlocProvider.of<CreateWalletBloc>(context).state.walletType;
    BlocProvider.of<CreateWalletBloc>(context).add(NextCardEvent(type, data: {}));
  }

  bool validBech(String xprvString) {
    try {
      Bech32 bech = bech32.decode(xprvString);
      assert(bech.hrp.isNotEmpty);
      return true;
    } catch (e) {
      return false;
    }
  }

  bool validXprv(String xprvString) {
    try {
      Xprv _xprv = Xprv.fromXprv(xprvString);
      assert(_xprv.address.address.isNotEmpty);
    } catch (e) {
      return false;
    }
    return true;
  }

  Widget _buildPasswordField(double width) {
    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        PasswordInput(
          'Password',
          focusNode: passwordInputFocusNode,
          textEditingController: passwordInputTextController,
          validator: (String? value) {
            if (useStrongPassword) {
              var ensureTwoUpperCase = RegExp(r'^(?=.*[A-Z]){3,}');
              var ensureOneSpecial = RegExp(r'^(?=.*[!@#$&*])');
              var ensureTwoDigits = RegExp(r'^(?=.*[0-9].*[0-9])');
              var ensureThreeLowerCase = RegExp(r'^(?=.*[a-z].*[a-z].*[a-z])');
              if (value != null) {
                if (value.isEmpty) return null;
                if (value.length < 8) return 'Too Short. length 8 required.';
                if (!ensureTwoUpperCase.hasMatch(value))
                  return 'Need two uppercase letters.';
                if (!ensureOneSpecial.hasMatch(value))
                  return 'Need 1 special case !@#\$&*';
                if (!ensureTwoDigits.hasMatch(value))
                  return 'Need 2 digits. 0-9';
                if (!ensureThreeLowerCase.hasMatch(value))
                  return 'Need 3 lowercase letters.';

                return null;
              }
            }
            return null;
          },
          onChanged: (String? value) {
            setState(() {
              _password = value!;
            });
            return value;
          },
          onEditingComplete: () {
            passwordInputFocusNode.unfocus();
          },
          onSubmitted: (String? value) { return value!; },
        ),
      ],
    ));
  }

  String truncateAddress(String addr) {
    var start = addr.substring(0, 11);
    var end = addr.substring(addr.length - 6);
    return '$start...$end';
  }

  Widget _buildButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10, bottom: 10),
          child: ElevatedButton(
            onPressed: onBack,
            child: Text('Go back!'),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 5, top: 10, bottom: 10),
          child: ElevatedButton(
            onPressed: xprvVerified() ? onNext : null,
            child: Text('Confirm'),
          ),
        ),
      ],
    );
  }

  Widget buildErrorList(List<dynamic> errors) {
    List<Widget> _children = [];
    errors.forEach((element) {
      _children.add(Text(
        element.toString(),
        style: TextStyle(color: Colors.red),
      ));
    });
    return Column(children: _children);
  }

  Widget verifyXprvButton() {
    return BlocBuilder<CreateWalletBloc, CreateWalletState>(
        builder: (context, state) {
      if(state.status == CreateWalletStatus.EnterEncryptedXprv){
        return ElevatedButton(
          onPressed: _password.isEmpty
              ? null
              : () {
            WalletType type =
                BlocProvider.of<CreateWalletBloc>(context).state.walletType;
            BlocProvider.of<CreateWalletBloc>(context)
                .add(VerifyEncryptedXprvEvent(type, xprv:xprv, password: _password));

          },
          child: Text('Verify'),
        );
      }
      else if (state.status == CreateWalletStatus.Loading) {
        return Container();
      } else if (state.status == CreateWalletStatus.ValidXprv) {
        try {
          setState(() {
            _xprvVerified = true;
          });
        } catch (e) {}
        return Container(
          padding: EdgeInsets.all(5.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
              ),
            ],
          ),
        );
      } else if (state.status == CreateWalletStatus.LoadingException) {
        return Container(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildErrorList([state.message]),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [],
              )
            ],
          ),
        );
      } else {
        return Container();
      }
    });
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
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5.0),
                      topRight: Radius.circular(5.0))),
              child: Padding(
                padding: EdgeInsets.only(top: 1),
                child: Text(
                  'Import Ecnrypted XPRV',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.backgroundColor, fontSize: 25),
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
                    _buildConfirmField(),
                    _buildPasswordField(textFieldWidth * 0.9),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        verifyXprvButton(),
                      ],
                    ),
                    _buildButtonRow(),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
