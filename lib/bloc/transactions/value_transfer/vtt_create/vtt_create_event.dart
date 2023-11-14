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

class InitializeTransactionEvent extends VTTCreateEvent {
  InitializeTransactionEvent();
  @override
  List<Object?> get props => [];
}

class SetPriorityEstimationsEvent extends VTTCreateEvent {
  SetPriorityEstimationsEvent();
  @override
  List<Object?> get props => [];
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

class ValidateTransactionEvent extends VTTCreateEvent {}

class ShowAuthPreferencesEvent extends VTTCreateEvent {}

class SignTransactionEvent extends VTTCreateEvent {
  final GeneralTransaction? speedUpTx;
  SignTransactionEvent({
    this.speedUpTx,
  });

  @override
  List<Object?> get props => [speedUpTx];
}

class SendTransactionEvent extends VTTCreateEvent {
  SendTransactionEvent();

  @override
  List<Object?> get props => [];
}

class ResetTransactionEvent extends VTTCreateEvent {}
