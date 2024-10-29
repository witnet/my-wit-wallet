import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

bool testingActive = false;
bool testingDeleteStorage = false;
bool biometricsAuthInProgress = false;
bool avoidBiometrics = false;
bool firstRun = false;
String? scannedContent = null;
bool? isPanelClose;
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
PanelController panelController = PanelController();
