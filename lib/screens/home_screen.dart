
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/bloc/auth/auth_bloc.dart';
import 'package:witnet_wallet/screens/screen_transitions/fade_transition.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'login/login_screen.dart';
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _logout(),
    );
  }

  _logout() {
    return BlocBuilder<BlocAuth, AuthState>(buildWhen: (previousState, state) {
      if (state is LoggedOutState) {
        Navigator.pushReplacement(context, FadeRoute(page: LoginScreen()));
      } return true;
    }, builder: (context, state) {
      if (state is LoadingLogoutState) {
        final theme = Theme.of(context);

        return SizedBox(
          child: SpinKitWave(
            color: theme.primaryColor,
          ),
        );
      }
      return Center(
        child: InkWell(
          onTap: () => BlocProvider.of<BlocAuth>(context).add(LogoutEvent()),
          child: Text(
            "Logout",
            style: TextStyle(
                fontSize: 26,
                decoration: TextDecoration.underline,
                color: Colors.white),
          ),
        ),
      );
    });
  }
}