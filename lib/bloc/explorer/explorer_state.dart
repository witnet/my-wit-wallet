part of 'explorer_bloc.dart';

class ExplorerState extends Equatable {
  const ExplorerState._(
      {this.status = ExplorerStatus.unknown,
      this.data = const {},
      this.dbWallet});
  final Map<String, dynamic> data;

  final ExplorerStatus status;
  final DbWallet? dbWallet;

  const ExplorerState.unknown() : this._();

  const ExplorerState.synced(DbWallet wallet)
      : this._(status: ExplorerStatus.dataloaded, dbWallet: wallet);

  const ExplorerState.dataLoading()
      : this._(status: ExplorerStatus.dataloading);

  const ExplorerState.dataLoaded(
      {required ExplorerQuery query, required Map<String, dynamic> data})
      : this._(status: ExplorerStatus.dataloaded, data: data);

  const ExplorerState.ready() : this._(status: ExplorerStatus.ready);

  const ExplorerState.error() : this._(status: ExplorerStatus.error);

  @override
  List<Object> get props => [status];
}
