part of 'dashboard_bloc.dart';

enum DashboardStatus{
  Ready,
  Loading,
  Initialize,
  Synchronized,
  Synchronizing,
  Reset
}

class DashboardState extends Equatable{
  DashboardState({ required this.status, required this.walletStorage});
  final WalletStorage walletStorage;
  final DashboardStatus status;

  DashboardState copyWith({
    WalletStorage? walletStorage,
    DashboardStatus? status,
  }){
    return DashboardState(
      walletStorage: walletStorage ?? this.walletStorage,
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [walletStorage, status];
}
