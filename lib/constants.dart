import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

const kTitleKey = Key('WALLET_TITLE');
const kDebugToolbarKey = Key('DEBUG_TOOLBAR');
const kRecoverWalletIntroKey = Key('RECOVER_WALLET_INTRO');
const kRecoverWalletDescriptionKey = Key('RECOVER_WALLET_DESCRIPTION');

const kMinLogoHeight = 50.0; // hide logo if less than this
const kMaxLogoHeight = 125.0;

/// Wallet Settings

enum WitUnit {
  Wit,
  milliWit,
  microWit,
  nanoWit,
}

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
const int EXTERNAL_GAP_LIMIT = 3;
const int INTERNAL_GAP_LIMIT = 1;
const bool ENCRYPT_DB = false;
