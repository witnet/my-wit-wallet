import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Explorer Settings
const bool USE_EXPLORER_DEV = false;
String EXPLORER_ADDRESS = dotenv.get('EXPLORER_ADDRESS');
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

Map<String, String> WIT_UNIT = {
  'WIT': 'Wit',
  'MILLI': 'milliWit',
  'MICRO': 'microWit',
  'NANO': 'nanoWit',
};

const int EXTERNAL_GAP_LIMIT = 20;
const int INTERNAL_GAP_LIMIT = 1;
const bool ENCRYPT_DB = false;
