import 'package:get_it/get_it.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:my_wit_wallet/bloc/crypto/api_crypto.dart';
import 'package:my_wit_wallet/bloc/crypto/crypto_bloc.dart';
import 'package:my_wit_wallet/util/preferences.dart';
import 'package:my_wit_wallet/util/storage/cache/implementations/vtt_get_through_block_explorer.dart';
import 'package:my_wit_wallet/util/storage/database/database_isolate.dart';
import 'package:my_wit_wallet/bloc/explorer/api_explorer.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/api_theme.dart';
import 'package:my_wit_wallet/util/storage/log.dart';

class Locator {
  static late GetIt _i;
  static GetIt get instance => _i;

  Locator.setup() {
    _i = GetIt.I;

    /// check if things are already registered, if they are skip it.
    /// if they are already registered it is because of end-to-end testing.
    register(ApiTheme.instance());
    register(DebugLogger());
    register(ApiDatabase());
    register(ApiExplorer());
    register(ApiPreferences());
    register(ApiCreateWallet());
    register(ApiCrypto());
    register(CryptoIsolate.instance());
    register(DatabaseIsolate.instance());
    register(VttGetThroughBlockExplorer());
  }

  void register<T extends Object>(T constructor) {
    if (!_i.isRegistered<T>()) {
      _i.registerSingleton<T>(constructor);
    }
  }

  Future<bool> initialize() async {
    await Locator.instance<DatabaseIsolate>().init();

    return true;
  }
}
