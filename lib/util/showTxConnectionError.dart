import 'package:my_wit_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';

bool showTxConnectionReEstablish(
    VTTCreateStatus prevStatus, VTTCreateStatus currentStatus) {
  return prevStatus == VTTCreateStatus.exception &&
      currentStatus != VTTCreateStatus.exception &&
      currentStatus != VTTCreateStatus.busy &&
      currentStatus != VTTCreateStatus.initial;
}
