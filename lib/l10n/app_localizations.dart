import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @addressBalanceDescription.
  ///
  /// In en, this message translates to:
  /// **'Received payments totalling'**
  String get addressBalanceDescription;

  /// No description provided for @addressCopied.
  ///
  /// In en, this message translates to:
  /// **'Address copied!'**
  String get addressCopied;

  /// No description provided for @addressList.
  ///
  /// In en, this message translates to:
  /// **'Address list'**
  String get addressList;

  /// No description provided for @addTimelockLabel.
  ///
  /// In en, this message translates to:
  /// **'Add Timelock (Optional)'**
  String get addTimelockLabel;

  /// No description provided for @advancedSettings.
  ///
  /// In en, this message translates to:
  /// **'Advanced Settings'**
  String get advancedSettings;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @authenticateWithBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Authenticate with biometrics'**
  String get authenticateWithBiometrics;

  /// No description provided for @authorization.
  ///
  /// In en, this message translates to:
  /// **'Node authorization'**
  String get authorization;

  /// No description provided for @authorizationInputHint.
  ///
  /// In en, this message translates to:
  /// **'Node authorization...'**
  String get authorizationInputHint;

  /// No description provided for @autorizationTooltip.
  ///
  /// In en, this message translates to:
  /// **'Node authorization to stake'**
  String get autorizationTooltip;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @backLabel.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backLabel;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'balance'**
  String get balance;

  /// No description provided for @balanceDetails.
  ///
  /// In en, this message translates to:
  /// **'Balance details'**
  String get balanceDetails;

  /// No description provided for @biometricsLabel.
  ///
  /// In en, this message translates to:
  /// **'Biometrics'**
  String get biometricsLabel;

  /// No description provided for @blocksMined.
  ///
  /// In en, this message translates to:
  /// **'Blocks mined'**
  String get blocksMined;

  /// No description provided for @buildWallet01.
  ///
  /// In en, this message translates to:
  /// **'The different addresses in your wallet are being scanned for existing transactions and balance. This will normally take less than 1 minute.'**
  String get buildWallet01;

  /// No description provided for @buildWalletBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get buildWalletBalance;

  /// No description provided for @buildWalletHeader.
  ///
  /// In en, this message translates to:
  /// **'Address discovery'**
  String get buildWalletHeader;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @cancelAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Cancel authentication'**
  String get cancelAuthentication;

  /// No description provided for @carouselMsg01.
  ///
  /// In en, this message translates to:
  /// **'myWitWallet allows you to send and receive Wit immediately. Bye bye synchronization!'**
  String get carouselMsg01;

  /// No description provided for @carouselMsg02.
  ///
  /// In en, this message translates to:
  /// **'myWitWallet uses state-of-the-art cryptography to store your Wit coins securely.'**
  String get carouselMsg02;

  /// No description provided for @carouselMsg03.
  ///
  /// In en, this message translates to:
  /// **'myWitWallet is completely non-custodial. Your keys will never leave your device.'**
  String get carouselMsg03;

  /// No description provided for @chooseMinerFee.
  ///
  /// In en, this message translates to:
  /// **'Choose you desired miner fee'**
  String get chooseMinerFee;

  /// No description provided for @clearTimelockLabel.
  ///
  /// In en, this message translates to:
  /// **'Clear Timelock'**
  String get clearTimelockLabel;

  /// No description provided for @clickToInstall.
  ///
  /// In en, this message translates to:
  /// **'Click to install'**
  String get clickToInstall;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// No description provided for @confirmMnemonic01.
  ///
  /// In en, this message translates to:
  /// **'Type in your secret recovery phrase below exactly as shown before. This will ensure that you have written down your secret recovery phrase correctly.'**
  String get confirmMnemonic01;

  /// No description provided for @confirmMnemonicHeader.
  ///
  /// In en, this message translates to:
  /// **'Secret Recovery Phrase Confirmation'**
  String get confirmMnemonicHeader;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @connectionIssue.
  ///
  /// In en, this message translates to:
  /// **'myWitWallet is experiencing connection problems'**
  String get connectionIssue;

  /// No description provided for @connectionReestablished.
  ///
  /// In en, this message translates to:
  /// **'Connection reestablished!'**
  String get connectionReestablished;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @copyAddressConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Address copied!'**
  String get copyAddressConfirmed;

  /// No description provided for @copyAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Copy selected address'**
  String get copyAddressLabel;

  /// No description provided for @copyAddressToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy address to clipboard'**
  String get copyAddressToClipboard;

  /// No description provided for @copyJson.
  ///
  /// In en, this message translates to:
  /// **'Copy JSON'**
  String get copyJson;

  /// No description provided for @copyStakingAddress.
  ///
  /// In en, this message translates to:
  /// **'Copy withdrawal address'**
  String get copyStakingAddress;

  /// No description provided for @copyXprvConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Xprv copied!'**
  String get copyXprvConfirmed;

  /// No description provided for @copyXprvLabel.
  ///
  /// In en, this message translates to:
  /// **'Copy Xprv'**
  String get copyXprvLabel;

  /// No description provided for @createImportWallet01.
  ///
  /// In en, this message translates to:
  /// **'When you created your wallet, you probably wrote down the secret security phrase on a piece of paper. It looks like a list of 12 apparently random words.'**
  String get createImportWallet01;

  /// No description provided for @createImportWallet02.
  ///
  /// In en, this message translates to:
  /// **'If you did not keep the secret security phrase, you can still export a password-protected Xprv key from the settings of your existing wallet.'**
  String get createImportWallet02;

  /// No description provided for @createImportWalletHeader.
  ///
  /// In en, this message translates to:
  /// **'Create or import your wallet'**
  String get createImportWalletHeader;

  /// No description provided for @createNewWalletLabel.
  ///
  /// In en, this message translates to:
  /// **'Create new wallet'**
  String get createNewWalletLabel;

  /// No description provided for @createOrImportLabel.
  ///
  /// In en, this message translates to:
  /// **'Create or import'**
  String get createOrImportLabel;

  /// No description provided for @createWalletLabel.
  ///
  /// In en, this message translates to:
  /// **'Create wallet'**
  String get createWalletLabel;

  /// No description provided for @cryptoException.
  ///
  /// In en, this message translates to:
  /// **'Error building the wallet'**
  String get cryptoException;

  /// No description provided for @currentAddress.
  ///
  /// In en, this message translates to:
  /// **'Current address'**
  String get currentAddress;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @dashboardViewSteps.
  ///
  /// In en, this message translates to:
  /// **'{selectedIndex, select, transactions{Transactions} stats{Stats} other{unused}}'**
  String dashboardViewSteps(String selectedIndex);

  /// No description provided for @dataRequestTxn.
  ///
  /// In en, this message translates to:
  /// **'Data Request'**
  String get dataRequestTxn;

  /// No description provided for @datePickerFormatError.
  ///
  /// In en, this message translates to:
  /// **'Invalid date format'**
  String get datePickerFormatError;

  /// No description provided for @datePickerHintText.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get datePickerHintText;

  /// No description provided for @datePickerInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid date'**
  String get datePickerInvalid;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteStorageWarning.
  ///
  /// In en, this message translates to:
  /// **'Your storage is about to be permanently deleted!'**
  String get deleteStorageWarning;

  /// No description provided for @deleteWallet.
  ///
  /// In en, this message translates to:
  /// **'Delete wallet'**
  String get deleteWallet;

  /// No description provided for @deleteWallet01.
  ///
  /// In en, this message translates to:
  /// **'Clicking \"Delete\" will result in the permanent deletion of your current wallet data. If you proceed, you\'ll need to import the wallet again to access your funds.'**
  String get deleteWallet01;

  /// No description provided for @deleteWalletSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings: Delete wallet'**
  String get deleteWalletSettings;

  /// No description provided for @deleteWalletSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your wallet data has been successfully deleted!'**
  String get deleteWalletSuccess;

  /// No description provided for @deleteWalletWarning.
  ///
  /// In en, this message translates to:
  /// **'Your wallet is about to be permanently deleted!'**
  String get deleteWalletWarning;

  /// No description provided for @disableStakeMessage.
  ///
  /// In en, this message translates to:
  /// **'The minimun amount to stake is 10,000 WIT'**
  String get disableStakeMessage;

  /// No description provided for @disableStakeTitle.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have enough balance to stake'**
  String get disableStakeTitle;

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get downloading;

  /// No description provided for @drSolved.
  ///
  /// In en, this message translates to:
  /// **'Data requests solved'**
  String get drSolved;

  /// No description provided for @emptyStakeMessage.
  ///
  /// In en, this message translates to:
  /// **'Stake some \$WIT! Secure the network, earn rewards, and be part of a censorship-resistant oracle.'**
  String get emptyStakeMessage;

  /// No description provided for @emptyStakeTitle.
  ///
  /// In en, this message translates to:
  /// **'You don´t have balance to unstake'**
  String get emptyStakeTitle;

  /// No description provided for @enableLoginWithBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Enable login with biometrics'**
  String get enableLoginWithBiometrics;

  /// No description provided for @encryptWallet01.
  ///
  /// In en, this message translates to:
  /// **'This password encrypts your Witnet wallet only on this computer.'**
  String get encryptWallet01;

  /// No description provided for @encryptWallet02.
  ///
  /// In en, this message translates to:
  /// **'This is not your backup and you cannot restore your wallet with this password.'**
  String get encryptWallet02;

  /// No description provided for @encryptWallet03.
  ///
  /// In en, this message translates to:
  /// **'Your {mnemonicLength} word seed phrase is still your ultimate recovery method.'**
  String encryptWallet03(int mnemonicLength);

  /// No description provided for @encryptWallet04.
  ///
  /// In en, this message translates to:
  /// **'Your Xprv is still your ultimate recovery method.'**
  String get encryptWallet04;

  /// No description provided for @encryptWalletHeader.
  ///
  /// In en, this message translates to:
  /// **'Encrypt your wallet'**
  String get encryptWalletHeader;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your Password'**
  String get enterYourPassword;

  /// No description provided for @epoch.
  ///
  /// In en, this message translates to:
  /// **'Epoch'**
  String get epoch;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @errorDeletingWallet.
  ///
  /// In en, this message translates to:
  /// **'There was an error deleting the wallet, please try again!'**
  String get errorDeletingWallet;

  /// No description provided for @errorFieldBlank.
  ///
  /// In en, this message translates to:
  /// **'Field is blank'**
  String get errorFieldBlank;

  /// No description provided for @errorReestablish.
  ///
  /// In en, this message translates to:
  /// **'There was an error re-establishing myWitWallet, please try again!'**
  String get errorReestablish;

  /// No description provided for @errorSigning.
  ///
  /// In en, this message translates to:
  /// **'Error signing message'**
  String get errorSigning;

  /// No description provided for @errorTransaction.
  ///
  /// In en, this message translates to:
  /// **'Error sending the transaction, try again!'**
  String get errorTransaction;

  /// No description provided for @errorTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Error. Try Again.'**
  String get errorTryAgain;

  /// No description provided for @errorXprvStart.
  ///
  /// In en, this message translates to:
  /// **'needs to start with \"xprv1\"'**
  String get errorXprvStart;

  /// No description provided for @estimatedFeeOptions.
  ///
  /// In en, this message translates to:
  /// **'{feeOption, select, stinky{Stinky} low{Low} medium{Medium} high{High} opulent{Opulent} custom{Custom} other{}}'**
  String estimatedFeeOptions(String feeOption);

  /// No description provided for @exploredAddresses.
  ///
  /// In en, this message translates to:
  /// **'Explored addresses'**
  String get exploredAddresses;

  /// No description provided for @exploringAddress.
  ///
  /// In en, this message translates to:
  /// **'Exploring address: '**
  String get exploringAddress;

  /// No description provided for @exportJson.
  ///
  /// In en, this message translates to:
  /// **'Export JSON'**
  String get exportJson;

  /// No description provided for @exportXprv.
  ///
  /// In en, this message translates to:
  /// **'Export Xprv'**
  String get exportXprv;

  /// No description provided for @fee.
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get fee;

  /// No description provided for @feesAndRewards.
  ///
  /// In en, this message translates to:
  /// **'Fees and rewards'**
  String get feesAndRewards;

  /// No description provided for @feesCollected.
  ///
  /// In en, this message translates to:
  /// **'Fees collected'**
  String get feesCollected;

  /// No description provided for @feesPayed.
  ///
  /// In en, this message translates to:
  /// **'Fees payed'**
  String get feesPayed;

  /// No description provided for @feeTypeOptions.
  ///
  /// In en, this message translates to:
  /// **'{feeType, select, absolute{Absolute} weighted{Weighted} other{}}'**
  String feeTypeOptions(String feeType);

  /// No description provided for @forgetPassword.
  ///
  /// In en, this message translates to:
  /// **'Did you forget your password?, You can delete your wallet and configure a new one!'**
  String get forgetPassword;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @generateAddressWarning.
  ///
  /// In en, this message translates to:
  /// **'You are about to generate a new address'**
  String get generateAddressWarning;

  /// No description provided for @generateAddressWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'A new address will be generated and ready to be used. The main address displayed in the navigation will be updated to the new one.'**
  String get generateAddressWarningMessage;

  /// No description provided for @generatedAddress.
  ///
  /// In en, this message translates to:
  /// **'Generated address'**
  String get generatedAddress;

  /// No description provided for @generatedAddresses.
  ///
  /// In en, this message translates to:
  /// **'Generated addresses'**
  String get generatedAddresses;

  /// No description provided for @generateMnemonic01.
  ///
  /// In en, this message translates to:
  /// **'These {mnemonicLength} apparently random words are your secret recovery phrase. They will allow you to recover your Wit coins if you uninstall this app or forget your wallet lock password.'**
  String generateMnemonic01(int mnemonicLength);

  /// No description provided for @generateMnemonic02.
  ///
  /// In en, this message translates to:
  /// **'You must write down your secret recovery phrase on a piece of paper and store it somewhere safe. Do not store it in a file in your device or anywhere else electronically. If you lose your secret recovery phrase, you may permanently lose access to your wallet and your Wit coins.'**
  String get generateMnemonic02;

  /// No description provided for @generateMnemonic03.
  ///
  /// In en, this message translates to:
  /// **'You should never share your secret recovery phrase with anyone. If someone finds or sees your secret recovery phrase, they will have full access to your wallet and your Wit coins.'**
  String get generateMnemonic03;

  /// No description provided for @generateMnemonicHeader.
  ///
  /// In en, this message translates to:
  /// **'Write down your secret recovery phrase'**
  String get generateMnemonicHeader;

  /// No description provided for @generateXprv.
  ///
  /// In en, this message translates to:
  /// **'Generate Xprv'**
  String get generateXprv;

  /// No description provided for @genNewAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Generate new Address'**
  String get genNewAddressLabel;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Transactions list'**
  String get home;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'Hour'**
  String get hour;

  /// No description provided for @importMnemonic01.
  ///
  /// In en, this message translates to:
  /// **'Type your secret recovery phrase below. It looks like a list of 12 apparently random words.'**
  String get importMnemonic01;

  /// No description provided for @importMnemonicHeader.
  ///
  /// In en, this message translates to:
  /// **'Import wallet from secret recovery phrase'**
  String get importMnemonicHeader;

  /// No description provided for @importMnemonicLabel.
  ///
  /// In en, this message translates to:
  /// **'Import from secret recovery phrase'**
  String get importMnemonicLabel;

  /// No description provided for @importWalletHeader.
  ///
  /// In en, this message translates to:
  /// **''**
  String get importWalletHeader;

  /// No description provided for @importWalletLabel.
  ///
  /// In en, this message translates to:
  /// **'Import wallet'**
  String get importWalletLabel;

  /// No description provided for @importXprv01.
  ///
  /// In en, this message translates to:
  /// **'Xprv is a key exchange format that encodes and protects your wallet with a password. Xprv keys look like a long sequence of apparently random letters and numbers, preceded by \"xprv\".'**
  String get importXprv01;

  /// No description provided for @importXprv02.
  ///
  /// In en, this message translates to:
  /// **'To import your wallet from an Xprv key encrypted with a password, you need to type the key itself and its password below:'**
  String get importXprv02;

  /// No description provided for @importXprvHeader.
  ///
  /// In en, this message translates to:
  /// **'Import wallet from an Xprv key'**
  String get importXprvHeader;

  /// No description provided for @importXprvLabel.
  ///
  /// In en, this message translates to:
  /// **'Import from Xprv key'**
  String get importXprvLabel;

  /// No description provided for @initializingWallet.
  ///
  /// In en, this message translates to:
  /// **'Initializing Wallet.'**
  String get initializingWallet;

  /// No description provided for @inputAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Input an amount'**
  String get inputAmountHint;

  /// No description provided for @inputPasswordPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please, input your wallet\'s password.'**
  String get inputPasswordPrompt;

  /// No description provided for @inputs.
  ///
  /// In en, this message translates to:
  /// **'Inputs'**
  String get inputs;

  /// No description provided for @inputYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Input your password'**
  String get inputYourPassword;

  /// No description provided for @insufficientFunds.
  ///
  /// In en, this message translates to:
  /// **'Insufficient funds'**
  String get insufficientFunds;

  /// No description provided for @insufficientUtxosAvailable.
  ///
  /// In en, this message translates to:
  /// **'Wait untill the pending transactions are confirmed or try creating a transaction with a smaller amount.'**
  String get insufficientUtxosAvailable;

  /// No description provided for @internalBalance.
  ///
  /// In en, this message translates to:
  /// **'Internal balance'**
  String get internalBalance;

  /// No description provided for @internalBalanceHint.
  ///
  /// In en, this message translates to:
  /// **'The internal balance corresponds to the sum of all the change accounts available balance'**
  String get internalBalanceHint;

  /// No description provided for @invalidPassword.
  ///
  /// In en, this message translates to:
  /// **'Invalid Password'**
  String get invalidPassword;

  /// No description provided for @invalidXprv.
  ///
  /// In en, this message translates to:
  /// **'Invalid Xprv:'**
  String get invalidXprv;

  /// No description provided for @invalidXprvBlank.
  ///
  /// In en, this message translates to:
  /// **'Field is blank'**
  String get invalidXprvBlank;

  /// No description provided for @invalidXprvStart.
  ///
  /// In en, this message translates to:
  /// **'needs to start with \"xprv1\"'**
  String get invalidXprvStart;

  /// No description provided for @jsonCopied.
  ///
  /// In en, this message translates to:
  /// **'JSON copied!'**
  String get jsonCopied;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @launchUrlError.
  ///
  /// In en, this message translates to:
  /// **'Could not launch {error}'**
  String launchUrlError(String error);

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @lockWalletLabel.
  ///
  /// In en, this message translates to:
  /// **'Lock wallet'**
  String get lockWalletLabel;

  /// No description provided for @lockYourWallet.
  ///
  /// In en, this message translates to:
  /// **'Lock your wallet'**
  String get lockYourWallet;

  /// No description provided for @messageSigning.
  ///
  /// In en, this message translates to:
  /// **'Message Signing'**
  String get messageSigning;

  /// No description provided for @messageSigning01.
  ///
  /// In en, this message translates to:
  /// **'Prove the ownership of your address by adding your signature to a message.'**
  String get messageSigning01;

  /// No description provided for @messageToBeSigned.
  ///
  /// In en, this message translates to:
  /// **'Message to be signed'**
  String get messageToBeSigned;

  /// No description provided for @mined.
  ///
  /// In en, this message translates to:
  /// **'Mined'**
  String get mined;

  /// No description provided for @minerFeeHint.
  ///
  /// In en, this message translates to:
  /// **'By default, \'Absolute fee\' is selected.\nTo set a custom weighted fee, you need to select \'Weighted\'. \nThe Weighted fee is automatically calculated by the wallet considering the network congestion and transaction weight multiplied by the value selected as custom.'**
  String get minerFeeHint;

  /// No description provided for @minerFeeInputHint.
  ///
  /// In en, this message translates to:
  /// **'Input the miner fee'**
  String get minerFeeInputHint;

  /// No description provided for @mintTxn.
  ///
  /// In en, this message translates to:
  /// **'Mint'**
  String get mintTxn;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutes;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @networkContribution.
  ///
  /// In en, this message translates to:
  /// **'Network contribution'**
  String get networkContribution;

  /// No description provided for @newVersion.
  ///
  /// In en, this message translates to:
  /// **'New Version: {versionNumber}'**
  String newVersion(Object versionNumber);

  /// No description provided for @newVersionAvailable.
  ///
  /// In en, this message translates to:
  /// **'A new version of the app is available.'**
  String get newVersionAvailable;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have transactions yet!'**
  String get noTransactions;

  /// No description provided for @okLabel.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get okLabel;

  /// No description provided for @outputs.
  ///
  /// In en, this message translates to:
  /// **'Outputs'**
  String get outputs;

  /// No description provided for @passwordDescription.
  ///
  /// In en, this message translates to:
  /// **'This password encrypts your xprv file. You will be asked to type this password if you want to import this xprv as a backup.'**
  String get passwordDescription;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;

  /// No description provided for @preferenceTabs.
  ///
  /// In en, this message translates to:
  /// **'{selectedTab, select, general{General} wallet{Wallet} other{unused}}'**
  String preferenceTabs(String selectedTab);

  /// No description provided for @readCarefully.
  ///
  /// In en, this message translates to:
  /// **'Please, read carefully before continuing. Your attention is crucial!'**
  String get readCarefully;

  /// No description provided for @readyToInstall.
  ///
  /// In en, this message translates to:
  /// **'Ready to install'**
  String get readyToInstall;

  /// No description provided for @receive.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get receive;

  /// No description provided for @recipientAddress.
  ///
  /// In en, this message translates to:
  /// **'Recipient address'**
  String get recipientAddress;

  /// No description provided for @reestablish.
  ///
  /// In en, this message translates to:
  /// **'Re-establish'**
  String get reestablish;

  /// No description provided for @reestablishInstructions.
  ///
  /// In en, this message translates to:
  /// **'Clicking \"Continue\" will result in the permanent deletion of your current wallet data. If you proceed, you\'ll need to import an existing wallet to access your funds or create a new one.'**
  String get reestablishInstructions;

  /// No description provided for @reestablishSteps01.
  ///
  /// In en, this message translates to:
  /// **'Make sure you have stored your recovery seed phrase or Xprv.'**
  String get reestablishSteps01;

  /// No description provided for @reestablishSteps02.
  ///
  /// In en, this message translates to:
  /// **'Click \"Continue\" to delete your storage and import your wallet again.'**
  String get reestablishSteps02;

  /// No description provided for @reestablishSucess.
  ///
  /// In en, this message translates to:
  /// **'myWitWallet has been successfully re-established!'**
  String get reestablishSucess;

  /// No description provided for @reestablishWallet.
  ///
  /// In en, this message translates to:
  /// **'Re-establish wallet'**
  String get reestablishWallet;

  /// No description provided for @reestablishYourWallet.
  ///
  /// In en, this message translates to:
  /// **'Re-establish your wallet'**
  String get reestablishYourWallet;

  /// No description provided for @reverted.
  ///
  /// In en, this message translates to:
  /// **'Reverted'**
  String get reverted;

  /// No description provided for @scanAqrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan a QR code'**
  String get scanAqrCode;

  /// No description provided for @scanQrCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get scanQrCodeLabel;

  /// No description provided for @selectImportOptionHeader.
  ///
  /// In en, this message translates to:
  /// **'Import your wallet'**
  String get selectImportOptionHeader;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @sendReceiveTx.
  ///
  /// In en, this message translates to:
  /// **'Send or receive WIT'**
  String get sendReceiveTx;

  /// No description provided for @sendStakeTransaction.
  ///
  /// In en, this message translates to:
  /// **'Stake Transaction'**
  String get sendStakeTransaction;

  /// No description provided for @sendUnstakeTransaction.
  ///
  /// In en, this message translates to:
  /// **'Unstake Transaction'**
  String get sendUnstakeTransaction;

  /// No description provided for @sendValueTransferTransaction.
  ///
  /// In en, this message translates to:
  /// **'Value Transfer Transaction'**
  String get sendValueTransferTransaction;

  /// No description provided for @setTimelock.
  ///
  /// In en, this message translates to:
  /// **'Set Timelock'**
  String get setTimelock;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsMessageSigning.
  ///
  /// In en, this message translates to:
  /// **'Settings: Message Signing'**
  String get settingsMessageSigning;

  /// No description provided for @settingsWalletConfigHeader.
  ///
  /// In en, this message translates to:
  /// **'Settings: Export the Xprv key of my wallet'**
  String get settingsWalletConfigHeader;

  /// No description provided for @sheikah.
  ///
  /// In en, this message translates to:
  /// **'Sheikah'**
  String get sheikah;

  /// No description provided for @showBalanceDetails.
  ///
  /// In en, this message translates to:
  /// **'Show balance details'**
  String get showBalanceDetails;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @showWalletList.
  ///
  /// In en, this message translates to:
  /// **'Show wallet list'**
  String get showWalletList;

  /// No description provided for @signAndSend.
  ///
  /// In en, this message translates to:
  /// **'Sign and Send'**
  String get signAndSend;

  /// No description provided for @signMessage.
  ///
  /// In en, this message translates to:
  /// **'Sign Message'**
  String get signMessage;

  /// No description provided for @signMessageError.
  ///
  /// In en, this message translates to:
  /// **'Error signing message'**
  String get signMessageError;

  /// No description provided for @speedUp.
  ///
  /// In en, this message translates to:
  /// **'Speed up'**
  String get speedUp;

  /// No description provided for @speedUpTxTitle.
  ///
  /// In en, this message translates to:
  /// **'Speed up transaction'**
  String get speedUpTxTitle;

  /// No description provided for @stake.
  ///
  /// In en, this message translates to:
  /// **'Stake'**
  String get stake;

  /// No description provided for @staked.
  ///
  /// In en, this message translates to:
  /// **'Staked'**
  String get staked;

  /// No description provided for @stakeSteps.
  ///
  /// In en, this message translates to:
  /// **'{currentStepIndex, select, Transaction{Stake} MinerFee{Miner Fee} Review{Review} other{unused}}'**
  String stakeSteps(String currentStepIndex);

  /// No description provided for @stakeTxnSuccess.
  ///
  /// In en, this message translates to:
  /// **'Stake transaction succesfully sent!'**
  String get stakeTxnSuccess;

  /// No description provided for @stakeUnstake.
  ///
  /// In en, this message translates to:
  /// **'Stake or unstake WIT'**
  String get stakeUnstake;

  /// No description provided for @stakeWithdrawalAddressText.
  ///
  /// In en, this message translates to:
  /// **'This is the address to create Stake transactions. Make sure this address is authorized to stake.'**
  String get stakeWithdrawalAddressText;

  /// No description provided for @stakingAddressCopied.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal address copied!'**
  String get stakingAddressCopied;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @timelock.
  ///
  /// In en, this message translates to:
  /// **'Timelock'**
  String get timelock;

  /// No description provided for @timelockTooltip.
  ///
  /// In en, this message translates to:
  /// **'The recipient will not be able to spend the coins before this date and time.'**
  String get timelockTooltip;

  /// No description provided for @timePickerHintText.
  ///
  /// In en, this message translates to:
  /// **'Set Time'**
  String get timePickerHintText;

  /// No description provided for @timePickerInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid time'**
  String get timePickerInvalid;

  /// No description provided for @timestamp.
  ///
  /// In en, this message translates to:
  /// **'Timestamp'**
  String get timestamp;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @totalDataSynced.
  ///
  /// In en, this message translates to:
  /// **'Scan summary'**
  String get totalDataSynced;

  /// No description provided for @totalFeesPaid.
  ///
  /// In en, this message translates to:
  /// **'Total fees paid'**
  String get totalFeesPaid;

  /// No description provided for @totalMiningRewards.
  ///
  /// In en, this message translates to:
  /// **'Total mining rewards'**
  String get totalMiningRewards;

  /// No description provided for @transaction.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get transaction;

  /// No description provided for @transactionDetails.
  ///
  /// In en, this message translates to:
  /// **'Transaction details'**
  String get transactionDetails;

  /// No description provided for @transactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get transactionId;

  /// No description provided for @transactionsFound.
  ///
  /// In en, this message translates to:
  /// **'Transactions found'**
  String get transactionsFound;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again!'**
  String get tryAgain;

  /// No description provided for @txEmptyState.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have transactions yet!'**
  String get txEmptyState;

  /// No description provided for @txnCheckStatus.
  ///
  /// In en, this message translates to:
  /// **'Check the transaction status in the Witnet Block Explorer:'**
  String get txnCheckStatus;

  /// No description provided for @txnDetails.
  ///
  /// In en, this message translates to:
  /// **'Transaction details'**
  String get txnDetails;

  /// No description provided for @txnSending.
  ///
  /// In en, this message translates to:
  /// **'Sending transaction'**
  String get txnSending;

  /// No description provided for @txnSending01.
  ///
  /// In en, this message translates to:
  /// **'The transaction is being sent'**
  String get txnSending01;

  /// No description provided for @txnSigning.
  ///
  /// In en, this message translates to:
  /// **'Signing transaction'**
  String get txnSigning;

  /// No description provided for @txnSigning01.
  ///
  /// In en, this message translates to:
  /// **'The transaction is being signed'**
  String get txnSigning01;

  /// No description provided for @txnStatus.
  ///
  /// In en, this message translates to:
  /// **'{feeType, select, pending{pending} mined{mined} confirmed{confirmed} other{}}'**
  String txnStatus(String feeType);

  /// No description provided for @txnSuccess.
  ///
  /// In en, this message translates to:
  /// **'Transaction succesfully sent!'**
  String get txnSuccess;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @unlockWallet.
  ///
  /// In en, this message translates to:
  /// **'Unlock wallet'**
  String get unlockWallet;

  /// No description provided for @unstake.
  ///
  /// In en, this message translates to:
  /// **'Unstake'**
  String get unstake;

  /// No description provided for @unstakeSteps.
  ///
  /// In en, this message translates to:
  /// **'{currentStepIndex, select, Transaction{Unstake} MinerFee{Miner Fee} Review{Review} other{unused}}'**
  String unstakeSteps(String currentStepIndex);

  /// No description provided for @unstakeTxnSuccess.
  ///
  /// In en, this message translates to:
  /// **'Unstake transaction succesfully sent!'**
  String get unstakeTxnSuccess;

  /// No description provided for @unstakeWithdrawalAddressText.
  ///
  /// In en, this message translates to:
  /// **'This is the address used to create Stake transactions.'**
  String get unstakeWithdrawalAddressText;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updateAvailable;

  /// No description provided for @updateError.
  ///
  /// In en, this message translates to:
  /// **'There was an issue with the update. Please try again.'**
  String get updateError;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update now'**
  String get updateNow;

  /// No description provided for @updateToVersion.
  ///
  /// In en, this message translates to:
  /// **'Update to version {versionNumber}'**
  String updateToVersion(Object versionNumber);

  /// No description provided for @validationDecimals.
  ///
  /// In en, this message translates to:
  /// **'Only 9 decimal digits supported'**
  String get validationDecimals;

  /// No description provided for @validationEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get validationEmpty;

  /// No description provided for @validationEnoughFunds.
  ///
  /// In en, this message translates to:
  /// **'Not enough Funds'**
  String get validationEnoughFunds;

  /// No description provided for @validationInvalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Invalid amount'**
  String get validationInvalidAmount;

  /// No description provided for @validationMinFee.
  ///
  /// In en, this message translates to:
  /// **'Fee should be higher than'**
  String get validationMinFee;

  /// No description provided for @validationNoZero.
  ///
  /// In en, this message translates to:
  /// **'Amount cannot be zero'**
  String get validationNoZero;

  /// No description provided for @validator.
  ///
  /// In en, this message translates to:
  /// **'Validator'**
  String get validator;

  /// No description provided for @validatorDescription.
  ///
  /// In en, this message translates to:
  /// **'Validator address that authorized staking.'**
  String get validatorDescription;

  /// No description provided for @valueTransferTxn.
  ///
  /// In en, this message translates to:
  /// **'Value Transfer'**
  String get valueTransferTxn;

  /// No description provided for @verifyLabel.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyLabel;

  /// No description provided for @versionNumber.
  ///
  /// In en, this message translates to:
  /// **'Version {versionNumber}'**
  String versionNumber(String versionNumber);

  /// No description provided for @viewOnExplorer.
  ///
  /// In en, this message translates to:
  /// **'View on Block Explorer'**
  String get viewOnExplorer;

  /// No description provided for @vttException.
  ///
  /// In en, this message translates to:
  /// **'Error building the transaction'**
  String get vttException;

  /// No description provided for @vttSendSteps.
  ///
  /// In en, this message translates to:
  /// **'{currentStepIndex, select, Transaction{Transaction} MinerFee{Miner Fee} Review{Review} other{unused}}'**
  String vttSendSteps(String currentStepIndex);

  /// No description provided for @walletConfig01.
  ///
  /// In en, this message translates to:
  /// **'Your Xprv key allows you to export and back up your wallet at any point after creating it.'**
  String get walletConfig01;

  /// No description provided for @walletConfig02.
  ///
  /// In en, this message translates to:
  /// **'Privacy-wise, your Xprv key is equivalent to a secret recovery phrase. Do not share it with anyone, and never store it in a file in your device or anywhere else electronically.'**
  String get walletConfig02;

  /// No description provided for @walletConfig03.
  ///
  /// In en, this message translates to:
  /// **'Your Xprv key will be protected with the password below. When importing the Xprv on this or another app, you will be asked to type in that same password.'**
  String get walletConfig03;

  /// No description provided for @walletConfigHeader.
  ///
  /// In en, this message translates to:
  /// **'Export the Xprv key of my wallet'**
  String get walletConfigHeader;

  /// No description provided for @walletDetail01.
  ///
  /// In en, this message translates to:
  /// **'You can better keep track of your different wallets by giving each its own name and description.'**
  String get walletDetail01;

  /// No description provided for @walletDetail02.
  ///
  /// In en, this message translates to:
  /// **'Wallet names make it easy to quickly change from one wallet to another. Wallet descriptions can be more elaborate and rather describe the purpose of a wallet or any other metadata.'**
  String get walletDetail02;

  /// No description provided for @walletDetailHeader.
  ///
  /// In en, this message translates to:
  /// **'Identify your wallet'**
  String get walletDetailHeader;

  /// No description provided for @walletNameHint.
  ///
  /// In en, this message translates to:
  /// **'My first million Wits'**
  String get walletNameHint;

  /// No description provided for @walletSecurity01.
  ///
  /// In en, this message translates to:
  /// **'Please, read carefully before continuing.'**
  String get walletSecurity01;

  /// No description provided for @walletSecurity02.
  ///
  /// In en, this message translates to:
  /// **'A wallet is an app that keeps your credentials safe and lets you interface with the Witnet blockchain. It allows you to easily transfer and receive Wit.'**
  String get walletSecurity02;

  /// No description provided for @walletSecurity03.
  ///
  /// In en, this message translates to:
  /// **'You should never share your seed phrase with anyone. We at Witnet do not store your seed phrase and will never ask you to share it with us. If you lose your seed phrase, you will permanently lose access to your wallet and your funds.'**
  String get walletSecurity03;

  /// No description provided for @walletSecurity04.
  ///
  /// In en, this message translates to:
  /// **'If someone finds or sees your seed phrase, they will have access to your wallet and all of your funds.'**
  String get walletSecurity04;

  /// No description provided for @walletSecurity05.
  ///
  /// In en, this message translates to:
  /// **'We recommend storing your seed phrase on paper somewhere safe. Do not store it in a file on your computer or anywhere electronically.'**
  String get walletSecurity05;

  /// No description provided for @walletSecurity06.
  ///
  /// In en, this message translates to:
  /// **'By accepting these disclaimers, you commit to comply with the explained restrictions and digitally sign your conformance using your Witnet wallet.'**
  String get walletSecurity06;

  /// No description provided for @walletSecurityConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'I will be careful, I promise!'**
  String get walletSecurityConfirmLabel;

  /// No description provided for @walletSecurityHeader.
  ///
  /// In en, this message translates to:
  /// **'Wallet security'**
  String get walletSecurityHeader;

  /// No description provided for @walletTypeHDLabel.
  ///
  /// In en, this message translates to:
  /// **'HD Wallet'**
  String get walletTypeHDLabel;

  /// No description provided for @walletTypeNodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Node'**
  String get walletTypeNodeLabel;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @whatToDo.
  ///
  /// In en, this message translates to:
  /// **'What to do?'**
  String get whatToDo;

  /// No description provided for @withdrawer.
  ///
  /// In en, this message translates to:
  /// **'Withdrawer'**
  String get withdrawer;

  /// No description provided for @withdrawalAddress.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal address'**
  String get withdrawalAddress;

  /// No description provided for @xprvInputHint.
  ///
  /// In en, this message translates to:
  /// **'Your Xprv key (starts with xprv...)'**
  String get xprvInputHint;

  /// No description provided for @xprvOrigin.
  ///
  /// In en, this message translates to:
  /// **'Xprv Origin'**
  String get xprvOrigin;

  /// No description provided for @yourMessage.
  ///
  /// In en, this message translates to:
  /// **'Your message...'**
  String get yourMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
