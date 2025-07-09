import 'package:flutter_bloc/flutter_bloc.dart';

enum SquatState {
  neutral,
  init,
  complete,
}

class SquatStatus {
  final int counter;
  final SquatState state;

  SquatStatus({
    required this.counter,
    required this.state,
  });
}

class SquatCounter extends Cubit<SquatStatus> {
  SquatCounter() : super(SquatStatus(counter: 0, state: SquatState.neutral));

  void setSquatState(SquatState newState) {
    emit(SquatStatus(counter: state.counter, state: newState));
  }

  void increment() {
    emit(SquatStatus(counter: state.counter + 1, state: SquatState.neutral));
  }

  void reset() {
    emit(SquatStatus(counter: 0, state: SquatState.neutral));
  }
}
