import 'package:flutter_bloc/flutter_bloc.dart';

enum PushUpState {
  neutral,
  init,
  complete,
}

class PushUpStatus {
  final int counter;
  final PushUpState state;

  PushUpStatus({
    required this.counter,
    required this.state,
  });
}

class PushUpCounter extends Cubit<PushUpStatus> {
  PushUpCounter() : super(PushUpStatus(counter: 0, state: PushUpState.neutral));

  void setPushUpState(PushUpState newState) {
    emit(PushUpStatus(counter: state.counter, state: newState));
  }

  void increment() {
    emit(PushUpStatus(counter: state.counter + 1, state: PushUpState.neutral));
  }

  void reset() {
    emit(PushUpStatus(counter: 0, state: PushUpState.neutral));
  }
}
