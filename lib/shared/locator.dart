
import 'package:get_it/get_it.dart';
import 'package:witnet_wallet/bloc/auth/create_wallet/api_create_wallet.dart';
import 'package:witnet_wallet/bloc/crypto/api_crypto.dart';
import 'package:witnet_wallet/bloc/crypto/crypto_isolate.dart';
import 'package:witnet_wallet/bloc/database/database_isolate.dart';
import 'package:witnet_wallet/bloc/explorer/api_explorer.dart';
import 'package:witnet_wallet/screens/dashboard/api_dashboard.dart';
import 'package:witnet_wallet/shared/api_database.dart';
import 'package:witnet_wallet/shared/api_theme.dart';
import 'package:witnet_wallet/util/storage/cache/file_manager_interface.dart';
import 'package:witnet_wallet/util/storage/database/database_service.dart';

import 'api_auth.dart';

class Locator {
  static late GetIt _i;
  static GetIt get instance => _i;

  Locator.setup() {
    _i = GetIt.I;

    _i.registerSingleton<ApiAuth>(ApiAuth());
    _i.registerSingleton<ApiTheme>(ApiTheme());
    _i.registerSingleton<ApiDatabase>(ApiDatabase());
    _i.registerSingleton<ApiExplorer>(ApiExplorer());
    _i.registerSingleton<TransactionCache>(TransactionCache());
    _i.registerSingleton<ApiCreateWallet>(ApiCreateWallet());
    _i.registerSingleton<ApiCrypto>(ApiCrypto());
    _i.registerSingleton<ApiDashboard>(ApiDashboard());
    _i.registerSingleton<DBService>(DBService());
    _i.registerSingleton<CryptoIsolate>(CryptoIsolate.instance());
    _i.registerSingleton<DatabaseIsolate>(DatabaseIsolate.instance());
  }
}
