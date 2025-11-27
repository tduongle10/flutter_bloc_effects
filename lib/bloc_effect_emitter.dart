import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

mixin BlocEffectEmitter<State, Effect> on StateStreamableSource<State> {
  final _effects = StreamController<Effect>();

  Stream<Effect> get effects => _effects.stream;

  void emitEffect(Effect effect) {
    _effects.add(effect);
  }

  @mustCallSuper
  @override
  Future<void> close() async {
    await _effects.close();
    await super.close();
  }
}
