import 'package:bloc/bloc.dart';

enum VttStatus { unknown, pending, mined, confirmed }

abstract class VttStatusEvent {}

class CheckStatusEvent extends VttStatusEvent {
  final String transactionHash;
  CheckStatusEvent({required this.transactionHash});
}

abstract class VttStatusState {}

class UnknownHashState extends VttStatusState {}

class PendingState extends VttStatusState {}

class MinedState extends VttStatusState {}

class ConfirmedState extends VttStatusState {}

class VttStatusBloc extends Bloc<VttStatusEvent, VttStatusState> {
  VttStatusBloc() : super(initialState);

  static VttStatusState initialState = UnknownHashState();
}

class BlocStatusVtt extends Bloc<VttStatusEvent, VttStatusState> {
  BlocStatusVtt(UnknownHashState initialState) : super(initialState);

  static VttStatusState get initialState => UnknownHashState();

  Future<void> checkStatus(String transactionHash) async {
    // ApiExplorer apiExplorer = Locator.instance.get<ApiExplorer>();
    try {
      // var status = await apiExplorer.getStatus();

      // var response = await apiExplorer.hash(transactionHash);
    } catch (e) {}
  }

  Stream<VttStatusState> mapEventToState(VttStatusEvent event) async* {
    Type eventType = event.runtimeType;
    switch (eventType) {
      case CheckStatusEvent:
        event as CheckStatusEvent;
        await checkStatus(event.transactionHash);
    }
  }
}
