import 'package:my_wit_wallet/widgets/input_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/screens/create_wallet/nav_action.dart';
import 'package:my_wit_wallet/shared/api_database.dart';

final _passController = TextEditingController();
final _passFocusNode = FocusNode();
final _passConfirmFocusNode = FocusNode();
final _showPassFocusNode = FocusNode();
final _showPassConfirmedFocusNode = FocusNode();
final _passConfirmController = TextEditingController();

typedef void VoidCallback(NavAction? value);
typedef void BoolCallback(bool value);

class EncryptWalletCard extends StatefulWidget {
  final Function nextAction;
  final Function prevAction;
  final Function clearActions;
  EncryptWalletCard({
    Key? key,
    required VoidCallback this.nextAction,
    required VoidCallback this.prevAction,
    required BoolCallback this.clearActions,
  }) : super(key: key);
  EncryptWalletCardState createState() => EncryptWalletCardState();
}

class EncryptWalletCardState extends State<EncryptWalletCard>
    with TickerProviderStateMixin {
  void prevAction() {
    CreateWalletType type =
        BlocProvider.of<CreateWalletBloc>(context).state.walletType;
    BlocProvider.of<CreateWalletBloc>(context).add(PreviousCardEvent(type));
  }

  void nextAction() async {
    if (validate(force: true)) {
      // set masterKey
      Locator.instance<ApiCreateWallet>().setPassword(_password);
      await Locator.instance<ApiDatabase>().setPassword(newPassword: _password);
      CreateWalletType type =
          BlocProvider.of<CreateWalletBloc>(context).state.walletType;
      BlocProvider.of<CreateWalletBloc>(context)
          .add(NextCardEvent(type, data: {}));
    }
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

  String _password = '';
  String _confirmPassword = '';
  String? errorText;

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
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.prevAction(prev));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.nextAction(next));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.clearActions(false));
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ignore: todo
  // TODO[#24]: Use formz model to validate password

  bool validate({force = false}) {
    if (this.mounted) {
      if (force ||
          (!_passConfirmFocusNode.hasFocus &&
              !_passFocusNode.hasFocus &&
              !_showPassFocusNode.hasFocus &&
              !_showPassConfirmedFocusNode.hasFocus)) {
        setState(() {
          errorText = null;
        });
        if (_password.isEmpty && _confirmPassword.isEmpty) {
          setState(() {
            errorText = 'Please input a password';
          });
        } else if (_password != _confirmPassword) {
          setState(() {
            errorText = 'Password Mismatch';
          });
        }
      }
    }
    return errorText != null ? false : true;
  }

  @override
  Widget build(BuildContext context) {
    _passConfirmFocusNode.addListener(() => validate());
    _passFocusNode.addListener(() => validate());
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Encrypt your wallet',
          style: theme.textTheme.titleLarge,
        ),
        SizedBox(height: 8),
        Text(
          'This password encrypts your Witnet wallet only on this computer.',
          style: theme.textTheme.bodyLarge,
        ),
        SizedBox(height: 8),
        Text(
          'This is not your backup and you cannot restore your wallet with this password.',
          style: theme.textTheme.bodyLarge,
        ),
        SizedBox(height: 8),
        Text(
          'Your ${Locator.instance.get<ApiCreateWallet>().seedData!.split(' ').length} word seed phrase is still your ultimate recovery method.',
          style: theme.textTheme.bodyLarge,
        ),
        SizedBox(height: 16),
        Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Password',
                style: theme.textTheme.titleSmall,
              ),
              SizedBox(height: 8),
              InputLogin(
                hint: 'Password',
                autoFocus: true,
                focusNode: _passFocusNode,
                showPassFocusNode: _showPassFocusNode,
                textEditingController: _passController,
                obscureText: true,
                onFieldSubmitted: (String? value) {
                  _passConfirmFocusNode.requestFocus();
                },
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
                style: theme.textTheme.titleSmall,
              ),
              SizedBox(height: 8),
              InputLogin(
                hint: 'Confirm Password',
                obscureText: true,
                focusNode: _passConfirmFocusNode,
                showPassFocusNode: _showPassConfirmedFocusNode,
                textEditingController: _passConfirmController,
                errorText: errorText,
                onFieldSubmitted: (String? value) {
                  // hide keyboard
                  FocusManager.instance.primaryFocus?.unfocus();
                  nextAction();
                },
                onChanged: (String? value) {
                  if (this.mounted) {
                    setState(() {
                      _confirmPassword = value!;
                    });
                  }
                },
              )
            ],
          ),
        ),
      ],
    );
  }
}
