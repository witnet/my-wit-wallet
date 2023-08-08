import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';

Finder widgetByType(Type type) => find.byType(type);
Finder widgetByText(String text) => find.text(text);
Finder widgetByIcon(IconData icon) => find.byIcon(icon);
Finder widgetByLabel(String label) => find.bySemanticsLabel(label);
const int defaultDelay = 1000;

Future<bool> tapButton(WidgetTester tester, dynamic value,
    {int? index, bool delay = true, int milliseconds = defaultDelay}) async {
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
    await Future.delayed(Duration(milliseconds: milliseconds));
  }
  return true;
}

Future<bool> tapButtonByName(WidgetTester tester, String text,
        {int index = 0,
        bool delay = true,
        int milliseconds = defaultDelay}) async =>
    await tapButton(
      tester,
      text,
      index: index,
      delay: delay,
      milliseconds: milliseconds,
    );

Future<bool> tapButtonByType(WidgetTester tester, Type type,
        {int index = 0,
        bool delay = true,
        int milliseconds = defaultDelay}) async =>
    await tapButton(
      tester,
      type,
      index: index,
      delay: delay,
      milliseconds: milliseconds,
    );

Future<bool> tapButtonByIndex(WidgetTester tester, dynamic data,
        {int index = 0,
        bool delay = true,
        int milliseconds = defaultDelay}) async =>
    await tapButton(
      tester,
      data,
      index: index,
      delay: delay,
      milliseconds: milliseconds,
    );

Future<bool> tapButtonByIcon(WidgetTester tester, IconData icon,
        {int index = 0,
        bool delay = true,
        int milliseconds = defaultDelay}) async =>
    await tapButton(
      tester,
      icon,
      index: index,
      delay: delay,
      milliseconds: milliseconds,
    );

Future<bool> tapButtonByLabel(WidgetTester tester, String label,
        {int index = 0,
        bool delay = true,
        int milliseconds = defaultDelay}) async =>
    await tapButton(
      tester,
      label,
      index: index,
      delay: delay,
      milliseconds: milliseconds,
    );

Future<bool> enterText(WidgetTester tester, Type type, String text,
    {int? index, bool delay = true, int milliseconds = defaultDelay}) async {
  index != null
      ? await tester.enterText(widgetByType(type).at(index), text)
      : await tester.enterText(widgetByType(type), text);
  await tester.pumpAndSettle();
  if (delay) {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }
  return true;
}

enum ScrollDirection { Up, Down, Left, Right }

Future<bool> scrollUntilVisible(WidgetTester tester, Finder finder,
    {int index = 0, bool delay = true, int milliseconds = defaultDelay}) async {
  await tester.scrollUntilVisible(finder, -100.0,
      duration: Duration(milliseconds: 500), maxScrolls: 100);
  await tester.pumpAndSettle();
  if (delay) {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }
  return true;
}

bool isTextOnScreen(String text) =>
    !find.text(text).toString().startsWith('zero widgets with text "$text"');
