import 'package:flutter_bloc/flutter_bloc.dart';

enum JumpingJackState { neutral, init, complete }

class JumpingJackStatus {
  final int counter;
  final JumpingJackState state;

  JumpingJackStatus({required this.counter, required this.state});

  JumpingJackStatus copyWith({int? counter, JumpingJackState? state}) {
    return JumpingJackStatus(
      counter: counter ?? this.counter,
      state: state ?? this.state,
    );
  }
}

class JumpingJackCounter extends Cubit<JumpingJackStatus> {
  JumpingJackCounter()
      : super(JumpingJackStatus(counter: 0, state: JumpingJackState.neutral));

  void increment() => emit(state.copyWith(counter: state.counter + 1));
  void setJumpingJackState(JumpingJackState newState) =>
      emit(state.copyWith(state: newState));
  void reset() =>
      emit(JumpingJackStatus(counter: 0, state: JumpingJackState.neutral));
}
