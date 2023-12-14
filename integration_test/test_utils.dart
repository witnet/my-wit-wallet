import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/globals.dart';
import 'package:my_wit_wallet/screens/create_wallet/generate_mnemonic_card.dart';
import 'package:my_wit_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/theme/colors.dart';
import 'package:my_wit_wallet/util/extensions/string_extensions.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/labeled_checkbox.dart';
import 'package:my_wit_wallet/widgets/select.dart';
import 'package:my_wit_wallet/main.dart' as myWitWallet;
import 'package:my_wit_wallet/globals.dart' as globals;
part 'e2e_auth_preferences_test.dart';
part 'e2e_export_node_xprv_test.dart';
part 'e2e_export_hd_xprv_test.dart';
part 'e2e_import_mnemonic_test.dart';
part 'e2e_show_node_stats.dart';
part "e2e_mnemonic_test.dart";
part 'e2e_re_establish_wallet.dart';
part "e2e_import_xprv_test.dart";
part 'e2e_import_xprv_from_sheikah_test.dart';
part 'e2e_update_wallet_test.dart';
part 'e2e_sign_message_test.dart';
part 'e2e_update_theme_test.dart';

bool walletsExist = false;
int defaultDelay = int.parse(dotenv.env['DELAY'] ?? '100');
int initializeDelay = int.parse(dotenv.env['INIT_E2E_DELAY_IN_SECONDS'] ?? '5');
String password = dotenv.env['PASSWORD'] ?? "password";
String mnemonic = dotenv.env['MNEMONIC'] ??
    "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about";

/// The Node Xprv is derived from the mnemonic:
/// "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon agent"
String nodeXprv = dotenv.env['NODE_XPRV'] ??
    'xprv1qrgqgjwqnprj4g74wjpgad6k7xa37qmxjk3nf5wakgka9d0hgmzvkqr88hgnklzs0x86x487nyr34uq7ujracm36wcgplftzsuaswe533ufnfx6r';
String sheikahXprv = dotenv.env['SHEIKAH_XPRV'] ??
    "xprv1yd5j548gfk6fc5an0n4r4mvp8kxq6pxcwynajfhc2evp6enm98fvxtawxr7z5z5yt0m83tlry8dzk8ygea2nk2nfqdlg76mn5e9k0x32ty0tewqe888cj6fap7e84s9zkgd5rkvjpdff4ylyx55xup6x3aqlwnq4wgl3mc0m5d8gphkpad7cr7ydt43c052pu4sec0kf4mtjye5l5lqu9m4vmdprh63w8l8vpxu6hrjrsh8lgsxs8t75pw4ppvr6tz86fydhxs0atgacfx29z35uavxy468h";
String mwwXprv = dotenv.env['MWW_XPRV'] ??
    "xprv1m9datmt8l4qyqa2nf7lxrw76vu3kyy63qndhtpjyezm7rjrlqrqjh23yks7zjwycud9k25g20rjqkl7uyfcvq6e246du73cl8hhcfa2xwm6cun5ma69jrtyyzjzm0nqwurwa8vg5pxhd9wxu2lgrpmwknsl3yk3t4qn5au4mnf33qpnk3gg7e093nkk0kqzhfkecg45jm0qsczellg6hll4nzuldckjvj6xku75gmhjc340jau26t634c98ke3a454mqjsxtvfs53f2464jfyhd605hqs0lu";

Finder widgetByType(Type type) => find.byType(type);

Finder widgetByText(String text) => find.text(text);

Finder widgetByIcon(IconData icon) => find.byIcon(icon);

Finder widgetByLabel(String label) => find.bySemanticsLabel(label);

Future<void> initializeTest(WidgetTester tester) async {
  myWitWallet.main();
  await tester.pumpAndSettle();
  String deleteStorageFlag = dotenv.env['DELETE_TEST_STORAGE'] ?? 'false';
  globals.testingDeleteStorage = deleteStorageFlag.toBoolean();
  await tester.pumpAndSettle(Duration(seconds: initializeDelay));
}

Future<bool> tapButton(
  WidgetTester tester,
  dynamic value, {
  int? index,
  bool delay = true,
  int? milliseconds,
}) async {
  Finder finder;
  switch (value.runtimeType) {
    case Type:
      finder = widgetByType(value);
      break;
    case String:
      finder = widgetByText(value);
      break;
    case IconDataSolid:
      finder = widgetByIcon(value);
      break;
    case PaddedButton:
      finder = widgetByType(value);
      break;
    case Select:
      finder = widgetByType(value);
      break;
    case SelectItem:
      finder = widgetByType(value);
      break;
    case Switch:
      finder = widgetByType(value);
      break;
    default:
      {
        if (value.runtimeType.toString().startsWith("IconData")) {
          finder = widgetByIcon(value);
        } else {
          finder = widgetByType(value);
        }
        break;
      }
  }
  await tester.tap(index != null ? finder.at(index) : finder);
  await tester.pumpAndSettle();
  if (delay) {
    await Future.delayed(Duration(milliseconds: milliseconds ?? defaultDelay));
  }
  return true;
}

Future<bool> tapButtonByName(
  WidgetTester tester,
  String text, {
  int index = 0,
  bool delay = true,
  int? milliseconds,
}) async =>
    await tapButton(
      tester,
      text,
      index: index,
      delay: delay,
      milliseconds: milliseconds,
    );

Future<bool> tapButtonByType(
  WidgetTester tester,
  Type type, {
  int index = 0,
  bool delay = true,
  int? milliseconds,
}) async =>
    await tapButton(
      tester,
      type,
      index: index,
      delay: delay,
      milliseconds: milliseconds,
    );

Future<bool> tapButtonByIndex(
  WidgetTester tester,
  dynamic data, {
  int index = 0,
  bool delay = true,
  int? milliseconds,
}) async =>
    await tapButton(
      tester,
      data,
      index: index,
      delay: delay,
      milliseconds: milliseconds,
    );

Future<bool> tapButtonByIcon(
  WidgetTester tester,
  IconData icon, {
  int index = 0,
  bool delay = true,
  int? milliseconds,
}) async =>
    await tapButton(
      tester,
      icon,
      index: index,
      delay: delay,
      milliseconds: milliseconds,
    );

Future<bool> tapButtonByLabel(
  WidgetTester tester,
  String label, {
  int index = 0,
  bool delay = true,
  int? milliseconds,
}) async =>
    await tapButton(
      tester,
      label,
      index: index,
      delay: delay,
      milliseconds: milliseconds,
    );

Future<bool> enterText(
  WidgetTester tester,
  Type type,
  String text, {
  int? index,
  bool delay = true,
  int? milliseconds,
}) async {
  index != null
      ? await tester.enterText(widgetByType(type).at(index), text)
      : await tester.enterText(widgetByType(type), text);
  await tester.pumpAndSettle();
  if (delay) {
    await Future.delayed(Duration(milliseconds: milliseconds ?? defaultDelay));
  }
  return true;
}

enum ScrollDirection { Up, Down, Left, Right }

Future<bool> scrollUntilVisible(
  WidgetTester tester,
  Finder finder, {
  int? index,
  bool delay = true,
  int? milliseconds,
  // take last because the tab bar up top is also a Scrollable
  bool? lastScroll,
}) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  if (delay) {
    await Future.delayed(Duration(milliseconds: milliseconds ?? defaultDelay));
  }
  return true;
}

Future<bool> teardownTest() async {
  ApiDatabase apiDatabase = Locator.instance<ApiDatabase>();
  if (globals.testingActive) {
    if (globals.testingDeleteStorage) {
      await apiDatabase.deleteAllWallets();
      await apiDatabase.openDatabase();
      globals.firstRun = false;
    }
    await apiDatabase.lockDatabase();
  }
  return true;
}

bool isTextOnScreen(String text) => find.text(text).hasFound;
