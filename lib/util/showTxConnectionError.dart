import 'package:my_wit_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:my_wit_wallet/constants.dart';

bool showTxConnectionReEstablish(
    TransactionStatus prevStatus, TransactionStatus currentStatus,
    {String? message}) {
  if (message != null && message.contains(INSUFFICIENT_FUNDS_ERROR)) {
    return false;
  }
  return prevStatus == TransactionStatus.explorerException &&
      currentStatus != TransactionStatus.explorerException &&
      currentStatus != TransactionStatus.busy &&
      currentStatus != TransactionStatus.initial;
}
