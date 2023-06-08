import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/constants.dart';
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

part 'vtt_create_event.dart';
part 'vtt_create_state.dart';

/// send the transaction via the explorer.
/// returns true on success
Future<bool> _sendTransaction(Transaction transaction) async {
  try {
    var resp =
        await Locator.instance.get<ApiExplorer>().sendTransaction(transaction);
    return resp['result'];
  } catch (e) {
    print('Error sending transaction: $e');
    return false;
  }
}

class VTTCreateBloc extends Bloc<VTTCreateEvent, VTTCreateState> {
  /// Create new [VTTCreateBloc].
  ///
  /// extends [Bloc]
  /// [on((event, emit) => null)]
  /// to map [VTTCreateEvent] To [VTTCreateState]
  VTTCreateBloc()
      : super(
          VTTCreateState(
            vtTransaction: VTTransaction(
              body: VTTransactionBody(inputs: [], outputs: []),
              signatures: [],
            ),
            message: null,
            vttCreateStatus: VTTCreateStatus.initial,
          ),
        ) {
    on<AddValueTransferOutputEvent>(_addValueTransferOutputEvent);
    on<SetTimelockEvent>(_setTimeLockEvent);
    on<SignTransactionEvent>(_signTransactionEvent);
    on<SendTransactionEvent>(_sendVttTransactionEvent);
    on<UpdateFeeEvent>(_updateFeeEvent);
    on<UpdateUtxoSelectionStrategyEvent>(_updateUtxoSelectionStrategyEvent);
    on<AddSourceWalletsEvent>(_addSourceWalletsEvent);
    on<ResetTransactionEvent>(_resetTransactionEvent);
    on<ValidateTransactionEvent>(_validateTransactionEvent);

    ///
  }

  final Map<String, Account> utxoAccountMap = {};
  late Wallet currentWallet;
  List<String> internalAddresses = [];
  List<String> externalAddresses = [];
  Account? changeAccount;
  List<ValueTransferOutput> outputs = [];
  List<String> receivers = [];
  List<Input> inputs = [];
  List<Utxo> utxos = [];
  Map<String, UtxoPool> masterUtxoPool = {};
  List<Utxo> selectedUtxos = [];
  UtxoPool utxoPool = UtxoPool();
  FeeType feeType = FeeType.Weighted;
  int feeNanoWit = 0;
  num balanceNanoWit = 0;
  DateTime? selectedTimelock;
  bool timelockSet = false;
  UtxoSelectionStrategy utxoSelectionStrategy =
      UtxoSelectionStrategy.SmallFirst;
  PrioritiesEstimate? prioritiesEstimate;
  Map<EstimatedFeeOptions, String?> minerFeeOptions = DEFAULT_MINER_FEE_OPTIONS;

  int getFee([int additionalOutputs = 0]) {
    switch (feeType) {
      case FeeType.Absolute:
        return feeNanoWit;
      case FeeType.Weighted:
        return calculatedWeightedFee(feeNanoWit);
    }
  }

  int calculatedWeightedFee(num multiplier, {int additionalOutputs = 0}) {
    num txWeight = (inputs.length * INPUT_SIZE) +
        (outputs.length + additionalOutputs * OUTPUT_SIZE * GAMMA);
    return (txWeight * multiplier).round();
  }

  Future setEstimatedPriorities() async {
    try {
      prioritiesEstimate = await Locator.instance.get<ApiExplorer>().priority();
    } catch (e) {
      print('Error getting priority estimations $e');
      rethrow;
    }
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

  void updateFee(FeeType newFeeType, [int feeNanoWit = 0]) {
    feeType = newFeeType;
    switch (feeType) {
      case FeeType.Absolute:
        this.feeNanoWit = feeNanoWit;
        break;
      case FeeType.Weighted:
        break;
    }
  }

  bool addOutput(ValueTransferOutput output, [bool merge = true]) {
    try {
      if (merge) {
        // check to see if the address is already in the list.
        if (receivers.contains(output.pkh)) {
          // if the address is in the list add the value instead of
          // generating a new output
          outputs[receivers.indexOf(output.pkh.address)].value += output.value;
          if (selectedTimelock != null) {
            outputs[receivers.indexOf(output.pkh.address)].timeLock =
                (selectedTimelock!.millisecondsSinceEpoch * 100) as Int64;
          }
        } else {
          receivers.add(output.pkh.address);
          outputs.add(output);
        }
      } else {
        // if merge is false then add an additional output.
        receivers.add(output.pkh.address);
        outputs.add(output);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  void setSelectionStrategy(UtxoSelectionStrategy strategy) {
    utxoSelectionStrategy = strategy;
  }

  Future<Wallet> _setWalletBalance(Wallet wallet) async {
    /// setup the external accounts
    wallet.externalAccounts.forEach((index, account) {
      balanceNanoWit += account.balance.availableNanoWit;

      externalAddresses.add(account.address);

      account.utxos.forEach((utxo) {
        if (utxo.timelock > 0) {
          int _ts = utxo.timelock * 1000;
          DateTime _timelock = DateTime.fromMillisecondsSinceEpoch(_ts);

          int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
          if (_timelock.millisecondsSinceEpoch > currentTimestamp) {
            /// utxo is still locked
            // int timeRemaining = _timelock.millisecondsSinceEpoch - currentTimestamp;
          } else {
            utxos.add(utxo);
            balanceNanoWit += utxo.value;
          }
        } else if (utxo.timelock == 0) {
          utxos.add(utxo);
          balanceNanoWit += utxo.value;
        }
      });
    });

    /// setup the internal accounts

    wallet.internalAccounts.forEach((index, account) {
      balanceNanoWit += account.balance.availableNanoWit;
      internalAddresses.add(account.address);

      account.utxos.forEach((utxo) {
        if (utxo.timelock > 0) {
          int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
          if (utxo.timelock > currentTimestamp) {
            /// utxo is still locked
          } else {
            utxos.add(utxo);
          }
        } else if (utxo.timelock == 0) {
          utxos.add(utxo);
        }
      });
    });
    return wallet;
  }

  Future<void> setWallet(Wallet? newWalletStorage) async {
    if (newWalletStorage != null) {
      utxos.clear();
      this.currentWallet = await _setWalletBalance(newWalletStorage);
      balanceNanoWit = 0;
      currentWallet = currentWallet;

      /// get the internal account that will be used for any change
      bool changeAccountSet = false;
      Wallet firstWallet = currentWallet;

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

      /// update the utxo pool
      utxoPool.clear();
      utxos.forEach((utxo) {
        utxoPool.insert(utxo);
      });

      /// presort the utxo pool
      utxoPool.sortUtxos(utxoSelectionStrategy);
    }
  }

  void buildTransactionBody(int balanceNanoWit) {
    int valueOwedNanoWit = 0;
    int valuePaidNanoWit = 0;
    int valueChangeNanoWit = 0;
    try {
      /// calculate value owed
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

      ///
      if (containsChangeAddress) {
        outputs.removeAt(changeIndex);
      }
      outputs.forEach((element) {
        ///
        valueOwedNanoWit += element.value.toInt();
      });

      /// sets the fee weighted and absolute
      feeNanoWit = getFee();
      valueOwedNanoWit += feeNanoWit;

      /// compare to balance
      if (balanceNanoWit < valueOwedNanoWit) {
        /// TODO:: throw insufficient funds exception
      } else {
        /// get utxos from the pool
        selectedUtxos = utxoPool.cover(
            amountNanoWit: valueOwedNanoWit,
            utxoStrategy: utxoSelectionStrategy);

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
          feeNanoWit = getFee(1);
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

  /// add a [ValueTransferOutput] to the [VTTransaction].
  void _addValueTransferOutputEvent(
      AddValueTransferOutputEvent event, Emitter<VTTCreateState> emit) {
    emit(state.copyWith(status: VTTCreateStatus.busy));
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
                (selectedTimelock!.millisecondsSinceEpoch * 100) as Int64;
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
    } catch (e) {}
    buildTransactionBody(event.currentWallet.balanceNanoWit().availableNanoWit);
    setEstimatedWeightedFees();
    emit(
      state.copyWith(
          inputs: inputs, outputs: outputs, status: VTTCreateStatus.building),
    );
  }

  /// set the timelock for the current [ValueTransferOutput].
  void _setTimeLockEvent(SetTimelockEvent event, Emitter<VTTCreateState> emit) {
    selectedTimelock = event.dateTime;
    timelockSet = true;
    emit(
      state.copyWith(
          inputs: inputs, outputs: outputs, status: VTTCreateStatus.building),
    );
  }

  /// sign the [VTTransaction]
  Future<VTTransaction> _signTransaction(
      {required Wallet currentWallet}) async {
    /// Read the encrypted XPRV string stored in the database
    Wallet walletStorage = currentWallet;
    ApiCrypto apiCrypto = Locator.instance<ApiCrypto>();
    try {
      buildTransactionBody(currentWallet.balanceNanoWit().availableNanoWit);
      List<KeyedSignature> signatures = await apiCrypto.signTransaction(
        selectedUtxos,
        walletStorage,
        bytesToHex(VTTransactionBody(inputs: inputs, outputs: outputs).hash),
      );

      return VTTransaction(
          body: VTTransactionBody(inputs: inputs, outputs: outputs),
          signatures: signatures);
    } catch (e) {
      rethrow;
    }
  }

  Map<String, List<String>> buildSignerMap() {
    Map<String, List<String>> _signers = {};

    /// loop through utxos
    for (int i = 0; i < selectedUtxos.length; i++) {
      Utxo currentUtxo = selectedUtxos.elementAt(i);

      Wallet currentWallet =
          Locator.instance.get<ApiDatabase>().walletStorage.currentWallet;

      /// loop though every external account
      currentWallet.externalAccounts.forEach((index, account) {
        if (account.utxos.contains(currentUtxo)) {
          if (_signers.containsKey(currentWallet.xprv)) {
            _signers[currentWallet.xprv]!.add(account.path);
          } else {
            _signers[currentWallet.xprv!] = [account.path];
          }
        }
      });

      /// loop though every internal account
      currentWallet.internalAccounts.forEach((index, account) {
        if (account.utxos.contains(currentUtxo)) {
          if (_signers.containsKey(currentWallet.xprv)) {
            _signers[currentWallet.xprv]!.add(account.path);
          } else {
            _signers[currentWallet.xprv!] = [account.path];
          }
        }
      });
    }

    return _signers;
  }

  List<InputUtxo> buildInputUtxoList() {
    List<InputUtxo> _inputs = [];

    /// loop through utxos
    for (int i = 0; i < selectedUtxos.length; i++) {
      Utxo currentUtxo = selectedUtxos.elementAt(i);

      /// loop though every external account
      currentWallet.externalAccounts.forEach((index, account) {
        if (account.utxos.contains(currentUtxo)) {
          _inputs.add(InputUtxo(
              address: account.address,
              input: currentUtxo.toInput(),
              value: currentUtxo.value));
        }
      });

      /// loop though every internal account
      currentWallet.internalAccounts.forEach((index, account) {
        if (account.utxos.contains(currentUtxo)) {
          _inputs.add(InputUtxo(
              address: account.address,
              input: currentUtxo.toInput(),
              value: currentUtxo.value));
        }
      });
    }
    return _inputs;
  }

  /// sign the transaction
  Future<void> _signTransactionEvent(
      SignTransactionEvent event, Emitter<VTTCreateState> emit) async {
    emit(state.copyWith(status: VTTCreateStatus.signing));
    try {
      VTTransaction vtTransaction =
          await _signTransaction(currentWallet: event.currentWallet);
      emit(VTTCreateState(
        vtTransaction: vtTransaction,
        vttCreateStatus: VTTCreateStatus.finished,
        message: null,
      ));
    } catch (e) {
      print('Error signing the transaction :: $e');
      emit(state.copyWith(status: VTTCreateStatus.exception, message: '$e'));
      rethrow;
    }
  }

  /// send the transaction to the explorer
  Future<void> _sendVttTransactionEvent(
      SendTransactionEvent event, Emitter<VTTCreateState> emit) async {
    emit(state.copyWith(status: VTTCreateStatus.sending));
    ApiDatabase database = Locator.instance.get<ApiDatabase>();

    bool transactionAccepted =
        await _sendTransaction(Transaction(valueTransfer: event.transaction));

    if (transactionAccepted) {
      /// add pending transaction
      ///
      List<InputUtxo> _inputUtxoList = buildInputUtxoList();
      ValueTransferInfo vti = ValueTransferInfo(
          blockHash: '',
          fee: feeNanoWit,
          inputs: _inputUtxoList,
          outputs: outputs,
          priority: 1,
          status: 'pending',
          txnEpoch: -1,
          txnHash: event.transaction.transactionID,
          txnTime: DateTime.now().millisecondsSinceEpoch,
          type: 'ValueTransfer',
          weight: event.transaction.weight);

      /// add pending tx to database
      await database.addVtt(vti);

      /// update the accounts transaction list

      /// the inputs
      for (int i = 0; i < _inputUtxoList.length; i++) {
        InputUtxo inputUtxo = _inputUtxoList[i];
        Account account = database.walletStorage.currentWallet
            .accountByAddress(inputUtxo.address)!;
        account.vttHashes.add(event.transaction.transactionID);
        account.vtts.add(vti);
        await database.walletStorage.currentWallet.updateAccount(
          index: account.index,
          keyType: account.keyType,
          account: account,
        );
      }

      /// check outputs for accounts and update them
      for (int i = 0; i < outputs.length; i++) {
        ValueTransferOutput output = outputs[i];
        Account? account = database.walletStorage.currentWallet
            .accountByAddress(output.pkh.address);
        if (account != null) {
          account.vttHashes.add(event.transaction.transactionID);
          account.vtts.add(vti);
          await database.walletStorage.currentWallet.updateAccount(
            index: account.index,
            keyType: account.keyType,
            account: account,
          );
        }
      }

      emit(state.copyWith(status: VTTCreateStatus.accepted));
      List<Account> utxoListToUpdate = [];
      selectedUtxos.forEach((selectedUtxo) {
        event.currentWallet.externalAccounts.forEach((index, value) {
          if (value.utxos.contains(selectedUtxo)) {
            value.utxos.remove(selectedUtxo);
            utxoListToUpdate.add(value);
          }
        });

        event.currentWallet.internalAccounts.forEach((index, value) {
          if (value.utxos.contains(selectedUtxo)) {
            value.utxos.remove(selectedUtxo);
            utxoListToUpdate.add(value);
          }
        });
      });
      for (int i = 0; i < utxoListToUpdate.length; i++) {
        Account account = utxoListToUpdate[i];
        await Locator.instance<ApiDatabase>()
            .walletStorage
            .currentWallet
            .updateAccount(
                index: account.index,
                keyType: account.keyType,
                account: account);
      }
      await Locator.instance<ApiDatabase>().getWalletStorage(true);
      await database.updateCurrentWallet();
    } else {
      emit(state.copyWith(status: VTTCreateStatus.exception));
    }
  }

  void _updateFeeEvent(UpdateFeeEvent event, Emitter<VTTCreateState> emit) {
    if (event.feeNanoWit != null) {
      updateFee(event.feeType, event.feeNanoWit!);
    } else {
      updateFee(event.feeType);
    }
  }

  void _updateUtxoSelectionStrategyEvent(
      UpdateUtxoSelectionStrategyEvent event, Emitter<VTTCreateState> emit) {
    utxoSelectionStrategy = event.strategy;
  }

  Future<void> _addSourceWalletsEvent(
      AddSourceWalletsEvent event, Emitter<VTTCreateState> emit) async {
    await setWallet(event.currentWallet);
    emit(state.copyWith(
        inputs: inputs, outputs: outputs, status: VTTCreateStatus.building));
    try {
      await setEstimatedPriorities();
    } catch (err) {
      print('Error setting estimated priorities $err');
      emit(state.copyWith(status: VTTCreateStatus.exception));
      rethrow;
    }
  }

  void _resetTransactionEvent(
      ResetTransactionEvent event, Emitter<VTTCreateState> emit) {
    selectedUtxos.clear();
    inputs.clear();
    outputs.clear();
    receivers.clear();
    selectedTimelock = null;
    timelockSet = false;
    feeNanoWit = 0;
    emit(state.copyWith(status: VTTCreateStatus.initial));
  }

  void _validateTransactionEvent(
      ValidateTransactionEvent event, Emitter<VTTCreateState> emit) {
    /// ensure that the wallet has sufficient funds
    int utxoValueNanoWit = selectedUtxos
        .map((Utxo utxo) => utxo.value)
        .toList()
        .reduce((value, element) => value + element);
    int outputValueNanoWit = outputs
        .map((ValueTransferOutput output) => output.value.toInt())
        .toList()
        .reduce((value, element) => value + element);
    int feeValueNanoWit = feeNanoWit;
    if (utxoValueNanoWit <= (outputValueNanoWit + feeValueNanoWit)) {
      emit(state.copyWith(
          inputs: inputs, outputs: outputs, status: VTTCreateStatus.building));
    } else {
      emit(state.copyWith(
          status: VTTCreateStatus.exception, message: 'Insufficient Funds'));
    }
  }
}
