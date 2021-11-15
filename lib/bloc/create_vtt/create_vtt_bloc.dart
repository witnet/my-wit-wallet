import 'dart:isolate';

import 'package:bloc/bloc.dart';
import 'package:witnet/constants.dart';
import 'package:witnet/data_structures.dart';
import 'package:witnet/schema.dart';
import 'package:witnet/utils.dart';
import 'package:witnet_wallet/bloc/crypto/crypto_isolate.dart';
import 'package:witnet_wallet/bloc/explorer/api_explorer.dart';
import 'package:witnet_wallet/shared/api_database.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/util/witnet/wallet/account.dart';

abstract class CreateVTTEvent {}

class AddValueTransferOutputEvent extends CreateVTTEvent {
  final String pkh;
  final int value;
  final int timeLock;

  AddValueTransferOutputEvent({
    required this.pkh,
    required this.value,
    required this.timeLock,
  });
}

class UpdateFeeEvent extends CreateVTTEvent {
  final FeeType feeType;
  final int? feeNanoWit;
  UpdateFeeEvent({required this.feeType, this.feeNanoWit});
}

class UpdateUtxoSelectionStrategyEvent extends CreateVTTEvent {
  final UtxoSelectionStrategy strategy;
  final List<Utxo>? utxos;
  UpdateUtxoSelectionStrategyEvent({required this.strategy, this.utxos});
}

class AddUtxosEvent extends CreateVTTEvent {
  final List<Utxo> utxos;
  AddUtxosEvent({required this.utxos});
}

class AddAccountsEvent extends CreateVTTEvent {
  final Map<String, Account> externalAccounts;
  final Map<String, Account> internalAccounts;
  AddAccountsEvent(
      {required this.externalAccounts, required this.internalAccounts});
}

class ValidRecipientAddressEvent extends CreateVTTEvent {
  String address;
  ValidRecipientAddressEvent({required this.address});
}

class AddValueTransferInputEvent extends CreateVTTEvent {
  final Input input;
  AddValueTransferInputEvent({
    required this.input,
  });
}

class SignTransactionEvent extends CreateVTTEvent {
  final String password;
  final VTTransactionBody vtTransactionBody;
  SignTransactionEvent(
      {required this.password, required this.vtTransactionBody});
}

class SendTransactionEvent extends CreateVTTEvent {
  final VTTransaction transaction;
  SendTransactionEvent(this.transaction);
}

class ResetTransactionEvent extends CreateVTTEvent {}

abstract class CreateVTTState {}

class InitialState extends CreateVTTState {}

class BuildingVTTState extends CreateVTTState {
  final List<ValueTransferOutput> outputs;
  final List<Input> inputs;
  BuildingVTTState({required this.inputs, required this.outputs});
}

class SigningState extends CreateVTTState {}

class SendingState extends CreateVTTState {}

class FinishState extends CreateVTTState {
  final VTTransaction vtTransaction;
  FinishState({required this.vtTransaction});
}

class RecipientSetState extends CreateVTTState {}

class InputSetState extends CreateVTTState {}

class ErrorState extends CreateVTTState {
  final String errorMsg;
  ErrorState({required this.errorMsg});
}

class BlocCreateVTT extends Bloc<CreateVTTEvent, CreateVTTState> {
  BlocCreateVTT(initialState) : super(initialState);
  CreateVTTState get initialState => InitialState();
  final Map<String, Account> externalAccounts = {};
  final Map<String, Account> internalAccounts = {};
  final Map<String, Account> utxoAccountMap = {};
  List<ValueTransferOutput> outputs = [];
  List<String> receivers = [];
  List<Input> inputs = [];
  List<Utxo> utxos = [];
  List<Utxo> selectedUtxos = [];
  UtxoPool utxoPool = UtxoPool();
  FeeType feeType = FeeType.Weighted;
  int feeNanoWit = 0;
  UtxoSelectionStrategy utxoSelectionStrategy =
      UtxoSelectionStrategy.SmallFirst;
  @override
  Stream<CreateVTTState> mapEventToState(CreateVTTEvent event) async* {
    print(event.runtimeType);
    try {
      switch (event.runtimeType) {

        /// -----------------------------------------------------------------
        case AddValueTransferOutputEvent:
          event as AddValueTransferOutputEvent;

          // check to see if we already added a change address
          // if we did -> remove the change address and recompute
          for (int i = 0; i < outputs.length; i++) {
            if (internalAccounts.keys.contains(outputs[i].pkh.address)) {
              outputs.removeAt(i);
            }
          }

          // check to see if the address is already in the list.
          if (receivers.contains(event.pkh)) {
            // if the address is in the list add the value instead of
            // generating a new output
            outputs[receivers.indexOf(event.pkh)].value += event.value;
          } else {
            receivers.add(event.pkh);
            outputs.add(ValueTransferOutput.fromJson({
              'pkh': event.pkh,
              'value': event.value,
              'time_lock': event.timeLock,
            }));
          }

          selectedUtxos = utxoPool.selectUtxos(
              outputs: outputs, utxoStrategy: utxoSelectionStrategy);
          inputs.clear();

          int valueOwed = 0;
          int valuePaid = 0;
          int valueChange = 0;

          selectedUtxos.forEach((utxo) {
            inputs.add(utxo.toInput());
            valuePaid += utxo.value;
          });
          VTTransactionBody vtBody =
              VTTransactionBody(inputs: inputs, outputs: outputs);
          outputs.forEach((element) {
            valueOwed += element.value;
          });

          if (feeType == FeeType.Weighted) {
            // calculate weight
            int weight = (inputs.length * INPUT_SIZE) +
                (outputs.length * OUTPUT_SIZE * GAMMA);
            feeNanoWit = weight;

            valueChange = (valuePaid - valueOwed) - weight;

            if (valueChange > 0) {
              // add change
              // +1 to the outputs length to include for change address
              weight = (inputs.length * INPUT_SIZE) +
                  (outputs.length + 1 * OUTPUT_SIZE * GAMMA);
              valueChange = (valuePaid - valueOwed) - weight;
              bool changeAccountSet = false;
              outputs.add(ValueTransferOutput.fromJson({
                'pkh': internalAccounts.entries.first.value.address,
                'value': valueChange,
                'time_lock': 0,
              }));
            }
          } else {
            // feeType == Absolute
            valueChange = (valuePaid - valueOwed) - feeNanoWit;
            if (valueChange > 0) {
              outputs.add(ValueTransferOutput.fromJson({
                'pkh': internalAccounts.entries.first.value.address,
                'value': valueChange,
                'time_lock': 0,
              }));
            }
          }
          yield BuildingVTTState(inputs: inputs, outputs: outputs);
          break;

        /// -----------------------------------------------------------------
        case AddValueTransferInputEvent:
          event as AddValueTransferInputEvent;
          inputs.add(event.input);
          yield BuildingVTTState(inputs: inputs, outputs: outputs);
          break;

        /// -----------------------------------------------------------------
        case SignTransactionEvent:
          event as SignTransactionEvent;
          yield SigningState();
          var encryptedXprv = await Locator.instance<ApiDatabase>()
              .readDatabaseRecord(key: 'xprv', type: String) as String;
          try {
            CryptoIsolate cryptoIsolate = Locator.instance<CryptoIsolate>();

            final receivePort = ReceivePort();
            await cryptoIsolate.init();
            List<String> signers = [];
            selectedUtxos.forEach((element) {
              externalAccounts.forEach((key, value) {
                if (value.utxos.contains(element)) {
                  signers.add(value.path);
                }
              });
            });
            print(signers);
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
            VTTransaction vtTransaction = VTTransaction(
                body: event.vtTransactionBody, signatures: signatures);

            yield FinishState(vtTransaction: vtTransaction);
          } catch (e) {
            yield ErrorState(errorMsg: e.toString());
            rethrow;
          }

          break;

        /// -----------------------------------------------------------------

        case SendTransactionEvent:
          event as SendTransactionEvent;
          try {
            var resp = await Locator.instance
                .get<ApiExplorer>()
                .sendVtTransaction(event.transaction);
            print(resp);
          } catch (e) {}
          break;

        /// -----------------------------------------------------------------
        case UpdateFeeEvent:
          event as UpdateFeeEvent;
          feeType = event.feeType;
          switch (feeType) {
            case FeeType.Absolute:
              feeNanoWit = event.feeNanoWit!;
              break;
            case FeeType.Weighted:
              break;
          }

          break;

        /// -----------------------------------------------------------------
        case UpdateUtxoSelectionStrategyEvent:
          event as UpdateUtxoSelectionStrategyEvent;
          utxoSelectionStrategy = event.strategy;
          break;

        /// -----------------------------------------------------------------
        case ValidRecipientAddressEvent:
          break;

        /// -----------------------------------------------------------------
        case AddUtxosEvent:
          event as AddUtxosEvent;

          utxos.addAll(event.utxos);
          utxos.forEach((utxo) {
            utxoPool.insert(utxo);
          });
          utxoPool.sortUtxos(utxoSelectionStrategy);

          yield BuildingVTTState(inputs: inputs, outputs: outputs);
          break;

        /// -----------------------------------------------------------------
        case AddAccountsEvent:
          event as AddAccountsEvent;
          externalAccounts.addAll(event.externalAccounts);
          internalAccounts.addAll(event.internalAccounts);

          externalAccounts.forEach((key, value) {
            utxos.addAll(value.utxos);
          });
          internalAccounts.forEach((key, value) {
            utxos.addAll(value.utxos);
          });
          utxos.forEach((utxo) {
            utxoPool.insert(utxo);
          });
          utxoPool.sortUtxos(utxoSelectionStrategy);
          yield BuildingVTTState(inputs: inputs, outputs: outputs);
          break;

        /// -----------------------------------------------------------------
        case ResetTransactionEvent:
          selectedUtxos.clear();
          inputs.clear();
          outputs.clear();
          receivers.clear();
          yield BuildingVTTState(inputs: inputs, outputs: outputs);
          break;
      }
    } catch (e) {}
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
