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
  String? errorText;
  final _loginController = TextEditingController();
  final _loginFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loginController.removeListener(() => validate());
      _loginController.clear();
      _loginFocusNode.addListener(() => validate());
    });
  }

  void dispose() {
    _loginFocusNode.removeListener(() => validate());
    _loginController.dispose();
    _loginFocusNode.dispose();
    super.dispose();
  }

  bool validate({bool force = false}) {
    if (this.mounted) {
      if (force || !_loginFocusNode.hasFocus) {
        if (_password.isEmpty) {
          if (this.mounted) {
            setState(() {
              errorText = 'Please input a password';
            });
            return false;
          }
        } else {
          setState(() {
            errorText = null;
            widget.setWallet(Wallet(
                walletName: WalletName.dirty(widget.currentWallet),
                password: _password));
          });
          return true;
        }
      }
      return false;
    }
    return false;
  }

  Widget _buildWalletField() {
    return Form(
      autovalidateMode: AutovalidateMode.always,
      child: InputLogin(
        prefixIcon: Icons.lock,
        hint: 'Password',
        errorText: errorText,
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
              errorText = 'Invalid password';
            });
          }
        } else if (state.status == LoginStatus.LoginSuccess) {
          listenStatus = false;
          Navigator.pushReplacement(context,
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
