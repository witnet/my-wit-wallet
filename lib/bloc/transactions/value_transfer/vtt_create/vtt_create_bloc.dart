import 'dart:isolate';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:witnet/constants.dart';
import 'package:witnet/data_structures.dart';
import 'package:witnet/schema.dart';
import 'package:witnet/utils.dart';
import 'package:witnet_wallet/bloc/crypto/api_crypto.dart';
import 'package:witnet_wallet/bloc/crypto/crypto_bloc.dart';
import 'package:witnet_wallet/bloc/explorer/api_explorer.dart';
import 'package:witnet_wallet/shared/api_database.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/util/storage/database/db_wallet.dart';
import 'package:witnet_wallet/util/witnet/wallet/account.dart';
import 'package:witnet_wallet/util/witnet/wallet/wallet.dart';

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
    on<AddSourceWalletEvent>(_addSourceWalletEvent);
    on<ResetTransactionEvent>(_resetTransactionEvent);
    on<ValidateTransactionEvent>(_validateTransactionEvent);

    ///
  }

  final Map<String, Account> utxoAccountMap = {};
  late DbWallet dbWallet;
  List<String> internalAddresses = [];
  List<String> externalAddresses = [];
  late Account changeAccount;
  List<ValueTransferOutput> outputs = [];
  List<String> receivers = [];
  List<Input> inputs = [];
  List<Utxo> utxos = [];
  List<Utxo> selectedUtxos = [];
  UtxoPool utxoPool = UtxoPool();
  FeeType feeType = FeeType.Weighted;
  int feeNanoWit = 0;
  int balanceNanoWit = 0;
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
                selectedTimelock!.millisecondsSinceEpoch * 100;
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

  Future<void> setDbWallet(DbWallet? newDbWallet) async {
    if (newDbWallet != null) {
      utxos.clear();
      this.dbWallet = newDbWallet;
      balanceNanoWit = 0;

      /// setup the external accounts

      dbWallet.externalAccounts.forEach((index, account) {
        // balanceNanoWit += account.balance;

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
        balanceNanoWit += account.balance;
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

      /// get the internal account that will be used for any change
      bool changeAccountSet = false;
      for (int i = 0; i < internalAddresses.length - 1; i++) {
        if (!changeAccountSet) {
          Account account = dbWallet.internalAccounts[i]!;
          if (account.vttHashes.isEmpty) {
            changeAccount = account;
            changeAccountSet = true;
          }
        }
      }

      /// did we run out of change addresses?
      if (!changeAccountSet) {
        ApiCrypto apiCrypto = Locator.instance<ApiCrypto>();
        Account changeAccount = await apiCrypto.generateAccount(
            KeyType.internal, internalAddresses.length + 1);
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

  void buildTransactionBody() {
    int valueOwedNanoWit = 0;
    int valuePaidNanoWit = 0;
    int valueChangeNanoWit = 0;

    try {
      /// calculate value owed

      bool containsChangeAddress = false;
      int changeIndex = 0;
      int outIdx = 0;
      outputs.forEach((element) {
        if (element.pkh.address == changeAccount.address) {
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
        valueOwedNanoWit += element.value;
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
        ///
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
            'pkh': changeAccount.address,
            'value': valueChangeNanoWit,
            'time_lock': 0,
          }));
        }
      } else {
        feeNanoWit = getFee();
        valueChangeNanoWit = (valuePaidNanoWit - valueOwedNanoWit);
        if (valueChangeNanoWit > 0) {
          outputs.add(ValueTransferOutput.fromJson({
            'pkh': changeAccount.address,
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
                selectedTimelock!.millisecondsSinceEpoch * 100;
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
    buildTransactionBody();

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
      required String password}) async {
    /// Read the encrypted XPRV string stored in the database
    var encryptedXprv = await Locator.instance<ApiDatabase>()
        .readDatabaseRecord(key: 'xprv', type: String) as String;

    try {
      CryptoIsolate cryptoIsolate = Locator.instance<CryptoIsolate>();

      final receivePort = ReceivePort();
      await cryptoIsolate.init();
      Map<String, int> signingRequirements = {};
      List<String> signers = [];

      selectedUtxos.forEach((selectedUtxo) {
        dbWallet.externalAccounts.forEach((index, value) {
          if (value.utxos.contains(selectedUtxo)) {
            signers.add(value.path);
          }
        });

        dbWallet.internalAccounts.forEach((index, value) {
          if (value.utxos.contains(selectedUtxo)) {
            signers.add(value.path);
          }
        });
      });
      cryptoIsolate.send(
          method: 'signTransaction',
          params: {
            'xprv': encryptedXprv,
            'password': password,
            'signers': signers,
            'transaction_id': bytesToHex(transactionBody.hash)
          },
          port: receivePort.sendPort);
      List<KeyedSignature> signatures = [];

      await receivePort.first.then((value) {
        value as List<dynamic>;
        value.forEach((element) {
          signatures.add(KeyedSignature.fromJson(element));
        });
      });

      return VTTransaction(body: transactionBody, signatures: signatures);
    } catch (e) {
      rethrow;
    }
  }

  /// sign the transaction
  Future<void> _signTransactionEvent(
      SignTransactionEvent event, Emitter<VTTCreateState> emit) async {
    emit(state.copyWith(status: VTTCreateStatus.signing));
    try {
      /// Read the encrypted XPRV string stored in the database
      var encryptedXprv = await Locator.instance<ApiDatabase>()
          .readDatabaseRecord(key: 'xprv', type: String) as String;

      try {
        CryptoIsolate cryptoIsolate = Locator.instance<CryptoIsolate>();

        final receivePort = ReceivePort();
        await cryptoIsolate.init();
        Map<String, int> signingRequirements = {};
        List<String> signers = [];

        selectedUtxos.forEach((selectedUtxo) {
          dbWallet.externalAccounts.forEach((index, value) {
            if (value.utxos.contains(selectedUtxo)) {
              signers.add(value.path);
            }
          });

          dbWallet.internalAccounts.forEach((index, value) {
            if (value.utxos.contains(selectedUtxo)) {
              signers.add(value.path);
            }
          });
        });
        cryptoIsolate.send(
            method: 'signTransaction',
            params: {
              'xprv': encryptedXprv,
              'password': event.password,
              'signers': signers,
              'transaction_id': bytesToHex(event.vtTransactionBody.hash)
            },
            port: receivePort.sendPort);
        List<KeyedSignature> signatures = [];

        await receivePort.first.then((value) {
          value as List<dynamic>;
          value.forEach((element) {
            signatures.add(KeyedSignature.fromJson(element));
          });
        });

        VTTransaction vtTransaction = await _signTransaction(
            transactionBody: event.vtTransactionBody, password: event.password);

        emit(VTTCreateState(
            vtTransaction: vtTransaction,
            vttCreateStatus: VTTCreateStatus.finished,
            message: null));
      } catch (e) {
        emit(
          state.copyWith(status: VTTCreateStatus.exception, message: '$e'),
        );
        rethrow;
      }
    } catch (e) {
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

  void _addSourceWalletEvent(
      AddSourceWalletEvent event, Emitter<VTTCreateState> emit) {
    setDbWallet(event.dbWallet);
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
        .map((ValueTransferOutput output) => output.value)
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
