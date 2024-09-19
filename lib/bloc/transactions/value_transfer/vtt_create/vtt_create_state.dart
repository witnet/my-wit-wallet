part of 'vtt_create_bloc.dart';

enum VTTCreateStatus {
  initial,
  needPasswordValidation,
  insufficientFunds,
  building,
  busy,
  signing,
  sending,
  accepted,
  finished,
  recipientSet,
  inputSet,
  exception,
  explorerException,
  discarded,
}

class VTTCreateState extends Equatable {
  VTTCreateState(
      {required this.transaction,
      required this.transactionType,
      required this.vttCreateStatus,
      required this.message});

  final VTTCreateStatus vttCreateStatus;
  final BuildTransaction transaction;
  final layout.TransactionType transactionType;
  final String? message;
  VTTCreateState copyWith({
    List<Input>? inputs,
    List<ValueTransferOutput>? outputs,
    List<KeyedSignature>? signatures,
    layout.TransactionType? transactionType,
    VTTCreateStatus? status,
    String? message,
  }) {
    layout.TransactionType txType = transactionType ?? this.transactionType;
    return VTTCreateState(
      transaction: BuildTransaction(
          vtTransaction: VTTransaction(
            body: VTTransactionBody(
              inputs: inputs ?? this.transaction.vtTransaction?.body.inputs,
              outputs: outputs ?? this.transaction.vtTransaction?.body.outputs,
            ),
            signatures:
                signatures ?? this.transaction.vtTransaction?.signatures,
          ),
          stakeTransaction: StakeTransaction(
              body: StakeBody(
                  change: this.transaction.stakeTransaction?.body.change,
                  inputs: this.transaction.stakeTransaction?.body.inputs,
                  output: this.transaction.stakeTransaction?.body.output)),
          unstakeTransaction: UnstakeTransaction(
              body: UnstakeBody(
                  operator: this.transaction.unstakeTransaction?.body.operator,
                  withdrawal:
                      this.transaction.unstakeTransaction?.body.withdrawal),
              signature: this.transaction.unstakeTransaction?.signature)),
      vttCreateStatus: status ?? this.vttCreateStatus,
      transactionType: txType,
      message: message ?? this.message,
    );
  }

  @override
  List<Object> get props => [transaction, vttCreateStatus];
}
