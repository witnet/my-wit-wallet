import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/bloc/crypto/crypto_bloc.dart';
import 'package:my_wit_wallet/bloc/explorer/explorer_bloc.dart';
import 'package:my_wit_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:my_wit_wallet/screens/login/bloc/login_bloc.dart';

void logout(BuildContext context) {
  BlocProvider.of<ExplorerBloc>(context)
      .add(CancelSyncWalletEvent(ExplorerStatus.unknown));
  BlocProvider.of<DashboardBloc>(context).add(DashboardResetEvent());
  BlocProvider.of<CryptoBloc>(context).add(CryptoReadyEvent());
  Navigator.of(context).popUntil((route) => route.isFirst);
  BlocProvider.of<LoginBloc>(context).add(LoginLogoutEvent());
}
