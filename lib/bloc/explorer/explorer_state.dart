part of 'explorer_bloc.dart';

class ExplorerState extends Equatable {
  const ExplorerState._(
      {this.status = ExplorerStatus.unknown,
      this.data = const {},
      this.walletStorage});
  final Map<String, dynamic> data;

  final ExplorerStatus status;
  final WalletStorage? walletStorage;

  const ExplorerState.unknown() : this._();

  const ExplorerState.synced(WalletStorage walletStorage)
      : this._(status: ExplorerStatus.dataloaded, walletStorage: walletStorage);

  const ExplorerState.dataLoading()
      : this._(status: ExplorerStatus.dataloading);

  const ExplorerState.singleAccountSyncing({required Map<String, dynamic> data})
      : this._(status: ExplorerStatus.singleSync, data: data);

  const ExplorerState.dataLoaded(
      {required ExplorerQuery query, required Map<String, dynamic> data})
      : this._(status: ExplorerStatus.dataloaded, data: data);

  const ExplorerState.ready() : this._(status: ExplorerStatus.ready);

  const ExplorerState.error() : this._(status: ExplorerStatus.error);

  @override
  List<Object> get props => [status];
}
