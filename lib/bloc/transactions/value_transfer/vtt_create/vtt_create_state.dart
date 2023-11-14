part of 'vtt_create_bloc.dart';

enum VTTCreateStatus {
  initial,
  needPasswordValidation,
  building,
  busy,
  signing,
  sending,
  accepted,
  finished,
  exception,
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
    VTTransaction? vtTransaction,
  }) {
    return VTTCreateState(
      vtTransaction: VTTransaction(
        body: VTTransactionBody(
          inputs: inputs ?? this.vtTransaction.body.inputs,
          outputs: outputs ?? this.vtTransaction.body.outputs,
        ),
        signatures: vtTransaction?.signatures ?? this.vtTransaction.signatures,
      ),
      vttCreateStatus: status ?? this.vttCreateStatus,
      message: message ?? this.message,
    );
  }

  static VTTCreateState initial(state) =>
      state.copyWith(status: VTTCreateStatus.initial);

  static VTTCreateState building(
    VTTCreateState state,
    VttBuilder builder,
  ) {
    return state.copyWith(
      inputs: builder.inputs,
      outputs: builder.outputs,
      status: VTTCreateStatus.building,
    );
  }

  static VTTCreateState busy(VTTCreateState state) =>
      state.copyWith(status: VTTCreateStatus.busy);

  static VTTCreateState signing(VTTCreateState state) =>
      state.copyWith(status: VTTCreateStatus.signing);

  static VTTCreateState sending(VTTCreateState state) =>
      state.copyWith(status: VTTCreateStatus.sending);

  static VTTCreateState accepted(VTTCreateState state) =>
      state.copyWith(status: VTTCreateStatus.accepted);

  static VTTCreateState finished(
          VTTCreateState state, VTTransaction vtTransaction) =>
      state.copyWith(
        vtTransaction: vtTransaction,
        status: VTTCreateStatus.finished,
        message: null,
      );

  static VTTCreateState exception(VTTCreateState state, String error) =>
      state.copyWith(status: VTTCreateStatus.exception, message: error);

  static VTTCreateState discarded(VTTCreateState state, String error) =>
      state.copyWith(status: VTTCreateStatus.discarded, message: error);
  @override
  List<Object> get props => [vtTransaction, vttCreateStatus];
}
