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
    if (!_i.isRegistered<ApiTheme>()) {
      _i.registerSingleton<ApiTheme>(ApiTheme.instance());
      _i.registerSingleton<DebugLogger>(DebugLogger());
      _i.registerSingleton<ApiDatabase>(ApiDatabase());
      _i.registerSingleton<ApiExplorer>(ApiExplorer());
      _i.registerSingleton<ApiPreferences>(ApiPreferences());
      _i.registerSingleton<ApiCreateWallet>(ApiCreateWallet());
      _i.registerSingleton<ApiCrypto>(ApiCrypto());
      _i.registerSingleton<CryptoIsolate>(CryptoIsolate.instance());
      _i.registerSingleton<DatabaseIsolate>(DatabaseIsolate.instance());
      _i.registerSingleton<VttGetThroughBlockExplorer>(
          VttGetThroughBlockExplorer());
    }
  }

  Future<bool> initialize() async {
    await Locator.instance<DatabaseIsolate>().init();

    return true;
  }
}
