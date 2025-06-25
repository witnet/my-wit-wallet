// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get address => 'Address';

  @override
  String get addressBalanceDescription => 'Received payments totalling';

  @override
  String get addressCopied => 'Address copied!';

  @override
  String get addressList => 'Address list';

  @override
  String get addTimelockLabel => 'Add Timelock (Optional)';

  @override
  String get advancedSettings => 'Advanced Settings';

  @override
  String get amount => 'Amount';

  @override
  String get authenticateWithBiometrics => 'Authenticate with biometrics';

  @override
  String get authorization => 'Node authorization';

  @override
  String get authorizationInputHint => 'Node authorization...';

  @override
  String get autorizationTooltip => 'Node authorization to stake';

  @override
  String get available => 'Available';

  @override
  String get backLabel => 'Back';

  @override
  String get balance => 'balance';

  @override
  String get balanceDetails => 'Balance details';

  @override
  String get biometricsLabel => 'Biometrics';

  @override
  String get blocksMined => 'Blocks mined';

  @override
  String get buildWallet01 =>
      'The different addresses in your wallet are being scanned for existing transactions and balance. This will normally take less than 1 minute.';

  @override
  String get buildWalletBalance => 'Balance';

  @override
  String get buildWalletHeader => 'Address discovery';

  @override
  String get cancel => 'Cancel';

  @override
  String get cancelAuthentication => 'Cancel authentication';

  @override
  String get carouselMsg01 =>
      'myWitWallet allows you to send and receive Wit immediately. Bye bye synchronization!';

  @override
  String get carouselMsg02 =>
      'myWitWallet uses state-of-the-art cryptography to store your Wit coins securely.';

  @override
  String get carouselMsg03 =>
      'myWitWallet is completely non-custodial. Your keys will never leave your device.';

  @override
  String get chooseMinerFee => 'Choose you desired miner fee';

  @override
  String get clearTimelockLabel => 'Clear Timelock';

  @override
  String get clickToInstall => 'Click to install';

  @override
  String get close => 'Close';

  @override
  String get confirm => 'Confirm';

  @override
  String get confirmed => 'Confirmed';

  @override
  String get confirmMnemonic01 =>
      'Type in your secret recovery phrase below exactly as shown before. This will ensure that you have written down your secret recovery phrase correctly.';

  @override
  String get confirmMnemonicHeader => 'Secret Recovery Phrase Confirmation';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get connectionIssue =>
      'myWitWallet is experiencing connection problems';

  @override
  String get connectionReestablished => 'Connection reestablished!';

  @override
  String get continueLabel => 'Continue';

  @override
  String get copyAddressConfirmed => 'Address copied!';

  @override
  String get copyAddressLabel => 'Copy selected address';

  @override
  String get copyAddressToClipboard => 'Copy address to clipboard';

  @override
  String get copyJson => 'Copy JSON';

  @override
  String get copyStakingAddress => 'Copy withdrawal address';

  @override
  String get copyXprvConfirmed => 'Xprv copied!';

  @override
  String get copyXprvLabel => 'Copy Xprv';

  @override
  String get createImportWallet01 =>
      'When you created your wallet, you probably wrote down the secret security phrase on a piece of paper. It looks like a list of 12 apparently random words.';

  @override
  String get createImportWallet02 =>
      'If you did not keep the secret security phrase, you can still export a password-protected Xprv key from the settings of your existing wallet.';

  @override
  String get createImportWalletHeader => 'Create or import your wallet';

  @override
  String get createNewWalletLabel => 'Create new wallet';

  @override
  String get createOrImportLabel => 'Create or import';

  @override
  String get createWalletLabel => 'Create wallet';

  @override
  String get cryptoException => 'Error building the wallet';

  @override
  String get currentAddress => 'Current address';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String dashboardViewSteps(String selectedIndex) {
    String _temp0 = intl.Intl.selectLogic(
      selectedIndex,
      {
        'transactions': 'Transactions',
        'stats': 'Stats',
        'other': 'unused',
      },
    );
    return '$_temp0';
  }

  @override
  String get dataRequestTxn => 'Data Request';

  @override
  String get datePickerFormatError => 'Invalid date format';

  @override
  String get datePickerHintText => 'Select date';

  @override
  String get datePickerInvalid => 'Invalid date';

  @override
  String get delete => 'Delete';

  @override
  String get deleteStorageWarning =>
      'Your storage is about to be permanently deleted!';

  @override
  String get deleteWallet => 'Delete wallet';

  @override
  String get deleteWallet01 =>
      'Clicking \"Delete\" will result in the permanent deletion of your current wallet data. If you proceed, you\'ll need to import the wallet again to access your funds.';

  @override
  String get deleteWalletSettings => 'Settings: Delete wallet';

  @override
  String get deleteWalletSuccess =>
      'Your wallet data has been successfully deleted!';

  @override
  String get deleteWalletWarning =>
      'Your wallet is about to be permanently deleted!';

  @override
  String get disableStakeMessage => 'The minimun amount to stake is 10,000 WIT';

  @override
  String get disableStakeTitle => 'You don\'t have enough balance to stake';

  @override
  String get downloading => 'Downloading...';

  @override
  String get drSolved => 'Data requests solved';

  @override
  String get emptyStakeMessage =>
      'Stake some \$WIT! Secure the network, earn rewards, and be part of a censorship-resistant oracle.';

  @override
  String get emptyStakeTitle => 'You don´t have balance to unstake';

  @override
  String get enableLoginWithBiometrics => 'Enable login with biometrics';

  @override
  String get encryptWallet01 =>
      'This password encrypts your Witnet wallet only on this computer.';

  @override
  String get encryptWallet02 =>
      'This is not your backup and you cannot restore your wallet with this password.';

  @override
  String encryptWallet03(int mnemonicLength) {
    return 'Your $mnemonicLength word seed phrase is still your ultimate recovery method.';
  }

  @override
  String get encryptWallet04 =>
      'Your Xprv is still your ultimate recovery method.';

  @override
  String get encryptWalletHeader => 'Encrypt your wallet';

  @override
  String get enterYourPassword => 'Enter your Password';

  @override
  String get epoch => 'Epoch';

  @override
  String get error => 'Error';

  @override
  String get errorDeletingWallet =>
      'There was an error deleting the wallet, please try again!';

  @override
  String get errorFieldBlank => 'Field is blank';

  @override
  String get errorReestablish =>
      'There was an error re-establishing myWitWallet, please try again!';

  @override
  String get errorSigning => 'Error signing message';

  @override
  String get errorTransaction => 'Error sending the transaction, try again!';

  @override
  String get errorTryAgain => 'Error. Try Again.';

  @override
  String get errorXprvStart => 'needs to start with \"xprv1\"';

  @override
  String estimatedFeeOptions(String feeOption) {
    String _temp0 = intl.Intl.selectLogic(
      feeOption,
      {
        'stinky': 'Stinky',
        'low': 'Low',
        'medium': 'Medium',
        'high': 'High',
        'opulent': 'Opulent',
        'custom': 'Custom',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String get exploredAddresses => 'Explored addresses';

  @override
  String get exploringAddress => 'Exploring address: ';

  @override
  String get exportJson => 'Export JSON';

  @override
  String get exportXprv => 'Export Xprv';

  @override
  String get fee => 'Fee';

  @override
  String get feesAndRewards => 'Fees and rewards';

  @override
  String get feesCollected => 'Fees collected';

  @override
  String get feesPayed => 'Fees payed';

  @override
  String feeTypeOptions(String feeType) {
    String _temp0 = intl.Intl.selectLogic(
      feeType,
      {
        'absolute': 'Absolute',
        'weighted': 'Weighted',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String get forgetPassword =>
      'Did you forget your password?, You can delete your wallet and configure a new one!';

  @override
  String get from => 'From';

  @override
  String get generateAddressWarning =>
      'You are about to generate a new address';

  @override
  String get generateAddressWarningMessage =>
      'A new address will be generated and ready to be used. The main address displayed in the navigation will be updated to the new one.';

  @override
  String get generatedAddress => 'Generated address';

  @override
  String get generatedAddresses => 'Generated addresses';

  @override
  String generateMnemonic01(int mnemonicLength) {
    return 'These $mnemonicLength apparently random words are your secret recovery phrase. They will allow you to recover your Wit coins if you uninstall this app or forget your wallet lock password.';
  }

  @override
  String get generateMnemonic02 =>
      'You must write down your secret recovery phrase on a piece of paper and store it somewhere safe. Do not store it in a file in your device or anywhere else electronically. If you lose your secret recovery phrase, you may permanently lose access to your wallet and your Wit coins.';

  @override
  String get generateMnemonic03 =>
      'You should never share your secret recovery phrase with anyone. If someone finds or sees your secret recovery phrase, they will have full access to your wallet and your Wit coins.';

  @override
  String get generateMnemonicHeader => 'Write down your secret recovery phrase';

  @override
  String get generateXprv => 'Generate Xprv';

  @override
  String get genNewAddressLabel => 'Generate new Address';

  @override
  String get history => 'History';

  @override
  String get home => 'Transactions list';

  @override
  String get hour => 'Hour';

  @override
  String get importMnemonic01 =>
      'Type your secret recovery phrase below. It looks like a list of 12 apparently random words.';

  @override
  String get importMnemonicHeader =>
      'Import wallet from secret recovery phrase';

  @override
  String get importMnemonicLabel => 'Import from secret recovery phrase';

  @override
  String get importWalletHeader => '';

  @override
  String get importWalletLabel => 'Import wallet';

  @override
  String get importXprv01 =>
      'Xprv is a key exchange format that encodes and protects your wallet with a password. Xprv keys look like a long sequence of apparently random letters and numbers, preceded by \"xprv\".';

  @override
  String get importXprv02 =>
      'To import your wallet from an Xprv key encrypted with a password, you need to type the key itself and its password below:';

  @override
  String get importXprvHeader => 'Import wallet from an Xprv key';

  @override
  String get importXprvLabel => 'Import from Xprv key';

  @override
  String get initializingWallet => 'Initializing Wallet.';

  @override
  String get inputAmountHint => 'Input an amount';

  @override
  String get inputPasswordPrompt => 'Please, input your wallet\'s password.';

  @override
  String get inputs => 'Inputs';

  @override
  String get inputYourPassword => 'Input your password';

  @override
  String get insufficientFunds => 'Insufficient funds';

  @override
  String get insufficientUtxosAvailable =>
      'Wait untill the pending transactions are confirmed or try creating a transaction with a smaller amount.';

  @override
  String get internalBalance => 'Internal balance';

  @override
  String get internalBalanceHint =>
      'The internal balance corresponds to the sum of all the change accounts available balance';

  @override
  String get invalidPassword => 'Invalid Password';

  @override
  String get invalidXprv => 'Invalid Xprv:';

  @override
  String get invalidXprvBlank => 'Field is blank';

  @override
  String get invalidXprvStart => 'needs to start with \"xprv1\"';

  @override
  String get jsonCopied => 'JSON copied!';

  @override
  String get later => 'Later';

  @override
  String launchUrlError(String error) {
    return 'Could not launch $error';
  }

  @override
  String get lightMode => 'Light Mode';

  @override
  String get loading => 'Loading';

  @override
  String get locked => 'Locked';

  @override
  String get lockWalletLabel => 'Lock wallet';

  @override
  String get lockYourWallet => 'Lock your wallet';

  @override
  String get messageSigning => 'Message Signing';

  @override
  String get messageSigning01 =>
      'Prove the ownership of your address by adding your signature to a message.';

  @override
  String get messageToBeSigned => 'Message to be signed';

  @override
  String get mined => 'Mined';

  @override
  String get minerFeeHint =>
      'By default, \'Absolute fee\' is selected.\nTo set a custom weighted fee, you need to select \'Weighted\'. \nThe Weighted fee is automatically calculated by the wallet considering the network congestion and transaction weight multiplied by the value selected as custom.';

  @override
  String get minerFeeInputHint => 'Input the miner fee';

  @override
  String get mintTxn => 'Mint';

  @override
  String get minutes => 'Minutes';

  @override
  String get nameLabel => 'Name';

  @override
  String get networkContribution => 'Network contribution';

  @override
  String newVersion(Object versionNumber) {
    return 'New Version: $versionNumber';
  }

  @override
  String get newVersionAvailable => 'A new version of the app is available.';

  @override
  String get noTransactions => 'You don\'t have transactions yet!';

  @override
  String get okLabel => 'Ok';

  @override
  String get outputs => 'Outputs';

  @override
  String get passwordDescription =>
      'This password encrypts your xprv file. You will be asked to type this password if you want to import this xprv as a backup.';

  @override
  String get passwordLabel => 'Password';

  @override
  String get pending => 'Pending';

  @override
  String get pleaseWait => 'Please wait...';

  @override
  String preferenceTabs(String selectedTab) {
    String _temp0 = intl.Intl.selectLogic(
      selectedTab,
      {
        'general': 'General',
        'wallet': 'Wallet',
        'other': 'unused',
      },
    );
    return '$_temp0';
  }

  @override
  String get readCarefully =>
      'Please, read carefully before continuing. Your attention is crucial!';

  @override
  String get readyToInstall => 'Ready to install';

  @override
  String get receive => 'Receive';

  @override
  String get recipientAddress => 'Recipient address';

  @override
  String get reestablish => 'Re-establish';

  @override
  String get reestablishInstructions =>
      'Clicking \"Continue\" will result in the permanent deletion of your current wallet data. If you proceed, you\'ll need to import an existing wallet to access your funds or create a new one.';

  @override
  String get reestablishSteps01 =>
      'Make sure you have stored your recovery seed phrase or Xprv.';

  @override
  String get reestablishSteps02 =>
      'Click \"Continue\" to delete your storage and import your wallet again.';

  @override
  String get reestablishSucess =>
      'myWitWallet has been successfully re-established!';

  @override
  String get reestablishWallet => 'Re-establish wallet';

  @override
  String get reestablishYourWallet => 'Re-establish your wallet';

  @override
  String get reverted => 'Reverted';

  @override
  String get scanAqrCode => 'Scan a QR code';

  @override
  String get scanQrCodeLabel => 'Scan QR code';

  @override
  String get selectImportOptionHeader => 'Import your wallet';

  @override
  String get send => 'Send';

  @override
  String get sendReceiveTx => 'Send or receive WIT';

  @override
  String get sendStakeTransaction => 'Stake Transaction';

  @override
  String get sendUnstakeTransaction => 'Unstake Transaction';

  @override
  String get sendValueTransferTransaction => 'Value Transfer Transaction';

  @override
  String get setTimelock => 'Set Timelock';

  @override
  String get settings => 'Settings';

  @override
  String get settingsMessageSigning => 'Settings: Message Signing';

  @override
  String get settingsWalletConfigHeader =>
      'Settings: Export the Xprv key of my wallet';

  @override
  String get sheikah => 'Sheikah';

  @override
  String get showBalanceDetails => 'Show balance details';

  @override
  String get showPassword => 'Show password';

  @override
  String get showWalletList => 'Show wallet list';

  @override
  String get signAndSend => 'Sign and Send';

  @override
  String get signMessage => 'Sign Message';

  @override
  String get signMessageError => 'Error signing message';

  @override
  String get speedUp => 'Speed up';

  @override
  String get speedUpTxTitle => 'Speed up transaction';

  @override
  String get stake => 'Stake';

  @override
  String get staked => 'Staked';

  @override
  String stakeSteps(String currentStepIndex) {
    String _temp0 = intl.Intl.selectLogic(
      currentStepIndex,
      {
        'Transaction': 'Stake',
        'MinerFee': 'Miner Fee',
        'Review': 'Review',
        'other': 'unused',
      },
    );
    return '$_temp0';
  }

  @override
  String get stakeTxnSuccess => 'Stake transaction succesfully sent!';

  @override
  String get stakeUnstake => 'Stake or unstake WIT';

  @override
  String get stakeWithdrawalAddressText =>
      'This is the address to create Stake transactions. Make sure this address is authorized to stake.';

  @override
  String get stakingAddressCopied => 'Withdrawal address copied!';

  @override
  String get status => 'Status';

  @override
  String get theme => 'Theme';

  @override
  String get timelock => 'Timelock';

  @override
  String get timelockTooltip =>
      'The recipient will not be able to spend the coins before this date and time.';

  @override
  String get timePickerHintText => 'Set Time';

  @override
  String get timePickerInvalid => 'Invalid time';

  @override
  String get timestamp => 'Timestamp';

  @override
  String get to => 'To';

  @override
  String get total => 'Total';

  @override
  String get totalDataSynced => 'Scan summary';

  @override
  String get totalFeesPaid => 'Total fees paid';

  @override
  String get totalMiningRewards => 'Total mining rewards';

  @override
  String get transaction => 'Transaction';

  @override
  String get transactionDetails => 'Transaction details';

  @override
  String get transactionId => 'Transaction ID';

  @override
  String get transactionsFound => 'Transactions found';

  @override
  String get tryAgain => 'Try again!';

  @override
  String get txEmptyState => 'You don\'t have transactions yet!';

  @override
  String get txnCheckStatus =>
      'Check the transaction status in the Witnet Block Explorer:';

  @override
  String get txnDetails => 'Transaction details';

  @override
  String get txnSending => 'Sending transaction';

  @override
  String get txnSending01 => 'The transaction is being sent';

  @override
  String get txnSigning => 'Signing transaction';

  @override
  String get txnSigning01 => 'The transaction is being signed';

  @override
  String txnStatus(String feeType) {
    String _temp0 = intl.Intl.selectLogic(
      feeType,
      {
        'pending': 'pending',
        'mined': 'mined',
        'confirmed': 'confirmed',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String get txnSuccess => 'Transaction succesfully sent!';

  @override
  String get type => 'Type';

  @override
  String get unlockWallet => 'Unlock wallet';

  @override
  String get unstake => 'Unstake';

  @override
  String unstakeSteps(String currentStepIndex) {
    String _temp0 = intl.Intl.selectLogic(
      currentStepIndex,
      {
        'Transaction': 'Unstake',
        'MinerFee': 'Miner Fee',
        'Review': 'Review',
        'other': 'unused',
      },
    );
    return '$_temp0';
  }

  @override
  String get unstakeTxnSuccess => 'Unstake transaction succesfully sent!';

  @override
  String get unstakeWithdrawalAddressText =>
      'This is the address used to create Stake transactions.';

  @override
  String get updateAvailable => 'Update available';

  @override
  String get updateError =>
      'There was an issue with the update. Please try again.';

  @override
  String get updateNow => 'Update now';

  @override
  String updateToVersion(Object versionNumber) {
    return 'Update to version $versionNumber';
  }

  @override
  String get validationDecimals => 'Only 9 decimal digits supported';

  @override
  String get validationEmpty => 'Please enter an amount';

  @override
  String get validationEnoughFunds => 'Not enough Funds';

  @override
  String get validationInvalidAmount => 'Invalid amount';

  @override
  String get validationMinFee => 'Fee should be higher than';

  @override
  String get validationNoZero => 'Amount cannot be zero';

  @override
  String get validator => 'Validator';

  @override
  String get validatorDescription =>
      'Validator address that authorized staking.';

  @override
  String get valueTransferTxn => 'Value Transfer';

  @override
  String get verifyLabel => 'Verify';

  @override
  String versionNumber(String versionNumber) {
    return 'Version $versionNumber';
  }

  @override
  String get viewOnExplorer => 'View on Block Explorer';

  @override
  String get vttException => 'Error building the transaction';

  @override
  String vttSendSteps(String currentStepIndex) {
    String _temp0 = intl.Intl.selectLogic(
      currentStepIndex,
      {
        'Transaction': 'Transaction',
        'MinerFee': 'Miner Fee',
        'Review': 'Review',
        'other': 'unused',
      },
    );
    return '$_temp0';
  }

  @override
  String get walletConfig01 =>
      'Your Xprv key allows you to export and back up your wallet at any point after creating it.';

  @override
  String get walletConfig02 =>
      'Privacy-wise, your Xprv key is equivalent to a secret recovery phrase. Do not share it with anyone, and never store it in a file in your device or anywhere else electronically.';

  @override
  String get walletConfig03 =>
      'Your Xprv key will be protected with the password below. When importing the Xprv on this or another app, you will be asked to type in that same password.';

  @override
  String get walletConfigHeader => 'Export the Xprv key of my wallet';

  @override
  String get walletDetail01 =>
      'You can better keep track of your different wallets by giving each its own name and description.';

  @override
  String get walletDetail02 =>
      'Wallet names make it easy to quickly change from one wallet to another. Wallet descriptions can be more elaborate and rather describe the purpose of a wallet or any other metadata.';

  @override
  String get walletDetailHeader => 'Identify your wallet';

  @override
  String get walletNameHint => 'My first million Wits';

  @override
  String get walletSecurity01 => 'Please, read carefully before continuing.';

  @override
  String get walletSecurity02 =>
      'A wallet is an app that keeps your credentials safe and lets you interface with the Witnet blockchain. It allows you to easily transfer and receive Wit.';

  @override
  String get walletSecurity03 =>
      'You should never share your seed phrase with anyone. We at Witnet do not store your seed phrase and will never ask you to share it with us. If you lose your seed phrase, you will permanently lose access to your wallet and your funds.';

  @override
  String get walletSecurity04 =>
      'If someone finds or sees your seed phrase, they will have access to your wallet and all of your funds.';

  @override
  String get walletSecurity05 =>
      'We recommend storing your seed phrase on paper somewhere safe. Do not store it in a file on your computer or anywhere electronically.';

  @override
  String get walletSecurity06 =>
      'By accepting these disclaimers, you commit to comply with the explained restrictions and digitally sign your conformance using your Witnet wallet.';

  @override
  String get walletSecurityConfirmLabel => 'I will be careful, I promise!';

  @override
  String get walletSecurityHeader => 'Wallet security';

  @override
  String get walletTypeHDLabel => 'HD Wallet';

  @override
  String get walletTypeNodeLabel => 'Node';

  @override
  String get welcome => 'Welcome';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get whatToDo => 'What to do?';

  @override
  String get withdrawer => 'Withdrawer';

  @override
  String get withdrawalAddress => 'Withdrawal address';

  @override
  String get xprvInputHint => 'Your Xprv key (starts with xprv...)';

  @override
  String get xprvOrigin => 'Xprv Origin';

  @override
  String get yourMessage => 'Your message...';
}
