part of 'vtt_create_bloc.dart';

class VTTCreateEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddValueTransferOutputEvent extends VTTCreateEvent {
  final ValueTransferOutput output;
  final bool merge;
  AddValueTransferOutputEvent({required this.output, required this.merge});
  @override
  List<Object?> get props => [output, merge];
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
  final WalletStorage walletStorage;
  AddSourceWalletsEvent({required this.walletStorage});
  @override
  List<Object?> get props => [walletStorage];
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
  final String password;
  final VTTransactionBody vtTransactionBody;
  SignTransactionEvent(
      {required this.password, required this.vtTransactionBody});

  @override
  List<Object?> get props => [password, vtTransactionBody];
}

class SendTransactionEvent extends VTTCreateEvent {
  final VTTransaction transaction;
  SendTransactionEvent(this.transaction);
  @override
  List<Object?> get props => [transaction];
}

class ResetTransactionEvent extends VTTCreateEvent {}
