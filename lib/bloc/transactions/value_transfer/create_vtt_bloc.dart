import 'dart:isolate';

import 'package:bloc/bloc.dart';
import 'package:witnet/constants.dart';
import 'package:witnet/data_structures.dart';
import 'package:witnet/schema.dart';
import 'package:witnet/utils.dart';
import 'package:witnet_wallet/bloc/crypto/api_crypto.dart';
import 'package:witnet_wallet/bloc/crypto/crypto_isolate.dart';
import 'package:witnet_wallet/bloc/explorer/api_explorer.dart';
import 'package:witnet_wallet/shared/api_database.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/util/storage/database/db_wallet.dart';
import 'package:witnet_wallet/util/witnet/wallet/account.dart';
import 'package:witnet_wallet/util/witnet/wallet/wallet.dart';

abstract class CreateVTTEvent {}

class AddValueTransferOutputEvent extends CreateVTTEvent {
  final ValueTransferOutput output;
  AddValueTransferOutputEvent({required this.output});
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

class AddSourceWalletEvent extends CreateVTTEvent {
  final DbWallet dbWallet;
  AddSourceWalletEvent({required this.dbWallet});
}

class ValidRecipientAddressEvent extends CreateVTTEvent {
  String address;
  ValidRecipientAddressEvent({required this.address});
}

class AddValueTransferInputEvent extends CreateVTTEvent {
  final Input input;
  AddValueTransferInputEvent({required this.input});
}

class SignTransactionEvent extends CreateVTTEvent {
  final String password;
  final VTTransactionBody vtTransactionBody;
  SignTransactionEvent({
    required this.password,
    required this.vtTransactionBody
  });
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
  UtxoSelectionStrategy utxoSelectionStrategy =
      UtxoSelectionStrategy.SmallFirst;



  int getFee([int additionalOutputs=0]) {
    switch (feeType) {
      case FeeType.Absolute:
        return feeNanoWit;
      case FeeType.Weighted:
        return (inputs.length * INPUT_SIZE)
             + (outputs.length+additionalOutputs * OUTPUT_SIZE * GAMMA);
    }
  }

  void updateFee(FeeType newFeeType, [int feeNanoWit = 0]){
    feeType = newFeeType;
    switch (feeType) {
      case FeeType.Absolute:
        print('Absolute Fee: $feeNanoWit NanoWit.');
        this.feeNanoWit = feeNanoWit;
        break;
      case FeeType.Weighted:
        print('Weighted Fee: ${getFee()}');
        break;
    }
  }

  bool addOutput(ValueTransferOutput output, [bool merge=true]){
    try{
      if(merge){
        // check to see if the address is already in the list.
        if (receivers.contains(output.pkh)) {
          // if the address is in the list add the value instead of
          // generating a new output
          outputs[receivers.indexOf(output.pkh.address)].value += output.value;
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
    } catch (e){
      return false;
    }
  }

  void setSelectionStrategy(UtxoSelectionStrategy strategy){
    utxoSelectionStrategy = strategy;
  }

  Future<void> setDbWallet(DbWallet? newDbWallet) async{
    if(newDbWallet != null){
      this.dbWallet = newDbWallet;
      balanceNanoWit = 0;
      /// setup the external accounts
      externalAddresses.addAll(List<String>.
      from(dbWallet.externalAccounts.entries.map((e) => e.value.address)
      ));
      dbWallet.externalAccounts.forEach((index, account) {
        balanceNanoWit += account.balance;

        externalAddresses.add(account.address);


        utxos.addAll(account.utxos);
      });
      /// setup the internal accounts
      internalAddresses.addAll(List<String>.
      from(dbWallet.internalAccounts.entries.map((e) => e.value.address)
      ));
      dbWallet.internalAccounts.forEach((index, account) {
        balanceNanoWit += account.balance;
        internalAddresses.add(account.address);

        utxos.addAll(account.utxos);
      });
      /// get the internal account that will be used for any change
      bool changeAccountSet = false;
      for(int i = 0; i < internalAddresses.length-1; i++){
        if(!changeAccountSet){
          Account account = dbWallet.internalAccounts[i]!;
          if(account.vttHashes.isEmpty) {
            changeAccount = account;
            changeAccountSet = true;
          }
        }
      }
      /// did we run out of change addresses?
      if(!changeAccountSet){
        ApiCrypto apiCrypto = Locator.instance<ApiCrypto>();
        Account changeAccount = await apiCrypto.generateAccount(KeyType.internal, internalAddresses.length+1);
        print(changeAccount.address);
        //dbWallet.internalAccounts[internalAddresses.length+1] = changeAccount;
        //await Locator.instance<ApiDatabase>().saveDbWallet(dbWallet);
      }

      /// update the utxo pool
      utxos.forEach((utxo) {
        utxoPool.insert(utxo);
      });
      /// presort the utxo pool
      utxoPool.sortUtxos(utxoSelectionStrategy);
    }

  }

  void resetTransaction(){
    selectedUtxos.clear();
    inputs.clear();
    outputs.clear();
    receivers.clear();
  }

  VTTransactionBody buildTransactionBody(){

    int valueOwed = 0;
    int valuePaid = 0;
    int valueChange = 0;
    /// calculate value owed
    outputs.forEach((element) {
      valueOwed += element.value;
    });
    /// compare to balance
    print('Balance: $balanceNanoWit');
    if(balanceNanoWit < valueOwed){
      /// TODO:: throw insufficient funds exception
    } else {
      /// get utxos from the pool
      selectedUtxos = selectUtxos();
      /// sets the fee weighted and absolute
      feeNanoWit = getFee();
      valueOwed += feeNanoWit;
      /// convert utxo to input
      selectedUtxos.forEach((utxo) {
        inputs.add(utxo.toInput());
        /// track value
        valuePaid += utxo.value;
      });
    }

    if (feeType == FeeType.Weighted) {
      /// calculate change
      valueChange = (valuePaid - valueOwed);
      ///
      if (valueChange > 0) {
        // add change
        // +1 to the outputs length to include for change address
        feeNanoWit = getFee(1);
        valueChange = (valuePaid - valueOwed);
        outputs.add(ValueTransferOutput.fromJson({
          'pkh': changeAccount.address,
          'value': valueChange,
          'time_lock': 0,
        }));
      }

    } else {
      feeNanoWit = getFee();
      // feeType == Absolute
      valueChange = (valuePaid - valueOwed);
      if (valueChange > 0) {
        outputs.add(ValueTransferOutput.fromJson({
          'pkh': changeAccount.address,
          'value': valueChange,
          'time_lock': 0,
        }));
      }
    }
    return VTTransactionBody(inputs: inputs, outputs: outputs);
  }

  /// signTransaction
  ///
  Future<VTTransaction> signTransaction({
    required VTTransactionBody transactionBody,
    required String password
  }) async {
    /// Read the encrypted XPRV string stored in the database
    var encryptedXprv = await Locator.instance<ApiDatabase>().
      readDatabaseRecord(key: 'xprv', type: String) as String;

    try {
      CryptoIsolate cryptoIsolate = Locator.instance<CryptoIsolate>();

      final receivePort = ReceivePort();
      await cryptoIsolate.init();
      Map<String, int> signingRequirements = {};
      List<String> signers = [];

      selectedUtxos.forEach((selectedUtxo) {

        dbWallet.externalAccounts.forEach((index, value) {
          print('$index - ${value.address}');
          if (value.utxos.contains(selectedUtxo)) {
            print('adding signer: ${value.path}');

            if(signingRequirements.containsKey(value.path)){
              signingRequirements.update(value.path, (sigValue) => sigValue += 1);
            } else {
              signingRequirements[value.path] = 1;
            }
            signers.add(value.path);
          }
        });

        dbWallet.internalAccounts.forEach((index, value) {
          if (value.utxos.contains(selectedUtxo)) {

          }
          signers.add(value.path);
        });

      });
      print(signers);
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
/*
{"transaction":{"ValueTransfer":{"body":{"inputs":[{"output_pointer":"746e67940d78316afceef50966c7a133cce42e98098cf0ef9c74686b4b4125a7:0"}],"outputs":[{"pkh":"wit1597ry956a2rsc80ayye9w3rgckfwtasals6wv7","time_lock":0,"value":1000},{"pkh":"wit1ykpatn87jgahnzmlx647wtyarzurey8s6fh3ms","time_lock":0,"value":9998998}]},"signatures":[{"public_key":{"bytes":"7c2363370f0faac449b09a99d9170b096826d6389f7c486f694d82bb2135732d","compressed":2},"signature":{"Secp256k1":{"der":"30450221009aea587e049cfa6203fb7884ea2dc77c7b7577bb23269589aebc2da7b12af87102206864a4c92a78353e54f48135a1c79782c536c882786b362090bc5fdca5897cbc"}}}]}}}
 */
      return VTTransaction(
        body: transactionBody,
        signatures: signatures
      );

    } catch (e){
      rethrow;
    }
  }

  /// send the transaction via the explorer.
  /// returns true on success
  Future<bool> sendTransaction(VTTransaction transaction) async{
    try {
      var resp = await Locator.instance
          .get<ApiExplorer>()
          .sendVtTransaction(transaction);
      return resp['result'];
    } catch (e) {
      return false;
    }
  }

  List<Utxo> selectUtxos(){
    return utxoPool
      .selectUtxos(outputs: outputs, utxoStrategy: utxoSelectionStrategy);
  }

  @override
  Stream<CreateVTTState> mapEventToState(CreateVTTEvent event) async* {

    try {
      switch (event.runtimeType) {

        /// -----------------------------------------------------------------
        case AddValueTransferOutputEvent:
          event as AddValueTransferOutputEvent;
          addOutput(event.output);
          buildTransactionBody();
          yield BuildingVTTState(inputs: inputs, outputs: outputs);
          break;

        /// -----------------------------------------------------------------
        case AddValueTransferInputEvent:
          event as AddValueTransferInputEvent;
          inputs.add(event.input);
          yield BuildingVTTState(inputs: inputs, outputs: outputs);
          break;

        /// -----------------------------------------------------------------
        /// sign the transaction
        case SignTransactionEvent:
          event as SignTransactionEvent;
          yield SigningState();
          try{
            VTTransaction vtTransaction = await signTransaction(
                transactionBody: event.vtTransactionBody,
                password: event.password
            );

            yield FinishState(vtTransaction: vtTransaction);
          } catch (e) {
            yield ErrorState(errorMsg: e.toString());
            rethrow;
          }

          break;

        /// -----------------------------------------------------------------

        case SendTransactionEvent:
          event as SendTransactionEvent;
          bool transactionAccepted = await sendTransaction(event.transaction);
          print(transactionAccepted);
          break;

        /// -----------------------------------------------------------------
        case UpdateFeeEvent:
          event as UpdateFeeEvent;
          if (event.feeNanoWit != null) {
            updateFee(event.feeType, event.feeNanoWit!);
          }else{
            updateFee(event.feeType);
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
        case AddSourceWalletEvent:
          event as AddSourceWalletEvent;
          setDbWallet(event.dbWallet);
          yield BuildingVTTState(inputs: inputs, outputs: outputs);
          break;
        /// -----------------------------------------------------------------
        case ResetTransactionEvent:
          resetTransaction();
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
