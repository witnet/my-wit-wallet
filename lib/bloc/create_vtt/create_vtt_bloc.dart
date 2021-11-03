import 'dart:isolate';

import 'package:bloc/bloc.dart';
import 'package:witnet/constants.dart';
import 'package:witnet/data_structures.dart';
import 'package:witnet/schema.dart';
import 'package:witnet/utils.dart';
import 'package:witnet_wallet/bloc/crypto/crypto_isolate.dart';
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

class UpdateFeeTypeEvent extends CreateVTTEvent {
  final FeeType feeType;
  UpdateFeeTypeEvent({required this.feeType});
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

class ResetTransactionEvent extends CreateVTTEvent {}

abstract class CreateVTTState {}

class InitialState extends CreateVTTState {}

class BuildingVTTState extends CreateVTTState {
  final List<ValueTransferOutput> outputs;
  final List<Input> inputs;
  BuildingVTTState({required this.inputs, required this.outputs});
}

class SubmittingState extends CreateVTTState {}

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
          print('${event.pkh} ${event.value}');

          // check to see if we already added a change address
          // if we did -> remove the change address and recompute
          for (int i = 0; i < outputs.length; i++) {
            print('output addr: ${outputs[i].pkh.address}');

            if (internalAccounts.keys.contains(outputs[i].pkh.address)) {
              print('removing change addr ${outputs[i].pkh}');
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
            print(
                'pkk: ${event.pkh}\nvalue: ${event.value}\n timelock: ${event.timeLock}');
            outputs.add(ValueTransferOutput.fromJson({
              'pkh': event.pkh,
              'value': event.value,
              'time_lock': event.timeLock,
            }));
          }

          outputs.forEach((element) {
            print(element.jsonMap());
          });
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
            int weight = (inputs.length * INPUT_SIZE) +
                (outputs.length + 1 * OUTPUT_SIZE * GAMMA);
            valueChange = (valuePaid - valueOwed) - weight;

            if (valueChange > 0) {
              print('add change');
              weight = (inputs.length * INPUT_SIZE) +
                  (outputs.length + 1 * OUTPUT_SIZE * GAMMA);
              valueChange = (valuePaid - valueOwed) - weight;
              bool changeAccountSet = false;
              print('Change: $valueChange');
              print(internalAccounts.length);
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
          yield SubmittingState();
          print(event.vtTransactionBody.toRawJson());
          var encryptedXprv = await Locator.instance<ApiDatabase>()
              .readDatabaseRecord(key: 'xprv', type: String) as String;
          print(encryptedXprv);

          try {
            CryptoIsolate cryptoIsolate = Locator.instance<CryptoIsolate>();

            final receivePort = ReceivePort();
            await cryptoIsolate.init();
            List<String> signers = [];
            selectedUtxos.forEach((element) {
              externalAccounts.forEach((key, value) {
                if (value.utxos.contains(element)) {
                  print('add signer ${value.address} ${value.path}');
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
              print(value.runtimeType);
            });
            VTTransaction vtTransaction = VTTransaction(
                body: event.vtTransactionBody, signatures: signatures);

            print(vtTransaction.jsonMap(asHex: true));

            yield FinishState(vtTransaction: vtTransaction);
          } catch (e) {
            print(e);
            yield ErrorState(errorMsg: e.toString());
            rethrow;
          }

          break;

        /// -----------------------------------------------------------------
        case UpdateFeeTypeEvent:
          event as UpdateFeeTypeEvent;

          break;

        /// -----------------------------------------------------------------
        case ValidRecipientAddressEvent:

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