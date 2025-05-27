import 'dart:ui';
import 'package:my_wit_wallet/l10n/app_localizations.dart';
import 'package:my_wit_wallet/globals.dart';

AppLocalizations get localization {
  if (navigatorKey.currentContext != null) {
    return AppLocalizations.of(navigatorKey.currentContext!)!;
  } else {
    // Use default localization when no context if found. For instance, when we are running unit
    // tests and no Widget is being rendered
    return lookupAppLocalizations(Locale('en'));
  }
}
