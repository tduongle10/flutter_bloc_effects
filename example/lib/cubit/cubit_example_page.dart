import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_effects/flutter_bloc_effects.dart';

import 'counter_cubit.dart';

class CubitExamplePage extends StatelessWidget {
  const CubitExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocEffectListener<CounterCubit, CounterEffect>(
      listener: (context, effect) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(effect.message),
            backgroundColor: Colors.green,
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cubit Example'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BlocBuilder<CounterCubit, CounterState>(
                builder: (context, state) {
                  return Text(
                    'Count: ${state.count}',
                    style: Theme.of(context).textTheme.headlineLarge,
                  );
                },
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    onPressed: () => context.read<CounterCubit>().decrement(),
                    heroTag: 'decrement',
                    child: const Icon(Icons.remove),
                  ),
                  const SizedBox(width: 16),
                  FloatingActionButton(
                    onPressed: () => context.read<CounterCubit>().increment(),
                    heroTag: 'increment',
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Try incrementing to 10 or decrementing below 0 to see effects!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
