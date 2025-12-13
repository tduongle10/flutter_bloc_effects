import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_bloc_effects/flutter_bloc_effects.dart';

class TestState {
  const TestState(this.value);
  final int value;
}

class TestEffect {
  const TestEffect(this.message);
  final String message;
}

class TestCubit extends Cubit<TestState> with BlocEffectEmitter<TestEffect> {
  TestCubit() : super(const TestState(0));

  void emitTestEffect() {
    emit(const TestState(1));
    emitEffect(const TestEffect('effect-emitted'));
  }
}

void main() {
  group('BlocEffectEmitter', () {
    test('emits effects via effects stream', () async {
      final cubit = TestCubit();

      // Subscribe to effects stream before triggering
      final effectFuture = cubit.effects.first;

      // Trigger an effect
      cubit.emitTestEffect();

      final effect = await effectFuture;
      expect(effect.message, 'effect-emitted');

      await cubit.close();
    });
  });

  group('BlocEffectListener', () {
    testWidgets('invokes listener when effect is emitted', (tester) async {
      final cubit = TestCubit();
      TestEffect? receivedEffect;

      await tester.pumpWidget(
        BlocProvider<TestCubit>.value(
          value: cubit,
          child: MaterialApp(
            home: Scaffold(
              body: BlocEffectListener<TestCubit, TestEffect>(
                listener: (context, effect) {
                  receivedEffect = effect;
                },
                child: const SizedBox(),
              ),
            ),
          ),
        ),
      );

      // Wait for widget tree to settle and listener to subscribe
      await tester.pump();

      // Trigger an effect
      cubit.emitTestEffect();

      // Wait for effect to propagate
      await tester.pump();

      expect(receivedEffect, isNotNull);
      expect(receivedEffect!.message, 'effect-emitted');

      await cubit.close();
    });
  });
}
