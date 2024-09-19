import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/util/is_desktop_size.dart';

double getDashboardHeaderHeight() {
  return isDesktopSize
      ? LARGE_DASHBOARD_HEADER_HEIGHT
      : SMALL_DASHBOARD_HEADER_HEIGHT;
}
