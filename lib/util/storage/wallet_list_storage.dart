import 'dart:convert';
import 'dart:io' as io;
import 'path_provider_interface.dart';

class WalletInfo {
  WalletInfo(this.name, this.description);
  String name;
  String description;
  String get rawJson => json.encode(jsonMap);

  factory WalletInfo.fromJson(Map<String, dynamic> data) {
    return WalletInfo(data['name'], data['description']);
  }
  Map<String, dynamic> get jsonMap => {
        'name': name,
        'description': description,
      };
}

class WalletListStorage {
  // singleton
  static final WalletListStorage _listStorage = WalletListStorage._internal();
  factory WalletListStorage() => _listStorage;
  WalletListStorage._internal();

  Future<String> get _localPath async {
    return PathProviderInterface().localPath;
  }

  Future<io.File> get _localFile async {
    final path = await _localPath;
    return io.File('$path${io.Platform.pathSeparator}wallets.json');
  }

  Future<Map<String, dynamic>> readFile() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      return json.decode(contents);
    } catch (error) {
      var file = await writeFile({'wallets': []});
      return {'wallets': []};
    }
  }

  Future<io.File> writeFile(Map<String, dynamic> data) async {
    final file = await _localFile;
    return file.writeAsString(jsonEncode(data));
  }

  Future<List<WalletInfo>> getWalletInfoList() async {
    final Map<String, dynamic> infos = await readFile();
    return List<WalletInfo>.from(
        infos['wallets'].map((value) => WalletInfo.fromJson(value)));
  }

  Future<bool> removeWalletInfoFromList(WalletInfo walletInfo) async {
    return true;
  }

  Future<bool> saveWalletInfoListFile(List<WalletInfo> infos) async {
    try {
      await writeFile({'wallets': List.from(infos.map((e) => e.jsonMap))});
      return true;
    } catch (error) {
      return false;
    }
  }

  // returns null on success or error as string
  Future<dynamic> addWalletInfoToList(WalletInfo walletInfo) async {
    List<WalletInfo> infos = await getWalletInfoList();
    for (int i = 0; i < infos.length; i++) {
      if (walletInfo.name == infos[i].name) {
        // error wallet already exists // need to ask user if overwrite or not
        return 'Wallet already exists';
      }
    }

    infos.add(walletInfo);
    await saveWalletInfoListFile(infos);
    return null;
  }
}
