import 'package:flutter/widgets.dart';
import 'package:my_wit_wallet/screens/dashboard/view/dashboard_screen.dart';

String? currentRoute(BuildContext context) {
  return ModalRoute.of(context)?.settings.name ?? DashboardScreen.route;
}
