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
      {required this.vtTransaction,
      required this.vttCreateStatus,
      required this.message});

  final VTTCreateStatus vttCreateStatus;
  final VTTransaction vtTransaction;
  final String? message;
  VTTCreateState copyWith({
    List<Input>? inputs,
    List<ValueTransferOutput>? outputs,
    List<KeyedSignature>? signatures,
    VTTCreateStatus? status,
    String? message,
  }) {
    return VTTCreateState(
      vtTransaction: VTTransaction(
        body: VTTransactionBody(
          inputs: inputs ?? this.vtTransaction.body.inputs,
          outputs: outputs ?? this.vtTransaction.body.outputs,
        ),
        signatures: signatures ?? this.vtTransaction.signatures,
      ),
      vttCreateStatus: status ?? this.vttCreateStatus,
      message: message ?? this.message,
    );
  }

  @override
  List<Object> get props => [vtTransaction, vttCreateStatus];
}
