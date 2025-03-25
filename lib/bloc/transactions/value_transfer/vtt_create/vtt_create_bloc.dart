import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/util/allow_biometrics.dart';
import 'package:my_wit_wallet/util/filter_utxos.dart';
import 'package:my_wit_wallet/util/get_utxos_match_inputs.dart';
import 'package:my_wit_wallet/util/storage/database/adapters/transaction_adapter.dart';
import 'package:my_wit_wallet/util/storage/scanned_content.dart';
import 'package:witnet/constants.dart';
import 'package:witnet/data_structures.dart';
import 'package:witnet/explorer.dart';
import 'package:witnet/schema.dart';
import 'package:witnet/utils.dart';
import 'package:my_wit_wallet/bloc/crypto/api_crypto.dart';
import 'package:my_wit_wallet/bloc/explorer/api_explorer.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:my_wit_wallet/widgets/layouts/send_transaction_layout.dart'
    as layout;

part 'vtt_create_event.dart';
part 'vtt_create_state.dart';

class BuildVttInputsParams {
  final GeneralTransaction? speedUpTx;
  final layout.TransactionType transactionType;
  final int txValueNanoWit;
  final Wallet wallet;
  BuildVttInputsParams(
      {this.speedUpTx,
      required this.txValueNanoWit,
      required this.wallet,
      this.transactionType = layout.TransactionType.Vtt});
}

/// send the transaction via the explorer.
/// returns true on success
Future<bool> _sendTransaction(Transaction transaction) async {
  try {
    var resp =
        await Locator.instance.get<ApiExplorer>().sendTransaction(transaction);
    return resp['result'] != null ? true : false;
  } catch (e) {
    print(
        'Error sending transaction: ${transaction.toRawJson(asHex: true)} $e');
    return false;
  }
}

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  /// Create new [TransactionBloc].
  ///
  /// extends [Bloc]
  /// [on((event, emit) => null)]
  /// to map [TransactionEvent] To [TransactionState]
  TransactionBloc()
      : super(
          TransactionState(
            transaction: BuildTransaction(
                vtTransaction: VTTransaction(
                  body: VTTransactionBody(inputs: [], outputs: []),
                  signatures: [],
                ),
                stakeTransaction: StakeTransaction(
                  body: StakeBody(inputs: [], output: null, change: null),
                  signatures: [],
                ),
                unstakeTransaction: UnstakeTransaction(
                    body: UnstakeBody(operator: null, withdrawal: null),
                    signature: null)),
            message: null,
            transactionType: layout.TransactionType.Vtt,
            transactionStatus: TransactionStatus.initial,
          ),
        ) {
    on<AddValueTransferOutputEvent>(_addOutputEvent);
    on<AddUnstakeOutputEvent>(_addOutputEvent);
    on<AddStakeOutputEvent>(_addOutputEvent);
    on<SetTimelockEvent>(_setTimeLockEvent);
    on<SignTransactionEvent>(_signTransactionEvent);
    on<SendTransactionEvent>(_sendTransactionEvent);
    on<UpdateFeeEvent>(_updateFeeEvent);
    on<SetBuildingEvent>(_setBuildingStatus);
    on<PrepareSpeedUpTxEvent>(_prepareSpeedUpTx);
    on<UpdateUtxoSelectionStrategyEvent>(_updateUtxoSelectionStrategyEvent);
    on<AddSourceWalletsEvent>(_addSourceWalletsEvent);
    on<SetPriorityEstimationsEvent>(_setPriorityEstimations);
    on<SetTransactionTypeEvent>(_setTransactionType);
    on<ResetTransactionEvent>(_resetTransactionEvent);
    on<ShowAuthPreferencesEvent>(_showPasswordValidationModal);
  }

  final Map<String, Account> utxoAccountMap = {};
  late Wallet currentWallet;
  layout.TransactionType transactionType = layout.TransactionType.Vtt;
  List<String> internalAddresses = [];
  List<String> externalAddresses = [];
  Account? changeAccount;
  String? authorizationString;
  List<ValueTransferOutput> outputs = [];
  ValueTransferOutput? change = null;
  ValueTransferOutput? unstakeOutput = null;
  StakeOutput? stakeOutput = null;
  String validator = '';
  List<String> receivers = [];
  List<Input> inputs = [];
  List<Utxo> utxos = [];
  Map<String, UtxoPool> masterUtxoPool = {};
  List<Utxo> selectedUtxos = [];
  UtxoPool utxoPool = UtxoPool();
  UtxoPool filteredUtxoPool = UtxoPool();
  FeeType feeType = FeeType.Absolute;
  EstimatedFeeOptions feeOption = EstimatedFeeOptions.Medium;
  int feeNanoWit = 0;
  num balanceNanoWit = 0;
  DateTime? selectedTimelock;
  bool timelockSet = false;
  UtxoSelectionStrategy utxoSelectionStrategy =
      UtxoSelectionStrategy.SmallFirst;
  PrioritiesEstimate? prioritiesEstimate;
  bool isPrioritiesLoading = false;
  Map<EstimatedFeeOptions, String?> minerFeeOptions = DEFAULT_MINER_FEE_OPTIONS;
  int valuePaidNanoWit = 0;
  ScannedContent scannedContent = ScannedContent();

  int getFee([int additionalOutputs = 0]) {
    switch (feeType) {
      case FeeType.Absolute:
        return feeNanoWit;
      case FeeType.Weighted:
        return calculatedWeightedFee(feeNanoWit);
    }
  }

  Future<void> _showPasswordValidationModal(
      ShowAuthPreferencesEvent event, Emitter<TransactionState> emit) async {
    if (await showBiometrics()) {
      emit(state.copyWith(status: TransactionStatus.needPasswordValidation));
    }
  }

  int calculatedWeightedFee(num multiplier, {int additionalOutputs = 0}) {
    num txWeight = (inputs.length * INPUT_SIZE) +
        (outputs.length + additionalOutputs * OUTPUT_SIZE * GAMMA);
    return (txWeight * multiplier).round();
  }

  void _setEstimatedWeightedFees() {
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

  void _updateFee(
      {required FeeType newFeeType,
      int feeNanoWit = 0,
      EstimatedFeeOptions newFeeOption = EstimatedFeeOptions.Medium}) {
    feeType = newFeeType;
    feeOption = newFeeOption;
    switch (feeType) {
      case FeeType.Absolute:
        this.feeNanoWit = feeNanoWit;
        break;
      case FeeType.Weighted:
        this.feeNanoWit = feeNanoWit;
        break;
    }
  }

  void _setUtxo(Utxo utxo) {
    if (utxo.timelock > 0) {
      int _ts = utxo.timelock * 1000;
      DateTime _timelock = DateTime.fromMillisecondsSinceEpoch(_ts);

      int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
      if (_timelock.millisecondsSinceEpoch > currentTimestamp) {
        /// utxo is still locked
      } else {
        utxos.add(utxo);
        balanceNanoWit += utxo.value;
      }
    } else if (utxo.timelock == 0) {
      utxos.add(utxo);
      balanceNanoWit += utxo.value;
    }
  }

  Future<Wallet> _setWalletBalance(Wallet wallet) async {
    if (wallet.walletType == WalletType.hd) {
      /// setup the external accounts
      wallet.externalAccounts.forEach((index, account) {
        externalAddresses.add(account.address);
        account.utxos.forEach((utxo) {
          _setUtxo(utxo);
        });
      });

      /// setup the internal accounts
      wallet.internalAccounts.forEach((index, account) {
        internalAddresses.add(account.address);
        account.utxos.forEach((utxo) {
          _setUtxo(utxo);
        });
      });
    } else {
      /// master node
      wallet.masterAccount!.utxos.forEach((utxo) {
        _setUtxo(utxo);
      });
    }
    return wallet;
  }

  Future<void> _setWallet(Wallet? newWalletStorage) async {
    if (newWalletStorage != null) {
      utxos.clear();
      this.currentWallet = await _setWalletBalance(newWalletStorage);
      balanceNanoWit = 0;
      currentWallet = currentWallet;

      /// get the internal account that will be used for any change
      bool changeAccountSet = false;
      Wallet firstWallet = currentWallet;

      if (currentWallet.walletType == WalletType.hd) {
        for (int i = 0; i < firstWallet.internalAccounts.length; i++) {
          if (!changeAccountSet) {
            Account account = firstWallet.internalAccounts[i]!;
            if (account.vttHashes.isEmpty) {
              changeAccount = account;
              changeAccountSet = true;
            }
          }
        }

        /// did we run out of change addresses?
        if (!changeAccountSet) {
          ApiCrypto apiCrypto = Locator.instance<ApiCrypto>();
          changeAccount = await apiCrypto.generateAccount(
            firstWallet,
            KeyType.internal,
            internalAddresses.length,
          );
        }
      } else {
        /// master node
        changeAccount = currentWallet.masterAccount!;
      }

      /// update the utxo pool
      utxoPool.clear();
      utxos.forEach((utxo) {
        utxoPool.insert(utxo);
      });

      /// presort the utxo pool
      utxoPool.sortUtxos(utxoSelectionStrategy);
    }
  }

  Future<void> deleteVtt(Wallet wallet, ValueTransferInfo vtt) async {
    ApiDatabase database = Locator.instance.get<ApiDatabase>();

    /// check the inputs for accounts in the wallet and remove the vtt
    await wallet.deleteVtt(wallet, vtt);

    /// delete the stale vtt from the database.
    await database.deleteVtt(vtt);
  }

  void _setSelectedUtxos(BuildVttInputsParams params) {
    // Remove utxos used in pending transactions
    List<Utxo> filteredUtxos = filterUsedUtxos(
        utxoList: utxos,
        pendingVtts: params.wallet.pendingTransactions(),
        pendingStakes: params.wallet.pendingStakes());

    // Update the utxo pool
    filteredUtxoPool.clear();
    filteredUtxos.forEach((utxo) {
      filteredUtxoPool.insert(utxo);
    });

    if (params.speedUpTx != null && params.speedUpTx?.vtt != null) {
      // Calculate remain value to cover
      int rest = params.txValueNanoWit;
      params.speedUpTx!.vtt!.inputs.forEach((e) => rest -= e.value);

      // Get used utxos from speedUpTx inputs
      List<Utxo> usedUtxos = getUtxosMatchInputs(
          utxoList: utxos, inputs: params.speedUpTx!.vtt!.inputs);

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
  }

  void _addInputs() {
    /// convert utxo to input
    inputs.clear();
    for (int i = 0; i < selectedUtxos.length; i++) {
      Utxo currentUtxo = selectedUtxos[i];
      Input _input = currentUtxo.toInput();
      inputs.add(_input);
      valuePaidNanoWit += currentUtxo.value;
    }
  }

  void _buildTxInputs(
    BuildVttInputsParams params,
  ) {
    _setSelectedUtxos(params);
    _addInputs();
  }

  dynamic addTransactionChangeOutput(
      {required layout.TransactionType txType,
      required String? address,
      required int outputValue}) {
    switch (txType) {
      case layout.TransactionType.Vtt:
        outputs.add(ValueTransferOutput.fromJson({
          'pkh': address,
          'value': outputValue,
          'time_lock': 0,
        }));
      case layout.TransactionType.Stake:
        change = ValueTransferOutput.fromJson({
          'pkh': address,
          'value': outputValue,
          'time_lock': 0,
        });
      case layout.TransactionType.Unstake:
        return;
    }
  }

  int getTransactionOutputValue({
    required layout.TransactionType txType,
    required WalletType walletType,
  }) {
    switch (txType) {
      case layout.TransactionType.Vtt:
        return _getVttOutputValue(walletType: walletType);
      case layout.TransactionType.Stake:
        return _getStakeOutputValue();
      case layout.TransactionType.Unstake:
        return _getUnstakeOutputValue();
    }
  }

  int _getStakeOutputValue() {
    return stakeOutput != null ? stakeOutput!.value.toInt() : 0;
  }

  int _getUnstakeOutputValue() {
    /// calculate value owed
    return unstakeOutput != null ? unstakeOutput!.value.toInt() : 0;
  }

  int _getVttOutputValue({required WalletType walletType}) {
    /// calculate value owed
    int valueOwedNanoWit = 0;
    bool containsChangeAddress = false;
    int changeIndex = 0;
    int outIdx = 0;
    outputs.forEach((element) {
      if (element.pkh.address == changeAccount?.address) {
        /// check if a change address is already in the outputs
        containsChangeAddress = true;
        changeIndex = outIdx;
      }
      outIdx += 1;
    });

    if (containsChangeAddress && changeIndex == 1) {
      outputs.removeAt(changeIndex);
    }
    outputs.forEach((element) {
      valueOwedNanoWit += element.value.toInt();
    });
    return valueOwedNanoWit;
  }

  void _buildTransactionBody(Wallet wallet, {GeneralTransaction? speedUpTx}) {
    int valueOwedNanoWit = 0;
    int valueChangeNanoWit = 0;
    WalletType walletType = wallet.walletType;
    // Reset tx value paid
    valuePaidNanoWit = 0;
    valueOwedNanoWit = getTransactionOutputValue(
        walletType: walletType, txType: this.transactionType);

    /// sets the fee weighted and absolute
    feeNanoWit = getFee();
    valueOwedNanoWit += feeNanoWit;

    _buildTxInputs(BuildVttInputsParams(
        txValueNanoWit: valueOwedNanoWit,
        wallet: wallet,
        speedUpTx: speedUpTx));

    /// calculate change
    if (feeType == FeeType.Weighted) {
      valueChangeNanoWit = (valuePaidNanoWit - valueOwedNanoWit);

      if (valueChangeNanoWit > 0) {
        // add change
        // +1 to the outputs length to include for change address
        feeNanoWit = getFee(feeNanoWit);
        valueChangeNanoWit = (valuePaidNanoWit - valueOwedNanoWit);
        addTransactionChangeOutput(
          txType: this.transactionType,
          address: changeAccount?.address,
          outputValue: valueChangeNanoWit,
        );
      }
    } else {
      feeNanoWit = getFee();
      valueChangeNanoWit = (valuePaidNanoWit - valueOwedNanoWit);
      if (valueChangeNanoWit > 0) {
        addTransactionChangeOutput(
            txType: this.transactionType,
            address: changeAccount?.address,
            outputValue: valueChangeNanoWit);
      }
    }
  }

  _setTransactionType(
      SetTransactionTypeEvent event, Emitter<TransactionState> emit) {
    this.transactionType = event.transactionType;
    emit(state.copyWith(transactionType: event.transactionType));
  }

  _buildVttOutputs(AddValueTransferOutputEvent event) {
    try {
      if (event.merge) {
        /// check to see if the address is already in the list.
        if (receivers.contains(event.output.pkh)) {
          /// if the address is in the list add the value instead of
          /// generating a new output
          outputs[receivers.indexOf(event.output.pkh.address)].value +=
              event.output.value;
          if (selectedTimelock != null) {
            outputs[receivers.indexOf(event.output.pkh.address)].timeLock =
                (selectedTimelock!.millisecondsSinceEpoch * 1000) as Int64;
          }
        } else {
          receivers.add(event.output.pkh.address);
          outputs.add(event.output);
        }
      } else {
        // if merge is false then add an additional output.
        receivers.add(event.output.pkh.address);
        outputs.add(event.output);
      }
    } catch (e) {
      print('Error building vtt outputs $e');
    }
  }

  _buildStakeOutput(AddStakeOutputEvent event) {
    try {
      KeyedSignature validator = KeyedSignature.fromAuthorization(
          authorization: event.authorization, withdrawer: event.withdrawer);
      stakeOutput = StakeOutput(
        value: event.value,
        key: StakeKey.fromJson({
          "validator": validator.publicKey.pkh.address,
          "withdrawer": event.withdrawer,
        }),
        authorization: validator,
      );
    } catch (e) {
      print('Error building stake output $e');
    }
  }

  _buildUnstakeOutput(AddUnstakeOutputEvent event) {
    unstakeOutput = event.output;
    validator = event.validator;
  }

  void _buildTransactionOutputs(
      {required layout.TransactionType txType, required dynamic event}) {
    switch (txType) {
      case layout.TransactionType.Vtt:
        _buildVttOutputs(event);
      case layout.TransactionType.Stake:
        _buildStakeOutput(event);
      case layout.TransactionType.Unstake:
        _buildUnstakeOutput(event);
    }
  }

  void _addOutputEvent(dynamic event, Emitter<TransactionState> emit) {
    emit(state.copyWith(status: TransactionStatus.busy));
    try {
      _buildTransactionOutputs(txType: this.transactionType, event: event);
    } catch (e) {
      emit(state.copyWith(status: TransactionStatus.exception, message: '$e'));
      print('Error buildTransactionOutputs $e');
    }
    if (this.transactionType != layout.TransactionType.Unstake) {
      try {
        _buildTransactionBody(
          event.currentWallet,
          speedUpTx: this.transactionType == layout.TransactionType.Vtt
              ? event.speedUpTx
              : null,
        );
      } catch (err) {
        print('Error building transaction body $err');
        emit(state.copyWith(
            status: TransactionStatus.insufficientFunds,
            message: INSUFFICIENT_FUNDS_ERROR));
      }
      _setEstimatedWeightedFees();
    }
    emit(
      state.copyWith(
          outputs: outputs,
          inputs: inputs,
          stakeOutput: stakeOutput,
          change: change,
          operator: this.transactionType == layout.TransactionType.Unstake
              ? Address.fromAddress(validator).publicKeyHash
              : PublicKeyHash(),
          withdrawal: unstakeOutput,
          status: TransactionStatus.building,
          message: null),
    );
  }

  void _setBuildingStatus(
      SetBuildingEvent event, Emitter<TransactionState> emit) {
    emit(
      state.copyWith(
          inputs: inputs, outputs: outputs, status: TransactionStatus.building),
    );
  }

  /// set the timelock for the current [ValueTransferOutput].
  void _setTimeLockEvent(
      SetTimelockEvent event, Emitter<TransactionState> emit) {
    selectedTimelock = event.dateTime;
    timelockSet = true;
    emit(
      state.copyWith(
          inputs: inputs, outputs: outputs, status: TransactionStatus.building),
    );
  }

  /// sign the [VTTransaction]
  Future<dynamic> _signTransaction({
    required Wallet currentWallet,
    GeneralTransaction? speedUpTx,
  }) async {
    /// Read the encrypted XPRV string stored in the database
    Wallet walletStorage = currentWallet;
    ApiCrypto apiCrypto = Locator.instance<ApiCrypto>();
    try {
      switch (this.transactionType) {
        case layout.TransactionType.Vtt:
          _buildTransactionBody(
            currentWallet,
            speedUpTx: speedUpTx,
          );
          List<KeyedSignature> signatures = await apiCrypto.signTransaction(
            selectedUtxos,
            walletStorage,
            bytesToHex(
                VTTransactionBody(inputs: inputs, outputs: outputs).hash),
          );
          return BuildTransaction(
              vtTransaction: VTTransaction(
                  body: VTTransactionBody(inputs: inputs, outputs: outputs),
                  signatures: signatures));
        case layout.TransactionType.Stake:
          _buildTransactionBody(
            currentWallet,
            speedUpTx: speedUpTx,
          );
          List<KeyedSignature> signatures = await apiCrypto.signTransaction(
            selectedUtxos,
            walletStorage,
            bytesToHex(
                StakeBody(inputs: inputs, output: stakeOutput, change: change)
                    .hash),
          );
          return BuildTransaction(
              stakeTransaction: StakeTransaction(
                  body: StakeBody(
                      inputs: inputs, output: stakeOutput, change: change),
                  signatures: signatures));
        case layout.TransactionType.Unstake:
          int nonce = await Locator.instance.get<ApiExplorer>().getNonce(
              validator: validator,
              withdrawer: unstakeOutput?.pkh.address ?? '');
          UnstakeBody body = UnstakeBody(
              operator: Address.fromAddress(validator).publicKeyHash,
              withdrawal: unstakeOutput,
              nonce: nonce);
          KeyedSignature signature = await apiCrypto.signUnstakeBody(
            body.hash,
            unstakeOutput?.pkh.address ?? '',
          );

          return BuildTransaction(
              unstakeTransaction:
                  UnstakeTransaction(body: body, signature: signature));
      }
    } catch (e) {
      print('Error signing transaction $e');
      rethrow;
    }
  }

  List<InputUtxo> _buildInputUtxoList() {
    List<InputUtxo> _inputs = [];

    /// loop through utxos
    for (int i = 0; i < selectedUtxos.length; i++) {
      Utxo currentUtxo = selectedUtxos.elementAt(i);

      /// loop though every external account
      currentWallet.externalAccounts.forEach((index, account) {
        if (account.utxos.contains(currentUtxo)) {
          _inputs.add(InputUtxo(
              address: account.address,
              inputUtxo: currentUtxo.toInput().outputPointer.toString(),
              value: currentUtxo.value));
        }
      });

      /// loop though every internal account
      currentWallet.internalAccounts.forEach((index, account) {
        if (account.utxos.contains(currentUtxo)) {
          _inputs.add(InputUtxo(
              address: account.address,
              inputUtxo: currentUtxo.toInput().outputPointer.toString(),
              value: currentUtxo.value));
        }
      });

      if (currentWallet.walletType == WalletType.single &&
          currentWallet.masterAccount != null) {
        _inputs.add(InputUtxo(
            address: currentWallet.masterAccount!.address,
            inputUtxo: currentUtxo.toInput().outputPointer.toString(),
            value: currentUtxo.value));
      }
    }
    return _inputs;
  }

  /// sign the transaction
  Future<void> _signTransactionEvent(
      SignTransactionEvent event, Emitter<TransactionState> emit) async {
    emit(state.copyWith(status: TransactionStatus.signing, message: null));
    try {
      BuildTransaction buildTransaction = await _signTransaction(
        currentWallet: event.currentWallet,
        speedUpTx: event.speedUpTx,
      );
      emit(TransactionState(
        transaction: buildTransaction,
        transactionType: this.transactionType,
        transactionStatus: TransactionStatus.finished,
        message: null,
      ));
    } catch (e) {
      print('Error signing the transaction :: $e');
      emit(state.copyWith(status: TransactionStatus.exception, message: '$e'));
      rethrow;
    }
  }

  /// send the transaction to the explorer
  Future<void> _sendTransactionEvent(
      SendTransactionEvent event, Emitter<TransactionState> emit) async {
    bool transactionAccepted = false;
    emit(state.copyWith(status: TransactionStatus.sending, message: null));
    ApiDatabase database = Locator.instance.get<ApiDatabase>();
    dynamic transactionBuilt = event.transaction.get(this.transactionType);
    Transaction transactionToSend;
    switch (this.transactionType) {
      case layout.TransactionType.Vtt:
        transactionToSend = Transaction(valueTransfer: transactionBuilt);
      case layout.TransactionType.Stake:
        transactionToSend = Transaction(stake: transactionBuilt);
      case layout.TransactionType.Unstake:
        transactionToSend = Transaction(unstake: transactionBuilt);
    }
    try {
      transactionAccepted = await _sendTransaction(transactionToSend);
    } catch (e) {
      emit(state.copyWith(
          status: TransactionStatus.explorerException,
          message: 'Error sending the transaction ${e}'));
    }
    if (transactionAccepted) {
      List<InputUtxo> _inputUtxoList = _buildInputUtxoList();

      /// Value Transfer
      if (event.transaction.vtTransaction != null) {
        /// Adds pending transaction
        List<InputUtxo> _inputUtxoList = _buildInputUtxoList();
        ValueTransferInfo vti = ValueTransferInfo(
            block: '0',
            confirmed: false,
            reverted: false,
            inputsMerged: [],
            timelocks: outputs.map((e) => e.timeLock.toInt()).toList(),
            fee: feeNanoWit,
            inputAddresses: _inputUtxoList.map((e) => e.address).toList(),
            outputAddresses: outputs.map((e) => e.pkh.address).toList(),
            inputUtxos: _inputUtxoList,
            outputs: outputs,
            outputValues: outputs.map((e) => e.value.toInt()).toList(),
            priority: 1,
            status: TxStatusLabel.pending,
            value: outputs[0].value.toInt(),
            epoch: -1,
            utxos: [],
            utxosMerged: [],
            trueOutputAddresses: [],
            changeOutputAddresses: [],
            hash: event.transaction.getTransactionID(this.transactionType),
            timestamp: DateTime.now().millisecondsSinceEpoch,
            weight: event.transaction.vtTransaction!.weight);

        /// add pending tx to database
        await database.addVtt(vti);

        /// update the accounts transaction list
        /// the inputs

        List<String> accountUpdates = [];

        for (int i = 0; i < _inputUtxoList.length; i++) {
          InputUtxo inputUtxo = _inputUtxoList[i];
          if (!accountUpdates.contains(inputUtxo.address)) {
            Account account = database.walletStorage.currentWallet
                .accountByAddress(inputUtxo.address)!;
            account.vttHashes
                .add(event.transaction.getTransactionID(this.transactionType));
            account.vtts.add(vti);
            await database.walletStorage.currentWallet.updateAccount(
              index: account.index,
              keyType: account.keyType,
              account: account,
            );
            accountUpdates.add(account.address);
          }
        }

        /// check outputs for accounts and update them
        for (int i = 0; i < outputs.length; i++) {
          ValueTransferOutput output = outputs[i];
          if (!accountUpdates.contains(output.pkh.address)) {
            Account? account = database.walletStorage.currentWallet
                .accountByAddress(output.pkh.address);
            if (account != null) {
              account.vttHashes.add(
                  event.transaction.getTransactionID(this.transactionType));
              account.vtts.add(vti);
              await database.walletStorage.currentWallet.updateAccount(
                index: account.index,
                keyType: account.keyType,
                account: account,
              );
            }
          }
        }
        if (event.speedUpTx != null) {
          await deleteVtt(database.walletStorage.currentWallet,
              event.speedUpTx!.toValueTransferInfo());
        }
        emit(state.copyWith(status: TransactionStatus.accepted, message: null));
        await Locator.instance<ApiDatabase>().getWalletStorage(true);
        await database.updateCurrentWallet();
      } else if (event.transaction.stakeTransaction != null) {
        StakeEntry stakeEntry = StakeEntry(
          hash: event.transaction.getTransactionID(this.transactionType),
          blockHash: '0',
          fees: feeNanoWit,
          epoch: -1,
          inputs: _inputUtxoList
              .map((e) => StakeInput(address: e.address, value: e.value))
              .toList(),
          timestamp: DateTime.now().millisecondsSinceEpoch,
          status: TxStatusLabel.pending,
          type: TransactionType.stake,
          confirmed: false,
          reverted: false,
          validator: event
              .transaction.stakeTransaction!.body.output.key.validator.address,
          withdrawer: event
              .transaction.stakeTransaction!.body.output.key.withdrawer.address,
          value: event.transaction.stakeTransaction!.body.output.value.toInt(),
        );
        await database.addStake(stakeEntry);

        List<String> accountUpdates = [];

        for (int i = 0; i < _inputUtxoList.length; i++) {
          InputUtxo inputUtxo = _inputUtxoList[i];
          if (!accountUpdates.contains(inputUtxo.address)) {
            Account account = database.walletStorage.currentWallet
                .accountByAddress(inputUtxo.address)!;
            account.stakeHashes
                .add(event.transaction.getTransactionID(this.transactionType));
            account.stakes.add(stakeEntry);
            await database.walletStorage.currentWallet.updateAccount(
              index: account.index,
              keyType: account.keyType,
              account: account,
            );
            accountUpdates.add(account.address);
          }
        }

        /// check outputs for accounts and update them
        for (int i = 0; i < outputs.length; i++) {
          ValueTransferOutput output = outputs[i];
          if (!accountUpdates.contains(output.pkh.address)) {
            Account? account = database.walletStorage.currentWallet
                .accountByAddress(output.pkh.address);
            if (account != null) {
              account.stakeHashes.add(
                  event.transaction.getTransactionID(this.transactionType));
              account.stakes.add(stakeEntry);
              await database.walletStorage.currentWallet.updateAccount(
                index: account.index,
                keyType: account.keyType,
                account: account,
              );
            }
          }
        }
        emit(state.copyWith(status: TransactionStatus.accepted, message: null));
        await Locator.instance<ApiDatabase>().getWalletStorage(true);
        await database.updateCurrentWallet();
      } else if (event.transaction.unstakeTransaction != null) {
        UnstakeEntry unstakeEntry = UnstakeEntry(
            hash: event.transaction.getTransactionID(this.transactionType),
            blockHash: '0',
            fees: feeNanoWit,
            epoch: -1,
            timestamp: DateTime.now().millisecondsSinceEpoch,
            value: event.transaction.unstakeTransaction!.body.withdrawal.value
                .toInt(),
            status: TxStatusLabel.pending,
            type: TransactionType.unstake,
            confirmed: false,
            reverted: false,
            validator:
                event.transaction.unstakeTransaction!.body.operator.address,
            withdrawer: event
                .transaction.unstakeTransaction!.body.withdrawal.pkh.address,
            nonce: event.transaction.unstakeTransaction!.body.nonce.toInt());

        await database.addUnstake(unstakeEntry);

        List<String> accountUpdates = [];

        for (int i = 0; i < _inputUtxoList.length; i++) {
          InputUtxo inputUtxo = _inputUtxoList[i];
          if (!accountUpdates.contains(inputUtxo.address)) {
            Account account = database.walletStorage.currentWallet
                .accountByAddress(inputUtxo.address)!;
            account.unstakeHashes
                .add(event.transaction.getTransactionID(this.transactionType));
            account.unstakes.add(unstakeEntry);
            await database.walletStorage.currentWallet.updateAccount(
              index: account.index,
              keyType: account.keyType,
              account: account,
            );
            accountUpdates.add(account.address);
          }
        }

        /// check outputs for accounts and update them
        for (int i = 0; i < outputs.length; i++) {
          ValueTransferOutput output = outputs[i];
          if (!accountUpdates.contains(output.pkh.address)) {
            Account? account = database.walletStorage.currentWallet
                .accountByAddress(output.pkh.address);
            if (account != null) {
              account.unstakeHashes.add(
                  event.transaction.getTransactionID(this.transactionType));
              account.unstakes.add(unstakeEntry);
              await database.walletStorage.currentWallet.updateAccount(
                index: account.index,
                keyType: account.keyType,
                account: account,
              );
            }
          }
        }
        emit(state.copyWith(status: TransactionStatus.accepted, message: null));
        await Locator.instance<ApiDatabase>().getWalletStorage(true);
        await database.updateCurrentWallet();
      } else {
        emit(
            state.copyWith(status: TransactionStatus.discarded, message: null));
      }
    } else {
      emit(state.copyWith(
          status: TransactionStatus.discarded,
          message: 'Transaciton was not accepted'));
    }
  }

  void _updateFeeEvent(UpdateFeeEvent event, Emitter<TransactionState> emit) {
    if (event.feeNanoWit != null) {
      _updateFee(
          newFeeType: event.feeType,
          feeNanoWit: event.feeNanoWit!,
          newFeeOption: event.feeOption);
    } else {
      _updateFee(newFeeType: event.feeType, newFeeOption: event.feeOption);
    }
  }

  void _updateUtxoSelectionStrategyEvent(
      UpdateUtxoSelectionStrategyEvent event, Emitter<TransactionState> emit) {
    utxoSelectionStrategy = event.strategy;
  }

  Future<void> _prepareSpeedUpTx(
      PrepareSpeedUpTxEvent event, Emitter<TransactionState> emit) async {
    _resetTransactionEvent(ResetTransactionEvent(), emit);
    await _setPriorityEstimations(SetPriorityEstimationsEvent(), emit);
    await _addSourceWalletsEvent(
        AddSourceWalletsEvent(currentWallet: event.currentWallet), emit);
    _addOutputEvent(
        AddValueTransferOutputEvent(
            speedUpTx: event.speedUpTx,
            filteredUtxos: false,
            currentWallet: event.currentWallet,
            output: event.output,
            merge: true),
        emit);
  }

  Future<void> _addSourceWalletsEvent(
      AddSourceWalletsEvent event, Emitter<TransactionState> emit) async {
    await _setWallet(event.currentWallet);
    emit(state.copyWith(
        inputs: inputs,
        outputs: outputs,
        status: TransactionStatus.building,
        message: null));
  }

  Future<void> _setPriorityEstimations(
      SetPriorityEstimationsEvent event, Emitter<TransactionState> emit) async {
    if (!isPrioritiesLoading) {
      isPrioritiesLoading = true;
      try {
        prioritiesEstimate =
            await Locator.instance.get<ApiExplorer>().priority();
        isPrioritiesLoading = false;
      } catch (e) {
        print('Error getting priority estimations $e');
        emit(state.copyWith(
            status: TransactionStatus.explorerException, message: '$e'));
        isPrioritiesLoading = false;
        rethrow;
      }
    }
  }

  void _resetTransactionEvent(
      ResetTransactionEvent event, Emitter<TransactionState> emit) {
    scannedContent.clearScannedContent();
    selectedUtxos.clear();
    inputs.clear();
    outputs.clear();
    stakeOutput = null;
    unstakeOutput = null;
    change = null;
    authorizationString = null;
    receivers.clear();
    selectedTimelock = null;
    timelockSet = false;
    feeNanoWit = 0;
    feeOption = EstimatedFeeOptions.Medium;
    emit(state.copyWith(
        status: TransactionStatus.initial,
        message: null,
        inputs: [],
        outputs: [],
        stakeOutput: StakeOutput(),
        change: ValueTransferOutput(),
        operator: PublicKeyHash(),
        withdrawal: ValueTransferOutput()));
  }
}
