import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/screens/login/bloc/login_bloc.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';

class BiometricsAutentication extends StatefulWidget {
  const BiometricsAutentication({Key? key}) : super(key: key);

  @override
  State<BiometricsAutentication> createState() =>
      BiometricsAutenticationState();
}

class BiometricsAutenticationState extends State<BiometricsAutentication> {
  BiometricsStatus? autenticationStatus;

  @override
  void initState() {
    super.initState();
    _authenticateWithBiometrics();
  }

  void _authenticateWithBiometrics() {
    setState(() {
      autenticationStatus = BlocProvider.of<LoginBloc>(context)
          .add(LoginAutenticationEvent()) as BiometricsStatus?;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Current State: $autenticationStatus');
    return autenticationStatus != BiometricsStatus.notSupported
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PaddedButton(
                padding: EdgeInsets.all(0),
                onPressed: _authenticateWithBiometrics,
                text: autenticationStatus == BiometricsStatus.autenticating
                    ? 'Cancel autentication'
                    : 'Authenticate with your fingerprint',
                icon: const Icon(Icons.fingerprint),
                type: ButtonType.horizontalIcon,
              )
            ],
          )
        : Container();
  }
}
