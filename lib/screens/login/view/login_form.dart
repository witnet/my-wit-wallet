import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/models/wallet_name.dart';
import 'package:witnet_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:witnet_wallet/screens/login/bloc/login_bloc.dart';
import 'package:witnet_wallet/widgets/input_login.dart';

typedef void VoidCallback(Wallet? value);

class Wallet {
  WalletName walletName = WalletName.pure();
  String password;
  Wallet({
    required this.walletName,
    required this.password,
  });
}

class LoginForm extends StatefulWidget {
  final VoidCallback setWallet;
  final String currentWallet;
  final String? loginError;
  LoginForm({
    Key? key,
    required this.currentWallet,
    required this.setWallet,
    this.loginError,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> with TickerProviderStateMixin {
  String _password = '';
  bool _hasInputError = false;
  String? errorText = '';
  final _loginController = TextEditingController();
  final _loginFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loginController.removeListener(() => validation());
      _loginController.clear();
      _loginFocusNode.addListener(() => validation());
    });
  }

  void dispose() {
    _loginFocusNode.removeListener(() => validation());
    _loginController.dispose();
    _loginFocusNode.dispose();
    super.dispose();
  }

  void validation() {
    if (!_loginFocusNode.hasFocus) {
      if (_password.isEmpty) {
        if (this.mounted) {
          setState(() {
            _hasInputError = true;
            errorText = 'Please input a password';
          });
        }
      } else {
        if (this.mounted) {
          setState(() {
            _hasInputError = false;
            errorText = '';
            widget.setWallet(Wallet(
                walletName: WalletName.dirty(widget.currentWallet),
                password: _password));
          });
        }
      }
    }
  }

  final _formKey = GlobalKey<FormState>();

  Widget _buildWalletField() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.always,
      child: InputLogin(
        prefixIcon: Icons.lock,
        hint: 'Password',
        errorText: _hasInputError ? errorText : null,
        obscureText: true,
        textEditingController: _loginController,
        focusNode: _loginFocusNode,
        onChanged: (String? value) {
          if (mounted) {
            setState(() {
              _password = value!;
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var listenStatus = true;
    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (previous, current) {
        return listenStatus;
      },
      listener: (BuildContext context, LoginState state) {
        if (state.status == LoginStatus.LoginInvalid) {
          if (mounted) {
            setState(() {
              _hasInputError = true;
              errorText = 'Invalid password';
            });
          }
        } else if (state.status == LoginStatus.LoginSuccess) {
          listenStatus = false;
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => DashboardScreen()));
        }
      },
      child: Container(
        child: Column(
          children: [_buildWalletField()],
        ),
      ),
    );
  }
}
