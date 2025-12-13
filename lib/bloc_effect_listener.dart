import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_effects/bloc_effect_emitter.dart';
import 'package:provider/single_child_widget.dart';

/// Signature for the `listener` function which takes the [BuildContext] along
/// with the emitted `effect` and is responsible for executing in response to
/// effect emissions.
///
/// It should be used for functionality that needs to occur only once per
/// effect emission such as navigation, showing a `SnackBar`, showing a
/// `Dialog`, etc...
///
/// ```dart
/// BlocEffectListener<MyBloc, MyEffect>(
///   listener: (context, effect) {
///     // do stuff here based on the effect
///   },
///   child: Container(),
/// )
/// ```
typedef BlocEffectWidgetListener<E> = void Function(
    BuildContext context, E effect);

/// {@template bloc_effect_listener_listen_when}
/// An optional [listenWhen] can be implemented for more granular control
/// over when [listener] is called.
///
/// [listenWhen] will be invoked on every emitted effect.
/// It must return a [bool] which determines whether or not
/// the [BlocEffectWidgetListener] function will be invoked.
///
/// If omitted, [listenWhen] will default to `true`.
///
/// ```dart
/// BlocEffectListener<MyBloc, MyEffect>(
///   listenWhen: (effect) {
///     // return true/false to determine whether or not
///     // to invoke listener with the effect
///   },
///   listener: (context, effect) {
///     // do stuff here based on the effect
///   },
///   child: Container(),
/// )
/// ```
/// {@endtemplate}
typedef BlocEffectListenerCondition<E> = bool Function(E effect);

/// {@template bloc_effect_listener}
/// Takes a [BlocEffectWidgetListener] and an optional [bloc] and invokes
/// the [listener] in response to effect emissions from the [bloc] or [Cubit].
///
/// It should be used for functionality that needs to occur only in response to
/// an effect such as navigation, showing a `SnackBar`, showing a `Dialog`, etc.
///
/// If the [bloc] parameter is omitted, [BlocEffectListener] will automatically
/// perform a lookup using [BlocProvider] and the current [BuildContext].
///
/// Only specify the [bloc] if you wish to provide a [bloc] or [Cubit] that is otherwise
/// not accessible via [BlocProvider] and the current [BuildContext].
///
/// ```dart
/// BlocEffectListener<MyBloc, MyEffect>(
///   listener: (context, effect) {
///     // do stuff here based on the effect
///   },
///   child: Container(),
/// )
/// ```
///
/// ```dart
/// BlocEffectListener<MyBloc, MyEffect>(
///   bloc: myBloc,
///   listener: (context, effect) {
///     // do stuff here based on the effect
///   },
///   child: Container(),
/// )
/// ```
/// {@endtemplate}
class BlocEffectListener<B extends BlocEffectEmitter<E>, E>
    extends BlocEffectListenerBase<B, E> {
  /// {@macro bloc_effect_listener}
  const BlocEffectListener({
    required super.listener,
    super.key,
    super.bloc,
    super.listenWhen,
    super.child,
  });
}

/// Base class for widgets that listen to effect emissions from a specified
/// [Bloc] or [Cubit] which mixes in the `BlocEffectEmitter` mixin.
///
/// A [BlocEffectListenerBase] is stateful and maintains the effect
/// subscription.
abstract class BlocEffectListenerBase<B extends BlocEffectEmitter<E>, E>
    extends SingleChildStatefulWidget {
  const BlocEffectListenerBase({
    required this.listener,
    super.key,
    this.bloc,
    this.child,
    this.listenWhen,
  }) : super(child: child);

  /// The widget which will be rendered as a descendant of the
  /// [BlocEffectListenerBase].
  final Widget? child;

  /// The [bloc] or [Cubit] whose `effects` will be listened to.
  /// Whenever the [bloc] emits an effect, [listener] will be invoked.
  final B? bloc;

  /// The [BlocEffectWidgetListener] which will be called on each emitted
  /// effect (subject to [listenWhen]).
  final BlocEffectWidgetListener<E> listener;

  /// Optional predicate invoked for each effect to determine whether the
  /// [listener] should be called.
  ///
  /// {@macro bloc_effect_listener_listen_when}
  final BlocEffectListenerCondition<E>? listenWhen;

  @override
  SingleChildState<BlocEffectListenerBase<B, E>> createState() =>
      _BlocEffectListenerBaseState<B, E>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<B?>('bloc', bloc))
      ..add(
        ObjectFlagProperty<BlocEffectWidgetListener<E>>.has(
          'listener',
          listener,
        ),
      )
      ..add(
        ObjectFlagProperty<BlocEffectListenerCondition<E>?>.has(
          'listenWhen',
          listenWhen,
        ),
      );
  }
}

class _BlocEffectListenerBaseState<B extends BlocEffectEmitter<E>, E>
    extends SingleChildState<BlocEffectListenerBase<B, E>> {
  StreamSubscription<E>? _subscription;
  late B _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? context.read<B>();
    _subscribe();
  }

  @override
  void didUpdateWidget(BlocEffectListenerBase<B, E> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldBloc = oldWidget.bloc ?? context.read<B>();
    final currentBloc = widget.bloc ?? oldBloc;
    if (oldBloc != currentBloc) {
      if (_subscription != null) {
        _unsubscribe();
        _bloc = currentBloc;
      }
      _subscribe();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc = widget.bloc ?? context.read<B>();
    if (_bloc != bloc) {
      if (_subscription != null) {
        _unsubscribe();
        _bloc = bloc;
      }
      _subscribe();
    }
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    assert(
      child != null,
      '''${widget.runtimeType} used outside of MultiBlocEffectListener must specify a child''',
    );
    if (widget.bloc == null) {
      // Trigger a rebuild if the bloc reference has changed to ensure we are
      // listening to the correct instance.
      context.select<B, bool>((bloc) => identical(_bloc, bloc));
    }
    return child!;
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    // Listen to the effects stream of the bloc/cubit and call the listener when an effect is emitted
    _subscription = _bloc.effects.listen((effect) {
      if (!mounted) return;
      if (widget.listenWhen?.call(effect) ?? true) {
        widget.listener(context, effect);
      }
    });
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }
}
