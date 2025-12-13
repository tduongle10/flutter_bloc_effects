## 0.2.1

- **Bug fix**: Changed effects stream from single-subscription to broadcast stream to fix an error when multiple screens/listeners subscribe to the same bloc's effects stream simultaneously.

## 0.2.0

- Update dependencies to latest compatible versions.

## 0.1.0

- Initial public release of `flutter_bloc_effects`.
- Adds `BlocEffectEmitter` mixin for effect streams on top of `Bloc`.
- Adds `BlocEffectListener` for listening to effect streams in the widget tree.
- Adds `MultiBlocEffectListener` for composing multiple effect listeners without deep nesting.
