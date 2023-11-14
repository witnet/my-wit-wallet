import 'package:fixnum/fixnum.dart';
import 'package:my_wit_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:my_wit_wallet/util/extensions/utxo_list_extenstions.dart';
import 'package:my_wit_wallet/util/extensions/vto_list_extensions.dart';
import 'package:witnet/constants.dart';
import 'package:witnet/data_structures.dart';
import 'package:witnet/explorer.dart';
import 'package:witnet/schema.dart';
import 'package:witnet/utils.dart';
import 'package:my_wit_wallet/bloc/crypto/api_crypto.dart';
import 'package:my_wit_wallet/bloc/explorer/api_explorer.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/util/filter_utxos.dart';
import 'package:my_wit_wallet/util/get_utxos_match_inputs.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/util/storage/database/transaction_adapter.dart';

class BuildVttInputsParams {
  final GeneralTransaction? speedUpTx;
  final int txValueNanoWit;
  BuildVttInputsParams({this.speedUpTx, required this.txValueNanoWit});
}

class VttBuilder {
  VttBuilder();

  final Map<String, Account> utxoAccountMap = {};

  Wallet get wallet =>
      Locator.instance<ApiDatabase>().walletStorage.currentWallet;
  ApiDatabase get database => Locator.instance.get<ApiDatabase>();
  List<Utxo> selectedUtxos = [];
  UtxoPool utxoPool = UtxoPool();

  List<Utxo> get utxoList => utxoPool.map.values.toList();
  Account? changeAccount;
  num balanceNanoWit = 0;
  DateTime? selectedTimelock;
  bool timelockSet = false;
  UtxoSelectionStrategy utxoSelectionStrategy =
      UtxoSelectionStrategy.SmallFirst;
  PrioritiesEstimate? prioritiesEstimate;
  EstimatedFeeOptions feeOption = EstimatedFeeOptions.Medium;
  Map<EstimatedFeeOptions, String?> minerFeeOptions = DEFAULT_MINER_FEE_OPTIONS;
  GeneralTransaction? speedUpTx;
  List<Input> inputs = [];
  List<ValueTransferOutput> outputs = [];
  bool isPrioritiesLoading = false;
  List<KeyedSignature> signatures = [];

  /// fee
  FeeType feeType = FeeType.Weighted;
  int feeNanoWit = 0;

  int getFee([int additionalOutputs = 0]) {
    switch (feeType) {
      case FeeType.Absolute:
        return feeNanoWit;
      case FeeType.Weighted:
        return calculatedWeightedFee(feeNanoWit);
    }
  }

  VTTransactionBody get body =>
      VTTransactionBody(inputs: inputs, outputs: outputs);

  VTTransaction get vtt => VTTransaction(body: body, signatures: signatures);

  void setTimeLock(DateTime dateTime) {
    selectedTimelock = dateTime;
    timelockSet = true;
  }

  Future<void> initializeTransaction() async {
    balanceNanoWit = wallet.balanceNanoWit().availableNanoWit;
    changeAccount = await wallet.getChangeAccount();
    // update the utxo pool
    utxoPool.clear();
    this.wallet.utxoMap(false).keys.forEach((utxo) {
      utxoPool.insert(utxo);
    });

    // presort the utxo pool
    utxoPool.sortUtxos(utxoSelectionStrategy);
  }

  void reset() {
    selectedUtxos.clear();
    inputs.clear();
    outputs.clear();
    signatures.clear();
    selectedTimelock = null;
    speedUpTx = null;
    timelockSet = false;
    feeNanoWit = 1;
    feeOption = EstimatedFeeOptions.Medium;
  }

  bool addOutput(AddValueTransferOutputEvent event) {
    ValueTransferOutput output = event.output;
    try {
      if (event.merge) {
        // check to see if the address is already in the list.
        if (outputs.containsAddress(output.pkh.address)) {
          // if the address is in the list add the value instead of
          // generating a new output
          outputs.byAddress(output.pkh.address).value += output.value;
          if (selectedTimelock != null) {
            outputs.byAddress(output.pkh.address).timeLock =
                (selectedTimelock!.millisecondsSinceEpoch * 100) as Int64;
          }
        } else {
          outputs.add(output);
        }
      } else {
        // if merge is false then add an additional output.
        outputs.add(output);
      }

      buildTransactionBody(speedUpTx: speedUpTx);
      setEstimatedWeightedFees();

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Retrieves and sets the [prioritiesEstimate] from the Explorer.
  Future<String?> setPrioritiesEstimate() async {
    String? exception;
    try {
      prioritiesEstimate = await Locator.instance.get<ApiExplorer>().priority();
    } catch (e) {
      exception = 'Error getting priority estimations $e';
    }
    return exception ?? null;
  }

  void setSelectionStrategy(UtxoSelectionStrategy strategy) {
    utxoSelectionStrategy = strategy;
  }

  int calculatedWeightedFee(num multiplier, {int additionalOutputs = 0}) {
    num txWeight = (inputs.length * INPUT_SIZE) +
        (outputs.length + additionalOutputs * OUTPUT_SIZE * GAMMA);
    return (txWeight * multiplier).round();
  }

  bool validVTTransactionWeight(VTTransaction transaction) {
    return transaction.weight < MAX_VT_WEIGHT;
  }

  void setEstimatedWeightedFees() {
    if (prioritiesEstimate != null) {
      minerFeeOptions[EstimatedFeeOptions.Stinky] =
          calculatedWeightedFee(prioritiesEstimate!.vttStinky.priority)
              .toString();
      minerFeeOptions[EstimatedFeeOptions.Low] =
          calculatedWeightedFee(prioritiesEstimate!.vttLow.priority).toString();
      minerFeeOptions[EstimatedFeeOptions.Medium] =
          calculatedWeightedFee(prioritiesEstimate!.vttMedium.priority)
              .toString();
      minerFeeOptions[EstimatedFeeOptions.High] =
          calculatedWeightedFee(prioritiesEstimate!.vttHigh.priority)
              .toString();
      minerFeeOptions[EstimatedFeeOptions.Opulent] =
          calculatedWeightedFee(prioritiesEstimate!.vttOpulent.priority)
              .toString();
    }
  }

  void updateFee(UpdateFeeEvent event) {
    feeType = event.feeType;
    feeOption = event.feeOption;
    switch (feeType) {
      case FeeType.Absolute:
        this.feeNanoWit = event.feeNanoWit ?? 1;
        break;
      case FeeType.Weighted:
        this.feeNanoWit = event.feeNanoWit ?? 1;
        break;
    }
  }

  List<Utxo> _setSelectedUtxos(BuildVttInputsParams params) {
    selectedUtxos = [];
    List<Utxo> filteredUtxos = filterUsedUtxos(
        utxoList: utxoList, pendingVtts: wallet.pendingTransactions());
    UtxoPool filteredUtxoPool = UtxoPool();
    // Update the utxo pool
    filteredUtxoPool.clear();
    filteredUtxos.forEach((utxo) {
      filteredUtxoPool.insert(utxo);
    });
    speedUpTx = params.speedUpTx;
    if (speedUpTx != null && speedUpTx?.vtt != null) {
      // Calculate remain value to cover
      int rest = params.txValueNanoWit;
      speedUpTx!.vtt!.inputs.forEach((e) => rest -= e.value);

      // Get used utxos from speedUpTx inputs
      List<Utxo> usedUtxos = getUtxosMatchInputs(
          utxoList: utxoList, inputs: speedUpTx!.vtt!.inputs);

      if (rest > 0) {
        selectedUtxos = [
          ...usedUtxos,
          ...filteredUtxoPool.cover(
              amountNanoWit: rest, utxoStrategy: utxoSelectionStrategy)
        ];
      } else {
        selectedUtxos = usedUtxos;
      }
    } else {
      selectedUtxos = filteredUtxoPool.cover(
          amountNanoWit: params.txValueNanoWit,
          utxoStrategy: utxoSelectionStrategy);
    }
    return selectedUtxos;
  }

  void buildTransactionBody({GeneralTransaction? speedUpTx}) {
    int valueOwedNanoWit = 0;
    int valuePaidNanoWit = 0;
    int valueChangeNanoWit = 0;
    try {
      /// calculate value owed

      if (outputs.containsAddress(changeAccount!.address) && wallet.isHd) {
        outputs.removeAddress(changeAccount!.address);
      }

      valueOwedNanoWit = outputs.valueNanoWit();

      /// sets the fee weighted and absolute
      feeNanoWit = getFee();
      valueOwedNanoWit += feeNanoWit;

      /// compare to balance
      if (balanceNanoWit < valueOwedNanoWit) {
        /// TODO:: throw insufficient funds exception
      } else {
        /// get utxos from the pool
        _setSelectedUtxos(BuildVttInputsParams(
            txValueNanoWit: valueOwedNanoWit, speedUpTx: speedUpTx));

        /// convert utxo to input
        inputs.clear();
        for (int i = 0; i < selectedUtxos.length; i++) {
          Utxo currentUtxo = selectedUtxos[i];
          Input _input = currentUtxo.toInput();
          inputs.add(_input);
          valuePaidNanoWit += currentUtxo.value;
        }
      }

      if (feeType == FeeType.Weighted) {
        /// calculate change
        valueChangeNanoWit = (valuePaidNanoWit - valueOwedNanoWit);

        ///
        if (valueChangeNanoWit > 0) {
          // add change
          // +1 to the outputs length to include for change address
          feeNanoWit = getFee(feeNanoWit);
          valueChangeNanoWit = (valuePaidNanoWit - valueOwedNanoWit);

          outputs.add(ValueTransferOutput.fromJson({
            'pkh': changeAccount?.address,
            'value': valueChangeNanoWit,
            'time_lock': 0,
          }));
        }
      } else {
        feeNanoWit = getFee();
        valueChangeNanoWit = (valuePaidNanoWit - valueOwedNanoWit);
        if (valueChangeNanoWit > 0) {
          outputs.add(ValueTransferOutput.fromJson({
            'pkh': changeAccount?.address,
            'value': valueChangeNanoWit,
            'time_lock': 0,
          }));
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  String? validateAmount() {
    int utxoValueNanoWit = selectedUtxos.valueNanoWit();
    int outputValueNanoWit = outputs.valueNanoWit();

    if (utxoValueNanoWit <= (outputValueNanoWit + feeNanoWit)) {}
    if (utxoPool.map.values.toList().valueNanoWit() <=
        (outputValueNanoWit + feeNanoWit)) {
      return "Insufficient Funds";
    }
    return null;
  }

  ValueTransferInfo toValueTransferInfo(VTTransaction transaction,
      [String? status]) {
    return ValueTransferInfo(
        blockHash: '',
        fee: feeNanoWit,
        inputs: wallet.inputUtxos(selectedUtxos),
        outputs: outputs,
        priority: 1,
        status: status ?? 'pending',
        txnEpoch: -1,
        txnHash: transaction.transactionID,
        txnTime: DateTime.now().millisecondsSinceEpoch,
        type: 'ValueTransfer',
        weight: transaction.weight);
  }

  /// sign the [VTTransaction]
  Future<VTTransaction> sign() async {
    // Read the encrypted XPRV string stored in the database
    ApiCrypto apiCrypto = Locator.instance<ApiCrypto>();
    try {
      buildTransactionBody(speedUpTx: speedUpTx);
      signatures = await apiCrypto.signTransaction(
        selectedUtxos,
        wallet,
        bytesToHex(VTTransactionBody(inputs: inputs, outputs: outputs).hash),
      );
      var tx = VTTransaction(
          body: VTTransactionBody(inputs: inputs, outputs: outputs),
          signatures: signatures);
      return VTTransaction(
          body: VTTransactionBody(inputs: inputs, outputs: outputs),
          signatures: signatures);
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> send(SendTransactionEvent event) async {
    String? error;
    try {
      var resp = await Locator.instance
          .get<ApiExplorer>()
          .sendTransaction(Transaction(valueTransfer: vtt));
      if (resp['result'] == true) error = null;
      if (speedUpTx != null) {
        await deleteVtt(speedUpTx!.toValueTransferInfo());
      }
    } catch (e) {
      error = 'Error sending transaction: $e';
    }
    return error ?? null;
  }

  /// Build a list of accounts
  List<Account> accountsToUpdate(VTTransaction transaction) {
    ApiDatabase database = Locator.instance.get<ApiDatabase>();
    List<InputUtxo> _inputUtxoList = wallet.inputUtxos(selectedUtxos);
    ValueTransferInfo _vti = toValueTransferInfo(transaction);

    List<Account> _accounts = [];

    // the inputs
    for (int i = 0; i < _inputUtxoList.length; i++) {
      InputUtxo inputUtxo = _inputUtxoList[i];

      // get the account by address
      Account account = database.walletStorage.currentWallet
          .accountByAddress(inputUtxo.address)!;

      // add the vtt to the account
      account.addVtt(_vti);

      // we need to remove the UTXO from the account
      account.utxos.removeWhere((utxo) =>
          utxo.outputPointer.toString() ==
          inputUtxo.input.outputPointer.toString());

      // add the account to the list we need to update
      _accounts.add(account);
    }

    // check outputs for accounts and update them
    for (int i = 0; i < outputs.length; i++) {
      ValueTransferOutput output = outputs[i];
      Account? account = Account.fromDatabase(database, output.pkh.address);
      if (account != null) {
        account.addVtt(_vti);
        _accounts.add(account);
      }
    }

    return _accounts;
  }

  /// Updates the database with all the data from the [vtt].
  Future<void> updateDatabase() async {
    ApiDatabase database = Locator.instance.get<ApiDatabase>();
    // add pending tx to database
    await database.addVtt(toValueTransferInfo(vtt));

    // get the list of accounts that need to be updated
    List<Account> _accountsToUpdate = accountsToUpdate(vtt);

    // update each account that was part of the transaction in the database
    for (int i = 0; i < _accountsToUpdate.length; i++) {
      Account account = _accountsToUpdate[i];
      await database.walletStorage.currentWallet.updateAccount(
        index: account.index,
        keyType: account.keyType,
        account: account,
      );
    }

    if (speedUpTx != null) {
      await deleteVtt(speedUpTx!.toValueTransferInfo());
    }

    // refresh and reload the database
    await database.getWalletStorage(true);
    await database.updateCurrentWallet();
  }

  Future<void> deleteVtt(ValueTransferInfo vtt) async {
    /// check the inputs for accounts in the wallet and remove the vtt
    await wallet.deleteVtt(vtt);

    /// delete the stale vtt from the database.
    await database.deleteVtt(vtt);
  }
}
