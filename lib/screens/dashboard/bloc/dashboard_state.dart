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
  DashboardState({
    required this.status,
    required this.currentAddress,
    required this.currentWalletId,
    required this.currentVttId,
  });

  final String currentAddress;
  final String currentWalletId;
  final String currentVttId;
  final DashboardStatus status;

  DashboardState copyWith({
    String? currentWalletId,
    String? currentAddress,
    String? currentVttId,
    DashboardStatus? status,
  }) {
    return DashboardState(
      currentAddress: currentAddress ?? this.currentAddress,
      currentWalletId: currentWalletId ?? this.currentWalletId,
      currentVttId: currentVttId ?? this.currentVttId,
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props =>
      [currentWalletId, currentAddress, currentVttId, status];
}
