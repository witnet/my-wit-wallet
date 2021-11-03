import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef ThemedWidgetBuilder = Widget Function(
    BuildContext context, ThemeData data);
typedef ThemeDataWithBrightnessBuilder = ThemeData Function(
    Brightness brightness);

class ApiTheme {
  static const String _sharedPreferencesKey = 'isDark';
  Brightness _brightness = Brightness.dark;
  bool _shouldLoadBrightness = true;

  ApiTheme({
    Key? key,
  });

  Future<void> setBrightness(Brightness brightness) async {
    _brightness = brightness;
    // Save the brightness
    await saveBrightness(brightness);
  }

  /// Returns a boolean that gives you the latest brightness
  Future<bool> getBrightness() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Gets the bool stored in prefs
    // Or returns whether or not the `defaultBrightness` is dark
    return prefs.getBool(_sharedPreferencesKey) ??
        _brightness == Brightness.dark;
  }

  /// Saves the provided brightness in `SharedPreferences`
  Future<void> saveBrightness(Brightness brightness) async {
    //! Shouldn't save the brightness if you don't want to load it
    if (!_shouldLoadBrightness) {
      return;
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Saves whether or not the provided brightness is dark
    await prefs.setBool(
        _sharedPreferencesKey, brightness == Brightness.dark ? true : false);
  }

  /// Loads the brightness depending on the `loadBrightnessOnStart` value
  Future<void> loadBrightness() async {
    if (!_shouldLoadBrightness) {
      return;
    }
    final bool isDark = await getBrightness();
    _brightness = isDark ? Brightness.dark : Brightness.light;
  }
}
