import 'package:my_wit_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:my_wit_wallet/constants.dart';

bool showTxConnectionReEstablish(
    VTTCreateStatus prevStatus, VTTCreateStatus currentStatus,
    {String? message}) {
  if (message != null && message.contains(INSUFFICIENT_FUNDS_ERROR)) {
    return false;
  }
  return prevStatus == VTTCreateStatus.explorerException &&
      currentStatus != VTTCreateStatus.explorerException &&
      currentStatus != VTTCreateStatus.busy &&
      currentStatus != VTTCreateStatus.initial;
}
