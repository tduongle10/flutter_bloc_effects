## flutter_bloc_effects

**Side‑effect handling on top of `flutter_bloc`, with dedicated effect streams and listeners.**

`flutter_bloc_effects` adds a simple pattern for modeling one‑off UI side effects (navigation, snackbars, dialogs, toasts, etc.) on top of `flutter_bloc`.  
It gives you:

- **`BlocEffectEmitter` mixin**: add an `effects` stream and `emitEffect` to any `Bloc` or `Cubit`.
- **`BlocEffectListener` widget**: listen to the `effects` stream and run UI callbacks (similar to `BlocListener`, but for effects).
- **`MultiBlocEffectListener` widget**: compose multiple `BlocEffectListener`s without deep nesting.

---

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_bloc_effects: ^1.0.1

  flutter_bloc: ^9.1.1
  provider: ^6.1.5+1
```

Then import it:

```dart
import 'package:flutter_bloc_effects/flutter_bloc_effects.dart';
```

---

## Motivation

`BlocListener` is great for reacting to **state** changes, but some things are really **events that should happen once**:

- Navigate to another page
- Show a `SnackBar` / `Dialog`
- Show a one‑time toast / banner

If you put those in your state, you risk re‑triggering them on rebuilds, restores, or when states are re‑emitted.  
This package separates those into an **effect stream** that the UI can listen to exactly once.

---

## Usage

### 1. Add `BlocEffectEmitter` to your bloc or cubit

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_effects/flutter_bloc_effects.dart';

sealed class LoginEvent {}
class LoginSubmitted extends LoginEvent {
  LoginSubmitted(this.username, this.password);
  final String username;
  final String password;
}

sealed class LoginState {}
class LoginInitial extends LoginState {}
class LoginLoading extends LoginState {}
class LoginSuccess extends LoginState {}
class LoginFailure extends LoginState {}

/// Define your effects (navigation, snackbars, dialogs, etc.)
sealed class LoginEffect {}
class ShowLoginError extends LoginEffect {
  ShowLoginError(this.message);
  final String message;
}
class NavigateToHome extends LoginEffect {
  NavigateToHome(this.username);
  final String username;
}

class LoginBloc extends Bloc<LoginEvent, LoginState>
    with BlocEffectEmitter<LoginEffect> {
  LoginBloc() : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());

    try {
      // TODO: perform login
      emit(LoginSuccess());
      emitEffect(NavigateToHome(event.username));
    } catch (e) {
      emit(LoginFailure());
      emitEffect(ShowLoginError('Login failed'));
    }
  }
}
```

The mixin:

- Adds an `effects` stream: `Stream<LoginEffect> get effects`
- Exposes `emitEffect(LoginEffect effect)` to push one‑off UI effects.

#### Using with `Cubit`

You can also use `BlocEffectEmitter` with `Cubit`:

```dart
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
      emitEffect(CounterEffect('Congratulations! You reached 10!'));
    }
  }

  void decrement() {
    if (state.count > 0) {
      emit(CounterState(state.count - 1));
    } else {
      emitEffect(CounterEffect('Cannot go below 0'));
    }
  }
}
```

---

### 2. Listen to effects with `BlocEffectListener`

```dart
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(),
      child: BlocEffectListener<LoginBloc, LoginEffect>(
        listener: (context, effect) {
          switch (effect) {
            case ShowLoginError(:final message):
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
            case NavigateToHome(:final username):
              Navigator.of(context).pushReplacementNamed('/home');
              // username is available if needed
          }
        },
        child: const _LoginView(),
      ),
    );
  }
}
```

#### With `listenWhen`

You can filter which effects trigger the listener:

```dart
BlocEffectListener<LoginBloc, LoginEffect>(
  listenWhen: (effect) => effect is ShowLoginError,
  listener: (context, effect) {
    if (effect case ShowLoginError(:final message)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  },
  child: const _LoginView(),
);
```

---

### 3. Use `MultiBlocEffectListener` for multiple blocs

Instead of deeply nesting multiple `BlocEffectListener`s:

```dart
BlocEffectListener<BlocA, BlocAEffect>(
  listener: (context, effect) {},
  child: BlocEffectListener<BlocB, BlocBEffect>(
    listener: (context, effect) {},
    child: BlocEffectListener<BlocC, BlocCEffect>(
      listener: (context, effect) {},
      child: ChildA(),
    ),
  ),
);
```

You can write:

```dart
MultiBlocEffectListener(
  listeners: [
    BlocEffectListener<BlocA, BlocAEffect>(
      listener: (context, effect) {},
    ),
    BlocEffectListener<BlocB, BlocBEffect>(
      listener: (context, effect) {},
    ),
    BlocEffectListener<BlocC, BlocCEffect>(
      listener: (context, effect) {},
    ),
  ],
  child: ChildA(),
);
```

`MultiBlocEffectListener` is built on `provider`’s `MultiProvider` and just flattens the listeners into a tree.

---

## API Reference

### `BlocEffectEmitter<Effect>`

Mixin for `Bloc<Event, State>` or `Cubit<State>` that adds:

- **`Stream<Effect> get effects`**: the effect stream.
- **`void emitEffect(Effect effect)`**: push a new effect.

The mixin extends `Closable` and properly closes the effects stream when the bloc/cubit is closed.

### `BlocEffectListener<B extends BlocEffectEmitter<E>, E>`

Widget that:

- Subscribes to `B.effects` (where `B` mixes in `BlocEffectEmitter<E>`).
- Calls:

  ```dart
  void Function(BuildContext context, E effect)
  ```

  for each effect (optionally filtered by `listenWhen`).

Options:

- **`bloc`** *(optional)*: provide a specific bloc instance; otherwise it uses `BlocProvider` / `context.read<B>()`.
- **`listenWhen`** *(optional)*: `bool Function(E effect)` to filter which effects should be delivered.
- **`listener`**: required callback that handles the effect.
- **`child`**: the subtree that will be rendered.

### `MultiBlocEffectListener`

Construction:

```dart
MultiBlocEffectListener({
  required List<SingleChildWidget> listeners,
  required Widget child,
})
```

- `listeners`: list of `BlocEffectListener` (or other `SingleChildWidget`-based listeners).
- `child`: the subtree that will receive all effects.

---

## Notes

- This package is designed to **complement** `flutter_bloc`, not replace any of its patterns.
- Effects are intentionally **decoupled from state** to make side‑effects explicit and one‑time.

---

## License

This project is licensed under the terms specified in the `LICENSE` file.
