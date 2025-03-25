part of 'vtt_create_bloc.dart';

class TransactionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddValueTransferOutputEvent extends TransactionEvent {
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

class AddUnstakeOutputEvent extends TransactionEvent {
  final ValueTransferOutput output;
  final String validator;
  final Wallet currentWallet;
  AddUnstakeOutputEvent({
    required this.output,
    required this.validator,
    required this.currentWallet,
  });
  @override
  List<Object?> get props => [output, currentWallet, validator];
}

class AddStakeOutputEvent extends TransactionEvent {
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

class PrepareSpeedUpTxEvent extends TransactionEvent {
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

class UpdateFeeEvent extends TransactionEvent {
  final FeeType feeType;
  final int? feeNanoWit;
  final EstimatedFeeOptions feeOption;
  UpdateFeeEvent(
      {required this.feeType, this.feeNanoWit, required this.feeOption});
  @override
  List<Object?> get props => [feeType, feeNanoWit, feeOption];
}

class SetTimelockEvent extends TransactionEvent {
  final DateTime dateTime;
  SetTimelockEvent({required this.dateTime});
  @override
  List<Object?> get props => [dateTime];
}

class SetBuildingEvent extends TransactionEvent {
  SetBuildingEvent();
  @override
  List<Object?> get props => [];
}

class UpdateUtxoSelectionStrategyEvent extends TransactionEvent {
  final UtxoSelectionStrategy strategy;
  final List<Utxo>? utxos;
  UpdateUtxoSelectionStrategyEvent({required this.strategy, this.utxos});
  @override
  List<Object?> get props => [strategy, utxos];
}

class AddUtxosEvent extends TransactionEvent {
  final List<Utxo> utxos;
  AddUtxosEvent({required this.utxos});
  @override
  List<Object?> get props => [utxos];
}

class AddSourceWalletsEvent extends TransactionEvent {
  final Wallet currentWallet;
  AddSourceWalletsEvent({required this.currentWallet});
  @override
  List<Object?> get props => [currentWallet];
}

class SetPriorityEstimationsEvent extends TransactionEvent {
  SetPriorityEstimationsEvent();
  @override
  List<Object?> get props => [];
}

class SetTransactionTypeEvent extends TransactionEvent {
  final layout.TransactionType transactionType;
  SetTransactionTypeEvent({required this.transactionType});
  @override
  List<Object?> get props => [transactionType];
}

class ValidRecipientAddressEvent extends TransactionEvent {
  final String address;
  ValidRecipientAddressEvent({required this.address});
  @override
  List<Object?> get props => [address];
}

class AddValueTransferInputEvent extends TransactionEvent {
  final Input input;
  AddValueTransferInputEvent({required this.input});

  @override
  List<Object?> get props => [input];
}

class BuildTransactionEvent extends TransactionEvent {}

class ShowAuthPreferencesEvent extends TransactionEvent {}

class SignTransactionEvent extends TransactionEvent {
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

class SendTransactionEvent extends TransactionEvent {
  final BuildTransaction transaction;
  final Wallet currentWallet;
  final GeneralTransaction? speedUpTx;
  SendTransactionEvent(
      {required this.currentWallet, required this.transaction, this.speedUpTx});
  @override
  List<Object?> get props => [currentWallet, transaction];
}

class ResetTransactionEvent extends TransactionEvent {}
