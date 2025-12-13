import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_effects/flutter_bloc_effects.dart';

class CounterState {
  const CounterState(this.count);
  final int count;
}

class CounterEffect {
  const CounterEffect(this.message);
  final String message;
}

class CounterCubit extends Cubit<CounterState>
    with BlocEffectEmitter<CounterEffect> {
  CounterCubit() : super(const CounterState(0));

  void increment() {
    emit(CounterState(state.count + 1));

    // Emit an effect when count reaches 10
    if (state.count == 10) {
      emitEffect(const CounterEffect('Congratulations! You reached 10!'));
    }
  }

  void decrement() {
    if (state.count > 0) {
      emit(CounterState(state.count - 1));
    } else {
      emitEffect(const CounterEffect('Cannot go below 0'));
    }
  }
}
