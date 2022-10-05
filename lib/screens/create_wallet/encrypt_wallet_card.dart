import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:witnet_wallet/theme/wallet_theme.dart';
import 'package:witnet_wallet/widgets/auto_size_text.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/widgets/witnet/password_input.dart';

typedef void FunctionCallback(Function? value);

class EncryptWalletCard extends StatefulWidget {
  final Function nextAction;
  final Function prevAction;
  EncryptWalletCard({
    Key? key,
    required FunctionCallback this.nextAction,
    required FunctionCallback this.prevAction,
  }) : super(key: key);
  EncryptWalletCardState createState() => EncryptWalletCardState();
}

class EncryptWalletCardState extends State<EncryptWalletCard>
    with TickerProviderStateMixin {
  void prev() {
    WalletType type =
        BlocProvider.of<CreateWalletBloc>(context).state.walletType;
    BlocProvider.of<CreateWalletBloc>(context).add(PreviousCardEvent(type));
  }

  void next() {
    Locator.instance<ApiCreateWallet>().setPassword(_password);
    WalletType type =
        BlocProvider.of<CreateWalletBloc>(context).state.walletType;
    BlocProvider.of<CreateWalletBloc>(context)
        .add(NextCardEvent(type, data: {}));
  }

  late TextEditingController passwordInputTextController;
  late TextEditingController passwordInputConfirmTextController;

  FocusNode passwordInputFocusNode = FocusNode();
  FocusNode passwordInputConfirmFocusNode = FocusNode();

  String _password = '';
  bool _passwordsMatch = false;
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
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.prevAction(prev));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.nextAction(next));
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
        Row(
          children: [
            Expanded(
              flex: 2,
              child: AutoSizeText(
                'Encrypt your wallet.',
                textAlign: TextAlign.right,
                maxLines: 1,
                style: theme.textTheme.bodyText1,
              ),
            ),
            Expanded(
              flex: 1,
              child: Tooltip(
                  height: 75,
                  textStyle: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                  margin: EdgeInsets.only(left: 20, right: 20),
                  preferBelow: false,
                  message:
                      'PLEASE NOTE:\nThis password encrypts your Witnet wallet only on this computer.\nThis is not your backup and you cannot restore your wallet with this password.\nYour ${Locator.instance.get<ApiCreateWallet>().seedData!.split(' ').length} word seed phrase is still your ultimate recovery method.',
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      FontAwesomeIcons.questionCircle,
                      size: 15,
                    ),
                    iconSize: 10,
                    padding: EdgeInsets.all(3),
                  )),
            )
          ],
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: ElevatedButton(
            onPressed: prev,
            child: Text('Cancel'),
          ), // ElevatedButton
        ),
        Padding(
          padding: EdgeInsets.only(left: 5, top: 10),
          child: ElevatedButton(
            onPressed: _passwordsMatch ? next : null,
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
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
        //crossAxisAlignment: CrossAxisAlignment.center,
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
              Expanded(
                  flex: 1,
                  child: Checkbox(
                      value: useStrongPassword,
                      onChanged: (bool? value) {
                        setState(() {
                          this.useStrongPassword = value!;
                        });
                      })),
              Expanded(
                flex: 3,
                child: AutoSizeText(
                  'Use a strong password',
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Tooltip(
                    height: 75,
                    textStyle: TextStyle(fontSize: 12, color: Colors.white),
                    margin: EdgeInsets.only(left: 20, right: 20),
                    padding: EdgeInsets.all(10),
                    preferBelow: false,
                    message:
                        'Enabling this will ensure:\n - minimum length 8\n - 2 uppercase letters\n - 1 special case !@#\$&*\n - 2 digits\n - 3 lowercase letters.',
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        FontAwesomeIcons.questionCircle,
                        size: 15,
                      ),
                      iconSize: 10,
                      padding: EdgeInsets.all(3),
                    )),
              ),
            ],
          ),
        ]);
  }
}
