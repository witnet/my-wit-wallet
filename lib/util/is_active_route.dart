import 'package:flutter/widgets.dart';
import 'package:my_wit_wallet/util/current_route.dart';

bool isActiveRoute(BuildContext context, List<String> routesList) {
  return routesList.contains(currentRoute(context));
}
