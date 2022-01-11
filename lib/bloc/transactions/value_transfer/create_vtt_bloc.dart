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

class BuildTransactionEvent extends CreateVTTEvent {}

class ValidateTransactionEvent extends CreateVTTEvent {}

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
class BusyState extends CreateVTTState {}

class SigningState extends CreateVTTState {}

class SendingState extends CreateVTTState {}
class TransactionAcceptedState extends CreateVTTState {
  final VTTransaction vtTransaction;
  TransactionAcceptedState({required this.vtTransaction});
}
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
        // print('Absolute Fee: $feeNanoWit NanoWit.');
        this.feeNanoWit = feeNanoWit;
        break;
      case FeeType.Weighted:
        // print('Weighted Fee: ${getFee()}');
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
      utxos.clear();
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

  void resetTransaction(){
    selectedUtxos.clear();
    inputs.clear();
    outputs.clear();
    receivers.clear();
  }

  void buildTransactionBody(){

    int valueOwedNanoWit = 0;
    int valuePaidNanoWit = 0;
    int valueChangeNanoWit = 0;


    try {

      /// calculate value owed
      outputs.map((e) => null);

      bool containsChangeAddress = false;
      int changeIndex = 0 ;
      int outIdx = 0;
      outputs.forEach((element) {
        if (element.pkh.address == changeAccount.address) {
          /// check if a change address is already in the outputs
          containsChangeAddress = true;
          changeIndex = outIdx;
        }
        outIdx += 1;
      });

      if(containsChangeAddress) {
        
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
        selectedUtxos = utxoPool.cover(amountNanoWit: valueOwedNanoWit, utxoStrategy: utxoSelectionStrategy);

        // print('Selected UTXOS: ${List<String>.from(selectedUtxos.map((e) => e.outputPointer.rawJson))}');




        /// convert utxo to input
        /// '
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
    } catch(e) {
      rethrow;
    }
  }

  /// signTransaction
  /// transactionBody [VTTransactionBody]
  /// password [String]
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

      // print(List<String>.from(selectedUtxos.map((e) => e.outputPointer.rawJson)));
      selectedUtxos.forEach((selectedUtxo) {

        dbWallet.externalAccounts.forEach((index, value) {
          if (value.utxos.contains(selectedUtxo)) {
            // print('adding signer: ${value.path} ${value.address} for ${selectedUtxo.outputPointer.rawJson}');
            signers.add(value.path);
          }
        });

        dbWallet.internalAccounts.forEach((index, value) {
          if (value.utxos.contains(selectedUtxo)) {
          signers.add(value.path);
          // print('adding signer: ${value.path} ${value.address} for ${selectedUtxo.outputPointer.rawJson}');
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

        /// 
        case AddValueTransferOutputEvent:
          event as AddValueTransferOutputEvent;
          yield BusyState();
          addOutput(event.output);
          buildTransactionBody();
          yield BuildingVTTState(inputs: inputs, outputs: outputs);
          break;

        ///
          
        /// 

          

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

        /// 

        case SendTransactionEvent:
          event as SendTransactionEvent;
          yield(SendingState());
          bool transactionAccepted = await sendTransaction(event.transaction);

          if(transactionAccepted){
            yield TransactionAcceptedState(vtTransaction: event.transaction);
          } else {
            yield ErrorState(errorMsg: 'Error Sending Transaction');
          }
          break;

        /// 
        case UpdateFeeEvent:
          event as UpdateFeeEvent;
          if (event.feeNanoWit != null) {
            updateFee(event.feeType, event.feeNanoWit!);
          }else{
            updateFee(event.feeType);
          }
          break;

        /// 
        case UpdateUtxoSelectionStrategyEvent:
          event as UpdateUtxoSelectionStrategyEvent;
          utxoSelectionStrategy = event.strategy;
          break;

        /// 
        case ValidRecipientAddressEvent:
          break;

        /// 
        case AddSourceWalletEvent:
          event as AddSourceWalletEvent;
          setDbWallet(event.dbWallet);
          yield BuildingVTTState(inputs: inputs, outputs: outputs);
          break;
        /// 
        case ResetTransactionEvent:
          resetTransaction();
          yield BuildingVTTState(inputs: inputs, outputs: outputs);
          break;

        case ValidateTransactionEvent:
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
          int walletBalanceNanoWit = dbWallet.balanceNanoWit();

          if(walletBalanceNanoWit<=(outputValueNanoWit + feeValueNanoWit)){
            yield BuildingVTTState(inputs: inputs, outputs: outputs);
          } else {
            yield ErrorState(errorMsg: 'Insufficient Funds');
          }

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
