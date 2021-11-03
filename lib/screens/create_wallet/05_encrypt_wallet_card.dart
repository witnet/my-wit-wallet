import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/bloc/auth/create_wallet/api_create_wallet.dart';
import 'package:witnet_wallet/bloc/auth/create_wallet/create_wallet_bloc.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/widgets/witnet/password_input.dart';

class EncryptWalletCard extends StatefulWidget {
  EncryptWalletCard({Key? key}) : super(key: key);
  EncryptWalletCardState createState() => EncryptWalletCardState();
}

class EncryptWalletCardState extends State<EncryptWalletCard>
    with TickerProviderStateMixin {
  void onBack() =>
      BlocProvider.of<BlocCreateWallet>(context).add(PreviousCardEvent());

  void onNext() {
    Locator.instance<ApiCreateWallet>().setPassword(_password);
    BlocProvider.of<BlocCreateWallet>(context).add(NextCardEvent());
  }

  late TextEditingController passwordInputTextController;
  late TextEditingController passwordInputConfirmTextController;

  FocusNode passwordInputFocusNode = FocusNode();
  FocusNode passwordInputConfirmFocusNode = FocusNode();

  String _password = '';
  bool _passwordsMatch = false;
  String _walletDescription = '';
  bool useStrongPassword = false;
  void setPassword(String password) {
    setState(() {
      _password = password;
    });
  }

  @override
  void initState() {
    super.initState();
    passwordInputTextController = TextEditingController();
    passwordInputConfirmTextController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    passwordInputTextController.dispose();
    passwordInputConfirmTextController.dispose();
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
          },
          onChanged: (String? value) {
            setState(() {
              _password = value!;
            });
          },
          onEditingComplete: () {
            passwordInputFocusNode.unfocus();
          },
          onSubmitted: (String? value) {},
        ),
      ],
    ));
  }

  Widget _buildConfirmPasswordField(double width) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          PasswordInput(
            'Confirm Password',
            focusNode: passwordInputConfirmFocusNode,
            textEditingController: passwordInputConfirmTextController,
            validator: (String? value) {
              if (_password.isNotEmpty) {
                if (value != null) {
                  return (_password == value) ? null : 'Password Mismatch';
                }
              }
            },
            onChanged: (String? value) {
              setState(() {
                _passwordsMatch = (_password == value) ? true : false;
              });
            },
            onEditingComplete: () {},
            onSubmitted: (String? value) {},
          ),
        ],
      ),
    );
  }

  Widget _buildInfoText(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Encrypt your wallet with a password',
          style: theme.textTheme.headline6,
        ), //Text
        SizedBox(
          height: 10,
        ),

        Text(
          'PLEASE NOTE: this password encrypts your Witnet wallet only on this computer. This is not your backup and you cannot restore your wallet with this password. Your ${Locator.instance.get<ApiCreateWallet>().seedData.split(' ').length} word seed phrase is still your ultimate recovery method.',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),

        SizedBox(height: 10),
      ],
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
                  'Encrypt Wallet',
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
                    _buildInfoText(theme),
                    _buildPasswordField(textFieldWidth),
                    SizedBox(
                      height: 10,
                    ),
                    _buildConfirmPasswordField(textFieldWidth),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      // mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                            value: useStrongPassword,
                            onChanged: (bool? value) {
                              setState(() {
                                this.useStrongPassword = value!;
                              });
                            }),
                        Column(mainAxisSize: MainAxisSize.min, children: [
                          Text(
                            'Use strong password',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ]),
                      ],
                    ),
                    Text(
                      'Enabling this will ensure: minimum length 8, 2 uppercase letters, 1 special case !@#\$&*, 2 digits, and 3 lowercase letters. ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
