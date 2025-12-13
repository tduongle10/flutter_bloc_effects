## 1.0.1

- Update dependencies to latest compatible versions.

## 1.0.0

- **BREAKING**: Simplified `BlocEffectEmitter` signature from `BlocEffectEmitter<State, Effect>` to `BlocEffectEmitter<Effect>`.
  - The mixin now only requires the effect type parameter, making it cleaner and easier to use.
  - Update your code: `with BlocEffectEmitter<LoginEffect>` instead of `with BlocEffectEmitter<LoginState, LoginEffect>`.
- Changed effects stream from single-subscription to broadcast stream, allowing multiple listeners to subscribe to the same bloc's effects stream simultaneously.
- Improved resource management: `BlocEffectEmitter` now properly extends `Closable` and ensures the effects stream is closed when the bloc/cubit is disposed.
- Updated minimum SDK requirement to Dart 3.0.0 and Flutter 3.10.0.
- Updated dependencies: `flutter_bloc >=8.0.0 <10.0.0`, `provider >=6.0.0 <7.0.0`.

## 0.2.0

- Update dependencies to latest compatible versions.

## 0.1.0

- Initial public release of `flutter_bloc_effects`.
- Adds `BlocEffectEmitter` mixin for effect streams on top of `Bloc`.
- Adds `BlocEffectListener` for listening to effect streams in the widget tree.
- Adds `MultiBlocEffectListener` for composing multiple effect listeners without deep nesting.
