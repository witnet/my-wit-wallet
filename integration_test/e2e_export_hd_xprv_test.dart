part of 'test_utils.dart';

Future<void> e2eExportHdXprvTest(WidgetTester tester) async {
  await initializeTest(tester);

  AppLocalizations _localization =
      AppLocalizations.of(navigatorKey.currentContext!)!;

  /// Create or Import Wallet
  await tapButton(tester, _localization.importWalletLabel);
  await tapButton(tester, _localization.importXprvLabel);

  /// Wallet Security
  await scrollUntilVisible(
      tester, widgetByLabel(_localization.walletSecurityConfirmLabel));
  await tapButton(tester, LabeledCheckbox);
  await tapButton(tester, _localization.continueLabel);

  /// Enter Shiekah Compatible Encrypted Xprv
  await enterText(tester, TextField, sheikahXprv, index: 0);
  await enterText(tester, TextField, password, index: 1);
  await tapButton(tester, _localization.continueLabel);

  /// Enter Wallet Name
  await enterText(tester, TextField, "Test Wallet");
  await tapButton(tester, _localization.continueLabel);

  /// Enter the password
  await enterText(tester, TextFormField, password, index: 0);
  await enterText(tester, TextFormField, password, index: 1);
  await tapButton(tester, _localization.continueLabel);

  await tester.pumpAndSettle();

  /// Get the currentWallet loaded in the dashboard
  final DashboardScreenState dashboardScreenState =
      tester.state(widgetByType(DashboardScreen));
  Wallet? currentWallet = dashboardScreenState.currentWallet;

  await tapButton(tester, FontAwesomeIcons.gear);
  await tapButton(tester, _localization.preferenceTabs('wallet'));

  await tapButton(tester, _localization.exportXprv);

  await enterText(tester, TextFormField, password, index: 0);

  await scrollUntilVisible(
      tester, widgetByText(_localization.verifyLabel).first,
      lastScroll: true);

  await tapButton(tester, _localization.verifyLabel);

  await tester.pumpAndSettle();

  await enterText(tester, TextFormField, password, index: 0);
  await enterText(tester, TextFormField, password, index: 1);

  await scrollUntilVisible(
      tester, widgetByText(_localization.generateXprv).first,
      lastScroll: true);

  await tapButton(tester, _localization.generateXprv);

  // Scroll Save button into view
  await scrollUntilVisible(
      tester, widgetByText(_localization.copyXprvLabel).first,
      lastScroll: true);
  await tester.pumpAndSettle();
  await tapButton(tester, _localization.copyXprvLabel);

  // Data from the copied xprv
  ClipboardData? data = await Clipboard.getData('text/plain');

  /// Dashboard
  /// Tap on the first PaddedButton on the screen, which is the identicon
  /// and brings up the wallet list.
  await tapButton(tester, PaddedButton, index: 0);
  await tapButton(tester, FontAwesomeIcons.circlePlus);

  /// Create or Import Wallet
  await tapButton(tester, _localization.importWalletLabel);
  await tapButton(tester, _localization.importXprvLabel);

  /// Wallet Security
  await scrollUntilVisible(
      tester, widgetByLabel(_localization.walletSecurityConfirmLabel));
  await tapButton(tester, LabeledCheckbox);
  await tapButton(tester, _localization.continueLabel);

  /// Enter Sheikah Compatible Encrypted Xprv
  await enterText(tester, TextField, data?.text ?? '', index: 0);
  await enterText(tester, TextField, password, index: 1);
  await tapButton(tester, _localization.continueLabel);

  /// Enter Wallet Name
  await enterText(tester, TextField, "Test Wallet");
  await tapButton(tester, _localization.continueLabel);

  /// Get the currentWallet loaded in the dashboard
  final DashboardScreenState dashboardScreenState2 =
      tester.state(widgetByType(DashboardScreen));
  Wallet? currentWallet2 = dashboardScreenState2.currentWallet;

  /// Verify the imported wallet and the current address corresponds to the exported xprv
  expect(currentWallet2!.externalAccounts[0]!.address,
      currentWallet!.externalAccounts[0]!.address);

  await teardownTest();
}
// Warning: A call to tap() with finder "Found 1 widget with type "LabeledCheckbox": [
//     LabeledCheckbox(dependencies: [_InheritedTheme, _LocalizationsScope-[GlobalKey#be661]]),
//   ]" derived an Offset (Offset(208.5, 609.0)) that would not hit test on the specified widget.
//   Maybe the widget is actually off-screen, or another widget is obscuring it, or the widget cannot receive pointer events.
//   The finder corresponds to this RenderBox: RenderFlex#3287f relayoutBoundary=up8
//   The hit test result at that offset is: HitTestResult(RenderPointerListener#51b7f@Offset(75.0, 0.0), RenderSemanticsGestureHandler#db3b8@Offset(75.0, 0.0), RenderSemanticsAnnotations#8d0fa@Offset(75.0, 0.0), RenderPositionedBox#faa65@Offset(75.0, 0.0), RenderAnimatedOpacity#d4088@Offset(75.0, 0.0), RenderClipRect#0cf29@Offset(75.0, 0.0), RenderOffstage#ba6fc@Offset(75.0, 0.0), RenderConstrainedBox#3239f@Offset(75.0, 0.0), RenderCustomMultiChildLayoutBox#19adf@Offset(208.5, 609.0), _RenderInkFeatures#a3663@Offset(208.5, 609.0), RenderPhysicalModel#d7f81@Offset(208.5, 609.0), RenderStack#a531d@Offset(208.5, 609.0), RenderPointerListener#08dec@Offset(208.5, 609.0), RenderSemanticsAnnotations#ef923@Offset(208.5, 609.0), RenderSemanticsAnnotations#f78ed@Offset(208.5, 609.0), RenderSemanticsAnnotations#1b7e6@Offset(208.5, 609.0), RenderRepaintBoundary#97fe1@Offset(208.5, 609.0), RenderIgnorePointer#fc2f2@Offset(208.5, 609.0), _RenderSnapshotWidget#268ff@Offset(208.5, 609.0), _RenderSnapshotWidget#38f5c@Offset(208.5,
//   #0      WidgetController._getElementPoint (package:flutter_test/src/controller.dart:1409:25)
//   #1      WidgetController.getCenter (package:flutter_test/src/controller.dart:1292:12)
//   #2      WidgetController.tap (package:flutter_test/src/controller.dart:613:18)
//   #3      tapButton (file:///home/runner/work/my-wit-wallet/my-wit-wallet/integration_test/test_utils.dart:108:16)
//   #4      e2eExportHdXprvTest (file:///home/runner/work/my-wit-wallet/my-wit-wallet/integration_test/e2e_export_hd_xprv_test.dart:87:9)
//   <asynchronous suspension>
//   #5      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:168:15)
//   <asynchronous suspension>
//   #6      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1013:5)
//   <asynchronous suspension>
//   #7      StackZoneSpecification._registerCallback.<anonymous closure> (package:stack_trace/src/stack_zone_specification.dart:114:42)
//   <asynchronous suspension>
//   To silence this warning, pass "warnIfMissed: false" to "tap()".
//   To make this warning fatal, set WidgetController.hitTestWarningShouldBeFatal to true.
//   ══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
//   The following IndexError was thrown running a test:
//   RangeError (index): Index out of range: no indices are valid: 0
//   When the exception was thrown, this was the stack:
//   #0      Iterable.elementAt (dart:core/iterable.dart:807:5)
//   #1      _IndexFinderMixin.filter (package:flutter_test/src/finders.dart:1103:28)
//   #3      ExpandIterator.moveNext (dart:_internal/iterable.dart:489:21)
//   #4      SetBase.addAll (dart:collection/set.dart:58:23)
//   #5      _Set.addAll (dart:collection-patch/compact_hash.dart:986:11)
//   #6      new LinkedHashSet.of (dart:collection/linked_hash_set.dart:192:27)
//   #7      Iterable.toSet (dart:core/iterable.dart:512:21)
//   #8      _DescendantFinderMixin.allCandidates (package:flutter_test/src/finders.dart:1457:7)
//   #9      FinderBase.evaluate (package:flutter_test/src/finders.dart:781:76)
//   #10     WidgetController.state (package:flutter_test/src/controller.dart:490:31)
//   #11     WidgetTester.showKeyboard.<anonymous closure> (package:flutter_test/src/widget_tester.dart:1098:42)
//   #14     TestAsyncUtils.guard (package:flutter_test/src/test_async_utils.dart:71:41)
//   #15     WidgetTester.showKeyboard (package:flutter_test/src/widget_tester.dart:1097:27)
//   #16     WidgetTester.enterText.<anonymous closure> (package:flutter_test/src/widget_tester.dart:1133:13)
//   #19     TestAsyncUtils.guard (package:flutter_test/src/test_async_utils.dart:71:41)
//   #20     WidgetTester.enterText (package:flutter_test/src/widget_tester.dart:1132:27)
//   #21     enterText (file:///home/runner/work/my-wit-wallet/my-wit-wallet/integration_test/test_utils.dart:200:22)
//   #22     e2eExportHdXprvTest (file:///home/runner/work/my-wit-wallet/my-wit-wallet/integration_test/e2e_export_hd_xprv_test.dart:91:9)
//   <asynchronous suspension>
//   #23     testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:168:15)
//   <asynchronous suspension>
//   #24     TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1013:5)
//   <asynchronous suspension>
//   <asynchronous suspension>
//   (elided 6 frames from dart:async, dart:async-patch, and package:stack_trace)
//   The test description was:
//     Export Hd Xprv Test
//   ════════════════════════════════════════════════════════════════════════════════════════════════════
//   Test failed. See exception logs above.
//   The test description was: Export Hd Xprv Test