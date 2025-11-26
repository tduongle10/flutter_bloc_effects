import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'bloc_effect_listener.dart';

/// {@template multi_bloc_effect_listener}
/// Merges multiple [BlocEffectListener] widgets into one widget tree.
///
/// [MultiBlocEffectListener] improves the readability and eliminates the need
/// to nest multiple [BlocEffectListener]s.
///
/// By using [MultiBlocEffectListener] we can go from:
///
/// ```dart
/// BlocEffectListener<BlocA, BlocAEffect>(
///   listener: (context, effect) {},
///   child: BlocEffectListener<BlocB, BlocBEffect>(
///     listener: (context, effect) {},
///     child: BlocEffectListener<BlocC, BlocCEffect>(
///       listener: (context, effect) {},
///       child: ChildA(),
///     ),
///   ),
/// )
/// ```
///
/// to:
///
/// ```dart
/// MultiBlocEffectListener(
///   listeners: [
///     BlocEffectListener<BlocA, BlocAEffect>(
///       listener: (context, effect) {},
///     ),
///     BlocEffectListener<BlocB, BlocBEffect>(
///       listener: (context, effect) {},
///     ),
///     BlocEffectListener<BlocC, BlocCEffect>(
///       listener: (context, effect) {},
///     ),
///   ],
///   child: ChildA(),
/// )
/// ```
///
/// [MultiBlocEffectListener] converts the [BlocEffectListener] list into a tree
/// of nested [BlocEffectListener] widgets.
/// As a result, the only advantage of using [MultiBlocEffectListener] is
/// improved readability due to the reduction in nesting and boilerplate.
///
/// It is analogous to `MultiBlocListener` from `flutter_bloc` but works with
/// effect listeners built on top of the `BlocEffect` mixin.
/// {@endtemplate}
class MultiBlocEffectListener extends MultiProvider {
  /// {@macro multi_bloc_effect_listener}
  MultiBlocEffectListener({
    required List<SingleChildWidget> listeners,
    required Widget super.child,
    super.key,
  }) : super(providers: listeners);
}
