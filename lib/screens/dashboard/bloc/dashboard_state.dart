part of 'dashboard_bloc.dart';

enum DashboardStatus {
  Ready,
  Loading,
  Initialize,
  Synchronized,
  Synchronizing,
  Reset
}

class DashboardState extends Equatable {
  DashboardState(
      {required this.status,
      required this.currentAddress,
      required this.currentWallet});
  final Wallet currentWallet;
  final Address currentAddress;
  final DashboardStatus status;

  DashboardState copyWith({
    Wallet? currentWallet,
    Address? currentAddress,
    DashboardStatus? status,
  }) {
    return DashboardState(
      currentWallet: currentWallet ?? this.currentWallet,
      currentAddress: currentAddress ?? this.currentAddress,
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [currentWallet, currentAddress, status];
}
