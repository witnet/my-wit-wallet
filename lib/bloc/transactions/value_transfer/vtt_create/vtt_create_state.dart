part of 'vtt_create_bloc.dart';

enum TransactionStatus {
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

class TransactionState extends Equatable {
  TransactionState(
      {required this.transaction,
      required this.transactionType,
      required this.transactionStatus,
      required this.message});

  final TransactionStatus transactionStatus;
  final BuildTransaction transaction;
  final layout.TransactionType transactionType;
  final String? message;
  TransactionState copyWith({
    List<Input>? inputs,
    List<ValueTransferOutput>? outputs,
    ValueTransferOutput? withdrawal,
    KeyedSignature? signature,
    List<KeyedSignature>? signatures,
    PublicKeyHash? operator,
    ValueTransferOutput? change,
    StakeOutput? stakeOutput,
    layout.TransactionType? transactionType,
    TransactionStatus? status,
    String? message,
  }) {
    return TransactionState(
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
                change:
                    change ?? this.transaction.stakeTransaction?.body.change,
                inputs:
                    inputs ?? this.transaction.stakeTransaction?.body.inputs,
                output: stakeOutput ??
                    this.transaction.stakeTransaction?.body.output),
            signatures:
                signatures ?? this.transaction.stakeTransaction?.signatures,
          ),
          unstakeTransaction: UnstakeTransaction(
              body: UnstakeBody(
                  operator: operator ??
                      this.transaction.unstakeTransaction?.body.operator,
                  nonce:
                      this.transaction.unstakeTransaction?.body.nonce.toInt(),
                  withdrawal: withdrawal ??
                      this.transaction.unstakeTransaction?.body.withdrawal),
              signature:
                  signature ?? this.transaction.unstakeTransaction?.signature)),
      transactionStatus: status ?? this.transactionStatus,
      transactionType: transactionType ?? this.transactionType,
      message: message ?? this.message,
    );
  }

  @override
  List<Object> get props => [transaction, transactionStatus];
}
