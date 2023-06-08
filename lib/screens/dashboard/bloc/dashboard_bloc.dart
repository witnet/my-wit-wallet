import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';

import 'package:my_wit_wallet/util/storage/database/wallet_storage.dart';
part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  ApiDatabase database = Locator.instance.get<ApiDatabase>();

  DashboardBloc()
      : super(
          DashboardState(
              currentWalletId: defaultWallet.id,
              currentAddress: defaultAccount.address,
              currentVttId: defaulVtt.txnHash,
              status: DashboardStatus.Ready),
        ) {
    on<DashboardLoadEvent>(_dashboardLoadEvent);
    on<DashboardUpdateWalletEvent>(_dashboardUpdateWallet);
    on<DashboardInitEvent>(_dashboardInitEvent);
    on<DashboardUpdateEvent>(_dashboardUpdateStatusEvent);
    on<DashboardResetEvent>(_dashboardResetEvent);
  }
  get initialState => DashboardState(
      currentWalletId: defaultWallet.id,
      currentAddress: defaultAccount.address,
      currentVttId: defaulVtt.txnHash,
      status: DashboardStatus.Ready);

  Future<void> _dashboardLoadEvent(
    DashboardLoadEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardState(
        currentWalletId: event.currentWalletId ?? defaultWallet.id,
        currentAddress: event.currentAddress ?? defaultAccount.address,
        currentVttId: event.currentVttId ?? defaulVtt.txnHash,
        status: DashboardStatus.Ready));
  }

  Future<void> _dashboardInitEvent(
      DashboardInitEvent event, Emitter<DashboardState> emit) async {
    await Future.delayed(Duration(seconds: 4));
    emit(DashboardState(
        currentWalletId: event.currentWalletId ?? defaultWallet.id,
        currentAddress: event.currentAddress ?? defaultAccount.address,
        currentVttId: event.currentVttId ?? defaulVtt.txnHash,
        status: DashboardStatus.Ready));
  }

  void _dashboardUpdateWallet(
      DashboardUpdateWalletEvent event, Emitter<DashboardState> emit) async {
    ApiDatabase db = Locator.instance.get<ApiDatabase>();
    await db.updateCurrentWallet(event.currentWallet?.id);
    emit(DashboardState(
        currentWalletId: event.currentWallet?.id ?? defaultWallet.id,
        currentAddress: event.currentAddress ?? defaultAccount.address,
        currentVttId: event.currentVttId ?? defaulVtt.txnHash,
        status: DashboardStatus.Ready));
  }

  Future<void> _dashboardUpdateStatusEvent(
      DashboardUpdateEvent event, Emitter<DashboardState> emit) async {
    emit(DashboardState(
        currentWalletId: event.currentWalletId ?? defaultWallet.id,
        currentAddress: event.currentAddress ?? defaultAccount.address,
        currentVttId: event.currentVttId ?? defaulVtt.txnHash,
        status: DashboardStatus.Ready));
  }

  void _dashboardResetEvent(
      DashboardResetEvent event, Emitter<DashboardState> emit) {}
}
