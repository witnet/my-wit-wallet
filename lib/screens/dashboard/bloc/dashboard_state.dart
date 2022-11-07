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
  DashboardState({ required this.status, required this.currentWallet});
  final Wallet currentWallet;
  final DashboardStatus status;

  DashboardState copyWith({
    Wallet? currentWallet,
    DashboardStatus? status,
  }) {
    return DashboardState(
      currentWallet: currentWallet ?? this.currentWallet,
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [currentWallet, status];
}
