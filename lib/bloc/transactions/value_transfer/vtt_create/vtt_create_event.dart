part of 'vtt_create_bloc.dart';

class VTTCreateEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddValueTransferOutputEvent extends VTTCreateEvent {
  final ValueTransferOutput output;
  final Wallet currentWallet;
  final bool merge;
  final GeneralTransaction? speedUpTx;
  final bool filteredUtxos;
  AddValueTransferOutputEvent(
      {required this.output,
      required this.currentWallet,
      required this.merge,
      this.speedUpTx,
      this.filteredUtxos = true});
  @override
  List<Object?> get props => [output, currentWallet, merge];
}

class AddStakeOutputEvent extends VTTCreateEvent {
  final String withdrawer;
  final String authorization;
  final int value;
  final Wallet currentWallet;
  final bool merge;
  final bool filteredUtxos;
  AddStakeOutputEvent(
      {required this.authorization,
      required this.withdrawer,
      required this.currentWallet,
      required this.value,
      required this.merge,
      this.filteredUtxos = true});
  @override
  List<Object?> get props =>
      [currentWallet, authorization, withdrawer, value, merge];
}

class PrepareSpeedUpTxEvent extends VTTCreateEvent {
  final ValueTransferOutput output;
  final Wallet currentWallet;
  final bool merge;
  final GeneralTransaction? speedUpTx;
  final bool filteredUtxos;
  PrepareSpeedUpTxEvent(
      {required this.output,
      required this.currentWallet,
      required this.merge,
      this.speedUpTx,
      this.filteredUtxos = true});
  @override
  List<Object?> get props => [output, currentWallet, merge];
}

class UpdateFeeEvent extends VTTCreateEvent {
  final FeeType feeType;
  final int? feeNanoWit;
  final EstimatedFeeOptions feeOption;
  UpdateFeeEvent(
      {required this.feeType, this.feeNanoWit, required this.feeOption});
  @override
  List<Object?> get props => [feeType, feeNanoWit, feeOption];
}

class SetTimelockEvent extends VTTCreateEvent {
  final DateTime dateTime;
  SetTimelockEvent({required this.dateTime});
  @override
  List<Object?> get props => [dateTime];
}

class SetBuildingEvent extends VTTCreateEvent {
  SetBuildingEvent();
  @override
  List<Object?> get props => [];
}

class UpdateUtxoSelectionStrategyEvent extends VTTCreateEvent {
  final UtxoSelectionStrategy strategy;
  final List<Utxo>? utxos;
  UpdateUtxoSelectionStrategyEvent({required this.strategy, this.utxos});
  @override
  List<Object?> get props => [strategy, utxos];
}

class AddUtxosEvent extends VTTCreateEvent {
  final List<Utxo> utxos;
  AddUtxosEvent({required this.utxos});
  @override
  List<Object?> get props => [utxos];
}

class AddSourceWalletsEvent extends VTTCreateEvent {
  final Wallet currentWallet;
  AddSourceWalletsEvent({required this.currentWallet});
  @override
  List<Object?> get props => [currentWallet];
}

class SetPriorityEstimationsEvent extends VTTCreateEvent {
  SetPriorityEstimationsEvent();
  @override
  List<Object?> get props => [];
}

class SetTransactionTypeEvent extends VTTCreateEvent {
  final layout.TransactionType transactionType;
  SetTransactionTypeEvent({required this.transactionType});
  @override
  List<Object?> get props => [transactionType];
}

class ValidRecipientAddressEvent extends VTTCreateEvent {
  final String address;
  ValidRecipientAddressEvent({required this.address});
  @override
  List<Object?> get props => [address];
}

class AddValueTransferInputEvent extends VTTCreateEvent {
  final Input input;
  AddValueTransferInputEvent({required this.input});

  @override
  List<Object?> get props => [input];
}

class BuildTransactionEvent extends VTTCreateEvent {}

class ShowAuthPreferencesEvent extends VTTCreateEvent {}

class SignTransactionEvent extends VTTCreateEvent {
  final TransactionBody transactionBody;
  final Wallet currentWallet;
  final GeneralTransaction? speedUpTx;
  SignTransactionEvent({
    required this.currentWallet,
    required this.transactionBody,
    this.speedUpTx,
  });

  @override
  List<Object?> get props => [currentWallet, transactionBody, speedUpTx];
}

class SendTransactionEvent extends VTTCreateEvent {
  final BuildTransaction transaction;
  final Wallet currentWallet;
  final GeneralTransaction? speedUpTx;
  SendTransactionEvent(
      {required this.currentWallet, required this.transaction, this.speedUpTx});
  @override
  List<Object?> get props => [currentWallet, transaction];
}

class ResetTransactionEvent extends VTTCreateEvent {}
