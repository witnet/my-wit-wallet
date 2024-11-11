import 'package:flutter/material.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/screens/login/view/biometrics_autentication.dart';
import 'package:my_wit_wallet/screens/login/view/re_establish_wallet_button.dart';
import 'package:my_wit_wallet/util/allow_biometrics.dart';
import 'package:my_wit_wallet/widgets/buttons/custom_btn.dart';
import 'package:my_wit_wallet/widgets/layouts/dashboard_layout.dart';
import 'package:my_wit_wallet/widgets/layouts/layout.dart';
import 'package:my_wit_wallet/widgets/input_password.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/screens/login/bloc/login_bloc.dart';
import 'package:my_wit_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:my_wit_wallet/widgets/validations/password_input.dart';
import 'package:my_wit_wallet/widgets/validations/validation_utils.dart';
import 'package:my_wit_wallet/widgets/styled_text_controller.dart';

class LoginForm extends StatefulWidget {
  final List<Widget> mainComponents;

  LoginForm({Key? key, required this.mainComponents}) : super(key: key);

  @override
  LoginFormState createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> with TickerProviderStateMixin {
  PasswordInput _password = PasswordInput.pure();
  bool isLoading = false;
  String? _passwordInputErrorText;
  final _loginController = StyledTextController(obscureText: true);
  final _loginFocusNode = FocusNode();
  final _showPasswordFocusNode = FocusNode();
  ValidationUtils validationUtils = ValidationUtils();
  Widget biometricsOrPassword = Container();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _loginController.dispose();
    _loginFocusNode.dispose();
    super.dispose();
  }

  _login() {
    try {
      if (validateForm(force: true)) {
        BlocProvider.of<LoginBloc>(context)
            .add(LoginSubmittedEvent(password: _password.value));
      }
    } catch (err) {
      rethrow;
    }
  }

  Widget _buttonLogin() {
    return CustomButton(
      padding: EdgeInsets.only(top: 8, bottom: 0),
      text: localization.unlockWallet,
      isLoading: isLoading,
      type: CustomBtnType.primary,
      onPressed: _login,
    );
  }

  Widget _loginListener() {
    return BlocListener<LoginBloc, LoginState>(
      listener: (BuildContext context, LoginState state) {
        if (state.status == LoginStatus.LoginInvalid) {
          setState(() {
            _passwordInputErrorText = localization.invalidPassword;
            BlocProvider.of<LoginBloc>(context).add(LoginLogoutEvent());
            isLoading = false;
          });
        }
        if (state.status == LoginStatus.LoginInProgress) {
          setState(() {
            isLoading = true;
          });
        }
        if (state.status == LoginStatus.LoginSuccess) {
          Navigator.pushReplacement(
              context,
              CustomPageRoute(
                  builder: (BuildContext context) {
                    return DashboardScreen();
                  },
                  maintainState: false,
                  settings: RouteSettings(name: DashboardScreen.route)));
        }
        if (state.status == LoginStatus.LoginCancelled) {
          setState(() {
            isLoading = false;
          });
        }
      },
      child: _buttonLogin(),
    );
  }

  bool formValidation() {
    return _password.isValid;
  }

  bool validateForm({force = false}) {
    if (force) {
      setPassword(_password.value, validate: true);
    }
    return formValidation();
  }

  void setPassword(String password, {bool? validate}) {
    setState(() {
      _password = PasswordInput.dirty(
          value: password,
          allowValidation:
              validate ?? validationUtils.isFormUnFocus([_loginFocusNode]));
    });
  }

  Form _loginForm() {
    _loginFocusNode.addListener(() => validateForm());
    return Form(
      autovalidateMode: AutovalidateMode.disabled,
      child: InputPassword(
        hint: localization.passwordLabel,
        errorText: _password.error ?? _passwordInputErrorText,
        showPassFocusNode: _showPasswordFocusNode,
        obscureText: true,
        styledTextController: _loginController,
        focusNode: _loginFocusNode,
        onChanged: (String? value) {
          if (mounted) {
            _passwordInputErrorText = null;
            setPassword(value ?? '');
          }
        },
        onFieldSubmitted: (String? value) {
          // hide keyboard
          FocusManager.instance.primaryFocus?.unfocus();
          _login();
        },
        onTap: () {
          _loginFocusNode.requestFocus();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: showBiometrics(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data == true) {
            biometricsOrPassword = BiometricsAutentication();
          }
          return Layout(
            topNavigation: [],
            widgetList: [
              ...widget.mainComponents,
              SizedBox(height: 32),
              _loginForm(),
              SizedBox(height: 8),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    biometricsOrPassword,
                    SizedBox(height: 8),
                    ReEstablishWalletBtn(),
                  ])
            ],
            actions: [_loginListener()],
          );
        });
  }
}
