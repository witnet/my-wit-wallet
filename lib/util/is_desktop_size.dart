import 'package:flutter/material.dart';
import 'package:my_wit_wallet/globals.dart';

bool get isDesktopSize => navigatorKey.currentContext != null
    ? MediaQuery.of(navigatorKey.currentContext!).size.width > 1200
    : false;
