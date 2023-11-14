import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/util/allow_biometrics.dart';
import 'package:my_wit_wallet/util/storage/database/transaction_adapter.dart';
import 'package:witnet/data_structures.dart';
import 'package:witnet/schema.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/bloc/transactions/transaction_builder.dart';

import 'package:my_wit_wallet/constants.dart';

part 'vtt_create_event.dart';
part 'vtt_create_state.dart';

class VTTCreateBloc extends Bloc<VTTCreateEvent, VTTCreateState> {
  /// Create new [VTTCreateBloc].
  ///
  /// extends [Bloc]
  /// [on((event, emit) => null)]
  /// to map [VTTCreateEvent] To [VTTCreateState]
  VTTCreateBloc()
      : super(
          VTTCreateState(
            vtTransaction: VTTransaction(
              body: VTTransactionBody(inputs: [], outputs: []),
              signatures: [],
            ),
            message: null,
            vttCreateStatus: VTTCreateStatus.initial,
          ),
        ) {
    on<AddValueTransferOutputEvent>(_addValueTransferOutputEvent);
    on<SetTimelockEvent>(_setTimeLockEvent);
    on<SignTransactionEvent>(_signTransactionEvent);
    on<SendTransactionEvent>(_sendVttTransactionEvent);
    on<UpdateFeeEvent>(_updateFeeEvent);
    on<PrepareSpeedUpTxEvent>(_prepareSpeedUpTxEvent);
    on<UpdateUtxoSelectionStrategyEvent>(_updateUtxoSelectionStrategyEvent);
    on<InitializeTransactionEvent>(_initializeTransactionEvent);
    on<ResetTransactionEvent>(_resetTransactionEvent);
    on<ValidateTransactionEvent>(_validateTransactionEvent);
    on<ShowAuthPreferencesEvent>(_showAuthPreferencesEvent);
  }

  bool isPrioritiesLoading = false;

  VttBuilder vttBuilder = VttBuilder();

  Future<void> _showAuthPreferencesEvent(
      ShowAuthPreferencesEvent event, Emitter<VTTCreateState> emit) async {
    if (await showBiometrics()) {
      emit(state.copyWith(status: VTTCreateStatus.needPasswordValidation));
    }
  }

  /// add a [ValueTransferOutput] to the [VTTransaction].
  void _addValueTransferOutputEvent(
      AddValueTransferOutputEvent event, Emitter<VTTCreateState> emit) {
    emit(VTTCreateState.busy(state));
    vttBuilder.addOutput(event);
    emit(VTTCreateState.building(state, vttBuilder));
  }

  /// set the timelock for the current [ValueTransferOutput].
  void _setTimeLockEvent(SetTimelockEvent event, Emitter<VTTCreateState> emit) {
    vttBuilder.setTimeLock(event.dateTime);
    emit(VTTCreateState.building(state, vttBuilder));
  }

  /// sign the transaction
  Future<void> _signTransactionEvent(
      SignTransactionEvent event, Emitter<VTTCreateState> emit) async {
    emit(VTTCreateState.signing(state));
    try {
      VTTransaction vtTransaction = await vttBuilder.sign();
      emit(VTTCreateState.finished(state, vtTransaction));
    } catch (e) {
      emit(VTTCreateState.exception(
          state, "Error signing the transaction :: $e"));
      rethrow;
    }
  }

  /// send the transaction to the explorer
  Future<void> _sendVttTransactionEvent(
      SendTransactionEvent event, Emitter<VTTCreateState> emit) async {
    emit(VTTCreateState.sending(state));

    String? response = await vttBuilder.send(event);
    bool transactionAccepted = response == null;
    if (transactionAccepted) {
      await vttBuilder.updateDatabase();
      emit(VTTCreateState.accepted(state));
    } else {
      emit(VTTCreateState.discarded(state, response));
    }
  }

  void _updateFeeEvent(UpdateFeeEvent event, Emitter<VTTCreateState> emit) {
    vttBuilder.updateFee(event);
    emit(VTTCreateState.building(state, vttBuilder));
  }

  void _updateUtxoSelectionStrategyEvent(
      UpdateUtxoSelectionStrategyEvent event, Emitter<VTTCreateState> emit) {
    vttBuilder.setSelectionStrategy(event.strategy);
    emit(VTTCreateState.building(state, vttBuilder));
  }

  Future<void> _prepareSpeedUpTxEvent(
      PrepareSpeedUpTxEvent event, Emitter<VTTCreateState> emit) async {
    _resetTransactionEvent(ResetTransactionEvent(), emit);
    await _initializeTransactionEvent(InitializeTransactionEvent(), emit);
    _addValueTransferOutputEvent(
        AddValueTransferOutputEvent(
            speedUpTx: event.speedUpTx,
            filteredUtxos: false,
            currentWallet: event.currentWallet,
            output: event.output,
            merge: true),
        emit);
  }

  Future<void> _initializeTransactionEvent(
      InitializeTransactionEvent event, Emitter<VTTCreateState> emit) async {
    await vttBuilder.initializeTransaction();
    emit(VTTCreateState.building(state, vttBuilder));
    try {
      await vttBuilder.setPrioritiesEstimate();
    } catch (err) {
      String error = 'Error setting estimated priorities $err';
      emit(VTTCreateState.exception(state, error));
      rethrow;
    }
  }

  void _resetTransactionEvent(
      ResetTransactionEvent event, Emitter<VTTCreateState> emit) {
    vttBuilder.reset();
    emit(VTTCreateState.initial(state));
  }

  void _validateTransactionEvent(
    ValidateTransactionEvent event,
    Emitter<VTTCreateState> emit,
  ) {
    /// ensure that the wallet has sufficient funds
    String? exception = vttBuilder.validateAmount();
    emit((exception) == null
        ? VTTCreateState.building(state, vttBuilder)
        : VTTCreateState.exception(state, exception));
  }
}
