part of 'explorer_bloc.dart';

class ExplorerEvent extends Equatable {
  const ExplorerEvent(this.status);
  final ExplorerStatus status;
  @override
  List<Object?> get props => [status];
}

class ExplorerStatusChangedEvent extends ExplorerEvent {
  const ExplorerStatusChangedEvent(ExplorerStatus status) : super(status);
}

class HashQueryEvent extends ExplorerEvent {
  final String value;
  final bool utxos;
  HashQueryEvent(ExplorerStatus status,
      {required this.value, required this.utxos})
      : super(status);

  @override
  List<Object> get props => [status, value, utxos];
}

class HomeQueryEvent extends ExplorerEvent {
  HomeQueryEvent(ExplorerStatus status) : super(status);
}

class NetworkQueryEvent extends ExplorerEvent {
  NetworkQueryEvent(ExplorerStatus status) : super(status);
}

class StatusQueryEvent extends ExplorerEvent {
  StatusQueryEvent(ExplorerStatus status) : super(status);
}

class PendingQueryEvent extends ExplorerEvent {
  PendingQueryEvent(ExplorerStatus status) : super(status);
}

class ReputationQueryEvent extends ExplorerEvent {
  ReputationQueryEvent(ExplorerStatus status) : super(status);
}

class RichListQueryEvent extends ExplorerEvent {
  RichListQueryEvent(ExplorerStatus status) : super(status);
}

class UtxoQueryEvent extends ExplorerEvent {
  final Account account;

  UtxoQueryEvent(ExplorerStatus status, this.account) : super(status);

  @override
  List<Object> get props => [account];
}

class AddressQueryEvent extends ExplorerEvent {
  final String address;
  final String tab;
  AddressQueryEvent(
    ExplorerStatus status,
    this.address,
    this.tab,
  ) : super(status);

  @override
  List<Object> get props => [address, tab];
}

class SyncWalletEvent extends ExplorerEvent {
  final Wallet currentWallet;
  final bool force;
  SyncWalletEvent(
    ExplorerStatus status,
    this.currentWallet, {
    this.force = false,
  }) : super(status);

  @override
  List<Object> get props => [currentWallet, force];
}

class CancelSyncWalletEvent extends ExplorerEvent {
  CancelSyncWalletEvent(
    ExplorerStatus status,
  ) : super(status);
}

class SyncSingleAccountEvent extends ExplorerEvent {
  final Account account;
  SyncSingleAccountEvent(
    ExplorerStatus status,
    this.account,
  ) : super(status);

  @override
  List<Object> get props => [account];
}

class DataLoadedEvent extends ExplorerEvent {
  final WalletStorage walletStorage;
  DataLoadedEvent(
    ExplorerStatus status,
    this.walletStorage,
  ) : super(status);

  @override
  List<Object> get props => [walletStorage];
}

class DataLoadingEvent extends ExplorerEvent {
  DataLoadingEvent(ExplorerStatus status) : super(status);
}

class SyncErrorEvent extends ExplorerEvent {
  SyncErrorEvent(ExplorerStatus status) : super(status);
}

class BlockchainQueryEvent extends ExplorerEvent {
  BlockchainQueryEvent(ExplorerStatus status) : super(status);
}

class TapiQueryEvent extends ExplorerEvent {
  TapiQueryEvent(ExplorerStatus status) : super(status);
}

class VTTransactionPostEvent extends ExplorerEvent {
  final VTTransaction vtTransaction;
  VTTransactionPostEvent(
    ExplorerStatus status,
    this.vtTransaction,
  ) : super(status);

  @override
  List<Object> get props => [vtTransaction];
}
