import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';

/// Explorer Settings
const bool USE_EXPLORER_DEV = false;
// ignore: non_constant_identifier_names
String EXPLORER_ADDRESS = dotenv.get('EXPLORER_ADDRESS');
// ignore: non_constant_identifier_names
String EXPLORER_DEV_ADDRESS = dotenv.get('EXPLORER_DEV_ADDRESS');
const int EXPLORER_DELAY_MS = 100;

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

// ignore: non_constant_identifier_names
Map<EstimatedFeeOptions, String?> DEFAULT_MINER_FEE_OPTIONS = {
  EstimatedFeeOptions.Stinky: '0',
  EstimatedFeeOptions.Low: '0',
  EstimatedFeeOptions.Medium: '0',
  EstimatedFeeOptions.High: '0',
  EstimatedFeeOptions.Opulent: '0',
  EstimatedFeeOptions.Custom: null,
};
Map<WalletType, String> walletTypeToLabel = {
  WalletType.hd: 'HD wallet',
  WalletType.single: 'Single address',
};
Map<CreateWalletType, WalletType> xprvTypeToWalletType = {
  CreateWalletType.encryptedXprv: WalletType.hd,
  CreateWalletType.xprv: WalletType.single
};
Map<WalletType, CreateWalletType> walletTypeToXprvType = {
  WalletType.hd: CreateWalletType.encryptedXprv,
  WalletType.single: CreateWalletType.xprv
};
const int EXTERNAL_GAP_LIMIT = 3;
const int INTERNAL_GAP_LIMIT = 3;
const bool ENCRYPT_DB = false;
const int PAGINATION_LIMIT = 10;
const String VERSION_NUMBER = '0.1.2-dev';
const double DASHBOARD_HEADER_HEIGTH = 280;
const double HEADER_HEIGTH = 185;
