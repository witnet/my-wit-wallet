import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/screens/login/bloc/login_bloc.dart';
import 'package:my_wit_wallet/globals.dart' as globals;
import 'package:my_wit_wallet/widgets/buttons/icon_btn.dart';

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
                  IconBtn(
                    label: autenticationStatus == BiometricsStatus.autenticating
                        ? localization.cancelAuthentication
                        : localization.authenticateWithBiometrics,
                    padding: EdgeInsets.all(0),
                    onPressed: _authenticateWithBiometrics,
                    text: autenticationStatus == BiometricsStatus.autenticating
                        ? localization.cancelAuthentication
                        : localization.authenticateWithBiometrics,
                    icon: const Icon(Icons.fingerprint),
                    iconBtnType: IconBtnType.horizontalText,
                  )
                ],
              );
            });
          }
        },
        child: child);
  }
}
