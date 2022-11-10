import 'package:get_it/get_it.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:witnet_wallet/bloc/crypto/api_crypto.dart';
import 'package:witnet_wallet/bloc/crypto/crypto_bloc.dart';
import 'package:witnet_wallet/util/storage/database/database_isolate.dart';
import 'package:witnet_wallet/bloc/explorer/api_explorer.dart';
import 'package:witnet_wallet/screens/dashboard/api_dashboard.dart';
import 'package:witnet_wallet/shared/api_database.dart';
import 'package:witnet_wallet/shared/api_theme.dart';
import 'package:witnet_wallet/util/storage/cache/transaction_cache.dart';

class Locator {
  static late GetIt _i;
  static GetIt get instance => _i;

  Locator.setup() {
    _i = GetIt.I;

    _i.registerSingleton<ApiTheme>(ApiTheme());
    _i.registerSingleton<ApiDatabase>(ApiDatabase());
    _i.registerSingleton<ApiExplorer>(ApiExplorer());
    _i.registerSingleton<TransactionCache>(TransactionCache());
    _i.registerSingleton<ApiCreateWallet>(ApiCreateWallet());
    _i.registerSingleton<ApiCrypto>(ApiCrypto());
    _i.registerSingleton<ApiDashboard>(ApiDashboard());
    _i.registerSingleton<CryptoIsolate>(CryptoIsolate.instance());
    _i.registerSingleton<DatabaseIsolate>(DatabaseIsolate.instance());
  }

  Future<bool> initialize() async {
    await Locator.instance<DatabaseIsolate>().init();

    return true;
  }
}
