import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_bloc_effects/flutter_bloc_effects.dart';

class TestEvent {}

class TestState {
  const TestState(this.value);
  final int value;
}

class TestEffect {
  const TestEffect(this.message);
  final String message;
}

class TestBloc extends Bloc<TestEvent, TestState>
    with BlocEffect<TestState, TestEffect> {
  TestBloc() : super(const TestState(0)) {
    on<TestEvent>((event, emit) {
      emit(const TestState(1));
      emitEffect(const TestEffect('effect-emitted'));
    });
  }
}

void main() {
  group('BlocEffect', () {
    test('emits effects via effects stream', () async {
      final bloc = TestBloc();

      // Trigger an effect.
      bloc.add(TestEvent());

      final effect = await bloc.effects.first;
      expect(effect.message, 'effect-emitted');

      await bloc.close();
    });
  });

  group('BlocEffectListener', () {
    testWidgets('invokes listener when effect is emitted', (tester) async {
      final bloc = TestBloc();
      TestEffect? receivedEffect;

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<TestBloc>.value(
            value: bloc,
            child: BlocEffectListener<TestBloc, TestEffect>(
              listener: (context, effect) {
                receivedEffect = effect;
              },
              child: const SizedBox(),
            ),
          ),
        ),
      );

      // Trigger an effect.
      bloc.add(TestEvent());

      // Allow the listener to be called.
      await tester.pump();

      expect(receivedEffect, isNotNull);
      expect(receivedEffect!.message, 'effect-emitted');

      await bloc.close();
    });
  });
}
