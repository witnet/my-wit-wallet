import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:my_wit_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:my_wit_wallet/widgets/layouts/dashboard_layout.dart';

void clearAndRedirectToDashboard(BuildContext context) {
  BlocProvider.of<TransactionBloc>(context).add(ResetTransactionEvent());
  ScaffoldMessenger.of(context).clearSnackBars();
  Navigator.push(
      context,
      CustomPageRoute(
          builder: (BuildContext context) {
            return DashboardScreen();
          },
          maintainState: false,
          settings: RouteSettings(name: DashboardScreen.route)));
}
