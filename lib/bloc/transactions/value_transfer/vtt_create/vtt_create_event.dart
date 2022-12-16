part of 'vtt_create_bloc.dart';

class VTTCreateEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddValueTransferOutputEvent extends VTTCreateEvent {
  final ValueTransferOutput output;
  final Wallet currentWallet;
  final bool merge;
  AddValueTransferOutputEvent(
      {required this.output, required this.currentWallet, required this.merge});
  @override
  List<Object?> get props => [output, currentWallet, merge];
}

class UpdateFeeEvent extends VTTCreateEvent {
  final FeeType feeType;
  final int? feeNanoWit;
  UpdateFeeEvent({required this.feeType, this.feeNanoWit});
  @override
  List<Object?> get props => [feeType, feeNanoWit];
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

class AddSourceWalletsEvent extends VTTCreateEvent {
  final Wallet currentWallet;
  AddSourceWalletsEvent({required this.currentWallet});
  @override
  List<Object?> get props => [currentWallet];
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

class SignTransactionEvent extends VTTCreateEvent {
  final VTTransactionBody vtTransactionBody;
  final Wallet currentWallet;
  SignTransactionEvent(
      {required this.currentWallet, required this.vtTransactionBody});

  @override
  List<Object?> get props => [currentWallet, vtTransactionBody];
}

class SendTransactionEvent extends VTTCreateEvent {
  final VTTransaction transaction;
  final Wallet currentWallet;
  SendTransactionEvent(
      {required this.currentWallet, required this.transaction});
  @override
  List<Object?> get props => [currentWallet, transaction];
}

class ResetTransactionEvent extends VTTCreateEvent {}
