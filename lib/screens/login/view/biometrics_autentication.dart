import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:my_wit_wallet/screens/login/bloc/login_bloc.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/globals.dart' as globals;

class BiometricsAutentication extends StatefulWidget {
  const BiometricsAutentication({Key? key}) : super(key: key);

  @override
  State<BiometricsAutentication> createState() =>
      BiometricsAutenticationState();
}

class BiometricsAutenticationState extends State<BiometricsAutentication>
    with WidgetsBindingObserver {
  BiometricsStatus? autenticationStatus;
  Widget child = Container();

  AppLocalizations get _localization => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authenticateWithBiometrics();
  }

  void _authenticateWithBiometrics() async {
    if (!globals.avoidBiometrics) {
      BlocProvider.of<LoginBloc>(context).add(LoginAutenticationEvent())
          as BiometricsStatus?;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
        listener: (BuildContext context, LoginState state) {
          if (state.status != LoginStatus.BiometricsNotSupported) {
            setState(() {
              child = Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PaddedButton(
                    padding: EdgeInsets.all(0),
                    onPressed: _authenticateWithBiometrics,
                    text: autenticationStatus == BiometricsStatus.autenticating
                        ? _localization.cancelAuthentication
                        : _localization.authenticateWithBiometrics,
                    icon: const Icon(Icons.fingerprint),
                    type: ButtonType.horizontalIcon,
                  )
                ],
              );
            });
          }
        },
        child: child);
  }
}
