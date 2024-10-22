import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:my_wit_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:my_wit_wallet/screens/preferences/preferences_screen.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/widgets/layouts/send_transaction_layout.dart';
import 'package:witnet/data_structures.dart';

typedef String LocalizationCallback(String value);

Map<WalletType, String> walletTypeToLabel(BuildContext context) => {
      WalletType.hd: AppLocalizations.of(context)!.walletTypeHDLabel,
      WalletType.single: AppLocalizations.of(context)!.walletTypeNodeLabel,
    };

Map<DashboardViewSteps, String> localizedDashboardSteps = {
  DashboardViewSteps.transactions:
      localization.dashboardViewSteps('transactions'),
  DashboardViewSteps.stats: localization.dashboardViewSteps('stats'),
};

Map<TxSteps, String> localizedVTTsteps = {
  TxSteps.Transaction: localization.vttSendSteps('Transaction'),
  TxSteps.MinerFee: localization.vttSendSteps('MinerFee'),
  TxSteps.Review: localization.vttSendSteps('Review'),
};
Map<TxSteps, String> localizedStakeSteps = {
  TxSteps.Transaction: localization.stakeSteps('Transaction'),
  TxSteps.MinerFee: localization.stakeSteps('MinerFee'),
  TxSteps.Review: localization.stakeSteps('Review'),
};
Map<TxSteps, String> localizedUnstakeSteps = {
  TxSteps.Transaction: localization.unstakeSteps('Transaction'),
  TxSteps.Review: localization.unstakeSteps('Review'),
};
Map<EstimatedFeeOptions, String> localizedFeeOptions = {
  EstimatedFeeOptions.Stinky: localization.estimatedFeeOptions('stinky'),
  EstimatedFeeOptions.Low: localization.estimatedFeeOptions('low'),
  EstimatedFeeOptions.Medium: localization.estimatedFeeOptions('medium'),
  EstimatedFeeOptions.High: localization.estimatedFeeOptions('high'),
  EstimatedFeeOptions.Opulent: localization.estimatedFeeOptions('opulent'),
  EstimatedFeeOptions.Custom: localization.estimatedFeeOptions('custom'),
};

Map<FeeType, String> localizedFeeTypeOptions = {
  FeeType.Absolute: localization.feeTypeOptions('absolute'),
  FeeType.Weighted: localization.feeTypeOptions('weighted'),
};

Map<ConfigSteps, String> localizedConfigSteps = {
  ConfigSteps.general: localization.preferenceTabs('general'),
  ConfigSteps.wallet: localization.preferenceTabs('wallet'),
};

/// Explorer Settings
const bool USE_EXPLORER_DEV = false;
// ignore: non_constant_identifier_names
String EXPLORER_ADDRESS = dotenv.get('EXPLORER_ADDRESS');
// ignore: non_constant_identifier_names
String EXPLORER_DEV_ADDRESS = dotenv.get('EXPLORER_DEV_ADDRESS');
const int EXPLORER_DELAY_MS = 100;
const int SYNC_TIMER_IN_SECONDS = 30;

class Constants {
  static const String appName = 'Witnet';
  static const String logoTag = 'witnet.logo';
  static const String titleTag = 'witnet.title';
}

/// Wallet Settings

enum WitUnit {
  Wit,
  milliWit,
  microWit,
  nanoWit,
}

// ignore: non_constant_identifier_names
Map<WitUnit, String> WIT_UNIT = {
  WitUnit.Wit: 'WIT',
  WitUnit.milliWit: 'milliWIT',
  WitUnit.microWit: 'microWIT',
  WitUnit.nanoWit: 'nanoWIT',
};

enum EstimatedFeeOptions { Stinky, Low, Medium, High, Opulent, Custom }

enum ImportOrigin { fromSheikah, fromMyWitWallet, fromNode }

// ignore: non_constant_identifier_names
Map<EstimatedFeeOptions, String?> DEFAULT_MINER_FEE_OPTIONS = {
  EstimatedFeeOptions.Stinky: '0',
  EstimatedFeeOptions.Low: '0',
  EstimatedFeeOptions.Medium: '0',
  EstimatedFeeOptions.High: '0',
  EstimatedFeeOptions.Opulent: '0',
  EstimatedFeeOptions.Custom: null,
};

Map<ImportOrigin, String> importOriginToLabel(BuildContext context) {
  AppLocalizations _localization = AppLocalizations.of(context)!;
  return {
    ImportOrigin.fromMyWitWallet: 'myWitWallet',
    ImportOrigin.fromSheikah: 'Sheikah',
    ImportOrigin.fromNode: _localization.walletTypeNodeLabel
  };
}

Map<ImportOrigin, CreateWalletType> importOriginToXprvType = {
  ImportOrigin.fromMyWitWallet: CreateWalletType.encryptedXprv,
  ImportOrigin.fromSheikah: CreateWalletType.encryptedXprv,
  ImportOrigin.fromNode: CreateWalletType.xprv
};

Map<CreateWalletType, WalletType> xprvTypeToWalletType = {
  CreateWalletType.encryptedXprv: WalletType.hd,
  CreateWalletType.xprv: WalletType.single
};
const int EXTERNAL_GAP_LIMIT = 10;
const int INTERNAL_GAP_LIMIT = 3;
const bool ENCRYPT_DB = false;
const int PAGINATION_LIMIT = 10;
const double SMALL_DASHBOARD_HEADER_HEIGHT = 180;
const double LARGE_DASHBOARD_HEADER_HEIGHT = 258;
const double DEFAULT_BOTTOM_PADDING = 24;
const double HEADER_HEIGHT = 158;
const String VERSION_NUMBER = '1.1.4';
const int ENCRYPTED_XPRV_LENGTH = 293;
const int XPRV_LENGTH = 117;
const int MAX_VT_WEIGHT = 20000;

List<LocalizationsDelegate<dynamic>> localizationDelegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

const Map<String, Locale> SUPPORTED_LOCALES = {
  "en": const Locale("en"),
  // "es": const Locale("es"),
};
const int DB_VERSION = 3;
const int DB_VERSION_TO_MIGRATE = 3;
const int DB_PREV_VERSION = 2;
const String COMPATIBLE_API_VERSION = '1.0.0';
const String INSUFFICIENT_FUNDS_ERROR = "Insufficient funds";
const String APP_TITLE = "myWitWallet";
const String WINDOWS_FILE_NAME = "myWitWallet-windows.zip";
const String MACOS_FILE_NAME = "myWitWallet.dmg";
const String LINUX_FILE_NAME = "myWitWallet-linux.tar.gz";
const String DEFAULT_FILE_NAME = "myWitWallet.zip";
const String LATEST_RELEASE_URL =
    "https://api.github.com/repos/witnet/my-wit-wallet/releases/latest";
const String DOWNLOAD_BASE_URL =
    "https://github.com/witnet/my-wit-wallet/releases/download";

const double BORDER_RADIUS = 32;

const List<String> CUSTOM_ICON_NAMES = [
  'create-or-import-wallet',
  'general-error',
  'general-warning',
  'import-wallet',
  'empty',
  'receive-icon-dark',
  'receive-icon',
  'send-icon-dark',
  'send-icon',
  'send-receive-desktop-dark',
  'send-receive-desktop',
  'send-receive-dark',
  'send-receive',
  'sending-transaction',
  'signing-transaction',
  'stake-desktop-dark',
  'stake-desktop',
  'stake-dark',
  'stake-icon-dark',
  'stake-icon',
  'dots-bg',
  'dots-bg-dark',
  'stake',
  'transaction-error',
  'transaction-success',
  'unstake-icon-dark',
  'unstake-icon',
];
