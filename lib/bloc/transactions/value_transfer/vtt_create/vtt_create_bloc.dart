import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:witnet/constants.dart';
import 'package:witnet/data_structures.dart';
import 'package:witnet/schema.dart';
import 'package:witnet/utils.dart';
import 'package:witnet_wallet/bloc/crypto/api_crypto.dart';
import 'package:witnet_wallet/bloc/explorer/api_explorer.dart';
import 'package:witnet_wallet/screens/dashboard/api_dashboard.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/shared/api_database.dart';
import 'package:witnet_wallet/util/storage/database/wallet.dart';
import 'package:witnet_wallet/util/storage/database/account.dart';

part 'vtt_create_event.dart';
part 'vtt_create_state.dart';

/// send the transaction via the explorer.
/// returns true on success
Future<bool> _sendTransaction(VTTransaction transaction) async {
  try {
    var resp = await Locator.instance
        .get<ApiExplorer>()
        .sendVtTransaction(transaction);
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
    on<SendTransactionEvent>(_sendTransactionEvent);
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

  int getFee([int additionalOutputs = 0]) {
    switch (feeType) {
      case FeeType.Absolute:
        return feeNanoWit;
      case FeeType.Weighted:
        return (inputs.length * INPUT_SIZE) +
            (outputs.length + additionalOutputs * OUTPUT_SIZE * GAMMA);
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
                (selectedTimelock!.millisecondsSinceEpoch * 100);
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

  Future<Wallet> _setWalletBalance(Wallet dbWallet) async {
    /// setup the external accounts
    dbWallet.externalAccounts.forEach((index, account) {
      balanceNanoWit += account.balance().availableNanoWit;

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

    dbWallet.internalAccounts.forEach((index, account) {
      balanceNanoWit += account.balance().availableNanoWit;
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
    return dbWallet;
  }

  Future<void> setWallet(Wallet? newWalletStorage) async {
    if (newWalletStorage != null) {
      utxos.clear();
      this.currentWallet = newWalletStorage;
      balanceNanoWit = 0;
      Wallet currentWallet = await _setWalletBalance(this.currentWallet);
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
          firstWallet.name,
          KeyType.internal,
          internalAddresses.length + 1,
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
        print('Build transaction :: Insuficient funds');
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
                (selectedTimelock!.millisecondsSinceEpoch * 100);
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
      {required VTTransactionBody transactionBody,
      required Wallet currentWallet}) async {
    /// Read the encrypted XPRV string stored in the database
    Wallet walletStorage = currentWallet;
    ApiCrypto apiCrypto = Locator.instance<ApiCrypto>();
    try {
      List<KeyedSignature> signatures = await apiCrypto.signTransaction(
        selectedUtxos,
        walletStorage,
        bytesToHex(transactionBody.hash),
      );

      return VTTransaction(body: transactionBody, signatures: signatures);
    } catch (e) {
      rethrow;
    }
  }

  Map<String, List<String>> buildSignerMap() {
    Map<String, List<String>> _signers = {};

    /// loop through utxos
    for (int i = 0; i < selectedUtxos.length; i++) {
      Utxo currentUtxo = selectedUtxos.elementAt(i);

      Wallet currentWallet = Locator.instance.get<ApiDashboard>().currentWallet;

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

  /// sign the transaction
  Future<void> _signTransactionEvent(
      SignTransactionEvent event, Emitter<VTTCreateState> emit) async {
    emit(state.copyWith(status: VTTCreateStatus.signing));
    try {
      VTTransaction vtTransaction = await _signTransaction(
          transactionBody: event.vtTransactionBody,
          currentWallet: event.currentWallet);
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
  Future<void> _sendTransactionEvent(
      SendTransactionEvent event, Emitter<VTTCreateState> emit) async {
    emit(state.copyWith(status: VTTCreateStatus.sending));
    bool transactionAccepted = await _sendTransaction(event.transaction);

    if (transactionAccepted) {
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
        await Locator.instance<ApiDatabase>()
            .updateAccount(utxoListToUpdate[i]);
      }
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

  void _addSourceWalletsEvent(
      AddSourceWalletsEvent event, Emitter<VTTCreateState> emit) {
    setWallet(event.currentWallet);
    emit(state.copyWith(
        inputs: inputs, outputs: outputs, status: VTTCreateStatus.building));
  }

  void _resetTransactionEvent(
      ResetTransactionEvent event, Emitter<VTTCreateState> emit) {
    selectedUtxos.clear();
    inputs.clear();
    outputs.clear();
    receivers.clear();
    selectedTimelock = null;
    timelockSet = false;
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

class InputUtxo {
  InputUtxo({
    required this.address,
    required this.utxo,
    required this.value,
    required this.path,
  });
  final Utxo utxo;
  final String address;
  final String path;
  final int value;
}
