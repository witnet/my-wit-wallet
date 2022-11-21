import 'package:shared_preferences/shared_preferences.dart';

class ApiPreferences {
  static Future<void> setCurrentWallet(String walletId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('current_wallet', walletId);
  }

  static Future<String?> getCurrentWallet() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString('current_wallet');
  }
}
