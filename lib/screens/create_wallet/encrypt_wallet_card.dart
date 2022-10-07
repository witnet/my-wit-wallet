import 'package:witnet_wallet/widgets/input_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:witnet_wallet/shared/locator.dart';

final _passController = TextEditingController();
final _passFocusNode = FocusNode();
final _passConfirmFocusNode = FocusNode();
final _passConfirmController = TextEditingController();

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

  String _password = '';
  String _confirmPassword = '';
  bool _hasInputError = false;
  String errorText = 'Password mismatch';

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
  }

  void validation() {
    if (!_passConfirmFocusNode.hasFocus && !_passFocusNode.hasFocus) {
      if (this.mounted) {
        if (_password.isEmpty && _confirmPassword.isEmpty) {
          setState(() {
            _hasInputError = true;
            errorText = 'Please input a password';
          });
        } else if (_password == _confirmPassword) {
          setState(() {
            _hasInputError = false;
          });
          widget.nextAction(next);
        } else {
          setState(() {
            _hasInputError = true;
            errorText = 'Password Mismatch';
          });
        }
      }
    } else {
      widget.nextAction(null);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    _passConfirmFocusNode.addListener(() => validation());
    _passFocusNode.addListener(() => validation());
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PLEASE NOTE:',
          style: theme.textTheme.headline3,
        ),
        SizedBox(height: 8),
        Text(
          'This password encrypts your Witnet wallet only on this computer',
          style: theme.textTheme.bodyText1,
        ),
        SizedBox(height: 8),
        Text(
          'This is not your backup and you cannot restore your wallet with this password.',
          style: theme.textTheme.bodyText1,
        ),
        SizedBox(height: 8),
        Text(
          'Your ${Locator.instance.get<ApiCreateWallet>().seedData!.split(' ').length} word seed phrase is still your ultimate recovery method.',
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
                prefixIcon: Icons.lock,
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
                prefixIcon: Icons.lock,
                hint: 'Confirm Password',
                obscureText: true,
                focusNode: _passConfirmFocusNode,
                textEditingController: _passConfirmController,
                errorText: _hasInputError ? errorText : null,
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
