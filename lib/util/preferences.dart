import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';

class AddressEntry {
  String walletId;
  String addressIdx;
  int keyType;
  AddressEntry({
    required this.walletId,
    required this.addressIdx,
    required this.keyType,
  });
}

class ApiPreferences {
  static Future<void> setCurrentWallet(String walletId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_wallet', walletId);
  }

  static Future<String?> getCurrentWallet() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString('current_wallet');
  }

  static Future<void> setTheme(WalletTheme theme) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme.name);
  }

  static Future<String?> getTheme() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString('theme');
  }

  static Future<void> setCurrentAddress(AddressEntry addressEntry) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic>? currentMap = await getCurrentAddressList();
    // get list and update current address from the list
    Map<String, String>? finalMap;
    if (currentMap != null) {
      finalMap = {
        ...currentMap,
        "${addressEntry.walletId}":
            "${addressEntry.keyType}/${addressEntry.addressIdx}"
      };
    } else {
      finalMap = {
        "${addressEntry.walletId}":
            "${addressEntry.keyType}/${addressEntry.addressIdx}"
      };
    }
    await prefs.setString('current_address', json.encode(finalMap));
  }

  static Future<void> setCurrentAddressList(
      List<AddressEntry> addressList) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_address', json.encode(addressList));
  }

  static Future<Map<String, dynamic>?> getCurrentAddressList() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? selectedAddressesList = pref.getString('current_address');
    if (selectedAddressesList != null) {
      return json.decode(selectedAddressesList);
    } else {
      return null;
    }
  }

  static Future clearPreferences() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.clear();
  }

  static Future<String?> getCurrentAddress(String walletId) async {
    Map<String, dynamic>? selectedAddressesList = await getCurrentAddressList();
    if (selectedAddressesList != null) {
      return selectedAddressesList[walletId];
    } else {
      return null;
    }
  }
}
