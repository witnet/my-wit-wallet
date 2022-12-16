import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddressEntry {
  String walletId;
  String addressIdx;

  AddressEntry({
    required this.walletId,
    required this.addressIdx,
  });
}

class ApiPreferences {
  static Future<void> setCurrentWallet(String walletId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('current_wallet', walletId);
  }

  static Future<String?> getCurrentWallet() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString('current_wallet');
  }

  static Future<void> setCurrentAddress(AddressEntry addressEntry) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final currentMap = prefs.getString('current_address');
    Map<String, String>? finalMap;
    if (currentMap != null) {
      finalMap = {
        ...json.decode(currentMap),
        "${addressEntry.walletId}": "${addressEntry.addressIdx}"
      };
    } else {
      finalMap = {"${addressEntry.walletId}": "${addressEntry.addressIdx}"};
    }
    prefs.setString('current_address', json.encode(finalMap));
  }

  static Future getCurrentAddressList() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? selectedAddressesList = pref.getString('current_address');
    if (selectedAddressesList != null) {
      return json.decode(selectedAddressesList);
    } else {
      return null;
    }
  }

  static Future<String?> getCurrentAddress(String walletId) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? selectedAddressesList = pref.getString('current_address');
    if (selectedAddressesList != null) {
      final result = json.decode(selectedAddressesList);
      return result[walletId];
    } else {
      return '';
    }
  }
}
