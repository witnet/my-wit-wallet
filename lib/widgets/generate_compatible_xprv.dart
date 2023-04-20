import 'dart:async';
import 'dart:developer';

import 'package:witnet/witnet.dart';
import 'package:witnet_wallet/shared/api_database.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/util/storage/database/encrypt/password.dart';
import 'package:witnet_wallet/widgets/PaddedButton.dart';
import 'package:witnet_wallet/widgets/input_login.dart';
import 'package:flutter/material.dart';

final _passController = TextEditingController();
final _passFocusNode = FocusNode();
final _passConfirmFocusNode = FocusNode();
final _passConfirmController = TextEditingController();

typedef void StringCallback(String? value);

class GenerateCompatibleXprv extends StatefulWidget {
  final StringCallback onXprvGenerated;
  final Xprv? xprv;
  GenerateCompatibleXprv({
    Key? key,
    required this.onXprvGenerated,
    this.xprv,
  }) : super(key: key);
  GenerateCompatibleXprvState createState() => GenerateCompatibleXprvState();
}

class GenerateCompatibleXprvState extends State<GenerateCompatibleXprv>
    with TickerProviderStateMixin {
  String _password = '';
  String _confirmPassword = '';
  bool isLoading = false;
  String? errorText;
  String? localEncryptedXprv =
      Locator.instance.get<ApiDatabase>().walletStorage.currentWallet.xprv;
  String? compatibleXprv;

  void setPassword(String password) {
    setState(() {
      _password = password;
    });
  }

  @override
  void initState() {
    super.initState();
    _passController.clear();
    _passConfirmController.clear();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _generateSheikahCompatibleXprv(password) {
    try {
      // Checks if password is the one that encrypts the current (not-Sheikah-compatible) xprv
      Xprv.fromEncryptedXprv(localEncryptedXprv ?? '', Password.hash(password));
    } catch (e) {
      errorText = 'Wrong password';
    }
    if (widget.xprv != null) {
      setState(() {
        compatibleXprv = widget.xprv!.toEncryptedXprv(password: password);
        isLoading = false;
      });
      widget.onXprvGenerated(compatibleXprv);
    }
  }

  // ignore: todo
  // TODO[#24]: Use formz model to validate password

  bool validate({bool force = false}) {
    if (this.mounted) {
      setState(() {
        errorText = null;
      });
      if (force ||
          (!_passConfirmFocusNode.hasFocus && !_passFocusNode.hasFocus)) {
        if (_password.isEmpty && _confirmPassword.isEmpty) {
          setState(() {
            errorText = 'Please input your xprv password';
          });
          return false;
        } else if (_password == _confirmPassword) {
          setState(() {
            errorText = null;
          });
          return true;
        } else {
          setState(() {
            errorText = 'Password Mismatch';
          });
          return false;
        }
      } else {
        setState(() {
          errorText = null;
        });
        return false;
      }
    }
    return false;
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    _passConfirmFocusNode.addListener(() => validate());
    _passFocusNode.addListener(() => validate());

    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'This password encrypts your xprv file. You will be asked to type this password if you want to import this xprv as a backup.',
          style: theme.textTheme.bodyText1,
        ),
        SizedBox(height: 16),
        Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Password',
                style: theme.textTheme.subtitle2,
              ),
              SizedBox(height: 8),
              InputLogin(
                hint: 'Password',
                focusNode: _passFocusNode,
                textEditingController: _passController,
                obscureText: true,
                onChanged: (String? value) {
                  if (this.mounted) {
                    setState(() {
                      _password = value!;
                    });
                  }
                },
              ),
              SizedBox(height: 16),
              Text(
                'Confirm password',
                style: theme.textTheme.subtitle2,
              ),
              SizedBox(height: 8),
              InputLogin(
                hint: 'Confirm Password',
                obscureText: true,
                focusNode: _passConfirmFocusNode,
                textEditingController: _passConfirmController,
                errorText: errorText,
                onChanged: (String? value) {
                  if (this.mounted) {
                    setState(() {
                      _confirmPassword = value!;
                    });
                  }
                },
              ),
              SizedBox(height: 16),
              PaddedButton(
                  padding: EdgeInsets.only(bottom: 8),
                  text: 'Generate xprv',
                  type: 'primary',
                  isLoading: isLoading,
                  enabled: true,
                  onPressed: () async {
                    setState(() => isLoading = true);
                    await Future.delayed(
                      Duration(milliseconds: 300),
                      () => {
                        if (validate(force: true)) {
                          _generateSheikahCompatibleXprv(_password),
                        }
                      }
                    );
                    setState(() => isLoading = false);
                  }),
            ],
          ),
        ),
      ],
    );
  }
}
