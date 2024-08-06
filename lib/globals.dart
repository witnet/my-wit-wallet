import 'package:flutter/material.dart';

bool testingActive = false;
bool testingDeleteStorage = false;
bool biometricsAuthInProgress = false;
bool avoidBiometrics = false;
bool firstRun = false;
String? scannedContent = null;
bool? isPanelClose;
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
