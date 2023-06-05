import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';
import 'package:my_wit_wallet/util/storage/database/wallet_storage.dart';

import '../shared/locator.dart';

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

    /// The address index is a segment of the full BIP32 keychain path
    /// e.g. if the path is "m/3.0/4919.0/0.0/0/1" the addressIndex is "0/1"
    String addressIndex =
        await ApiPreferences.getCurrentAddress(walletId) ?? "0/0";
    ApiDatabase db = Locator.instance.get<ApiDatabase>();
    WalletStorage walletStorage = db.walletStorage;
    walletStorage.setCurrentWallet(walletId);
    String address;
    int index = int.parse(addressIndex.split("/").last);

    /// Checking the if the wallet chain portion is equal to zero
    /// ensures it is an external keychain
    /// Also check if the index is in the database
    if (addressIndex.split('/').first == "0" &&
        walletStorage.currentWallet.externalAccounts.containsKey(index)) {
      address = walletStorage.currentWallet.externalAccounts[index]!.address;
    } else {
      /// if the addressIndex is an internal / change account or
      /// if it is not in the database,
      /// return the first external address as default
      address = walletStorage.currentWallet.externalAccounts[0]!.address;
    }
    Locator.instance
        .get<ApiDatabase>()
        .walletStorage
        .setCurrentAccount(address);
    await prefs.setString('current_wallet', walletId);
  }

  static Future<String?> getCurrentWallet() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? currentWallet = pref.getString('current_wallet');
    ApiDatabase db = Locator.instance.get<ApiDatabase>();
    WalletStorage walletStorage = db.walletStorage;
    walletStorage.setCurrentWallet(currentWallet!);
    String address;
    String? addressIndex =
        await ApiPreferences.getCurrentAddress(currentWallet);
    int index = int.parse(addressIndex!.split("/").last);
    if (addressIndex.split('/').first == "0" &&
        walletStorage.currentWallet.externalAccounts.containsKey(index)) {
      address = walletStorage.currentWallet.externalAccounts[index]!.address;
    } else {
      address = walletStorage.currentWallet.externalAccounts[0]!.address;
    }
    Locator.instance
        .get<ApiDatabase>()
        .walletStorage
        .setCurrentAccount(address);
    return currentWallet;
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
    final currentMap = prefs.getString('current_address');
    Map<String, String>? finalMap;
    if (currentMap != null) {
      finalMap = {
        ...json.decode(currentMap),
        "${addressEntry.walletId}":
            "${addressEntry.keyType}/${addressEntry.addressIdx}"
      };
    } else {
      finalMap = {
        "${addressEntry.walletId}":
            "${addressEntry.keyType}/${addressEntry.addressIdx}"
      };
    }
    ApiDatabase db = Locator.instance.get<ApiDatabase>();
    String? address;
    int index = int.parse(addressEntry.addressIdx);
    WalletStorage walletStorage = db.walletStorage;
    walletStorage.setCurrentWallet(addressEntry.walletId);
    walletStorage.setCurrentAddressList(finalMap);
    if (addressEntry.keyType == 0 &&
        walletStorage.currentWallet.externalAccounts.containsKey(index)) {
      address = walletStorage.currentWallet.externalAccounts[index]!.address;
    } else {
      address = walletStorage.currentWallet.externalAccounts[0]!.address;
    }
    walletStorage.setCurrentAccount(address);
    await prefs.setString('current_address', json.encode(finalMap));
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

  static Future<String?> getCurrentAddress(String walletId) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? selectedAddressesList = pref.getString('current_address');
    if (selectedAddressesList != null) {
      final result = json.decode(selectedAddressesList);
      return result[walletId];
    } else {
      return null;
    }
  }
}
