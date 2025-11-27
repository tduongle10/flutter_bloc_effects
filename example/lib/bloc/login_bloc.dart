import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_effects/flutter_bloc_effects.dart';

import 'login_event.dart';
import 'login_state.dart';
import 'login_effect.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState>
    with BlocEffectEmitter<LoginState, LoginEffect> {
  LoginBloc() : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Simple validation
    if (event.username.isEmpty || event.password.isEmpty) {
      emit(LoginFailure('Username and password are required'));
      emitEffect(ShowLoginError('Please fill in all fields'));
      return;
    }

    if (event.password.length < 6) {
      emit(LoginFailure('Password must be at least 6 characters'));
      emitEffect(ShowLoginError('Password must be at least 6 characters'));
      return;
    }

    // Simulate successful login
    emit(LoginSuccess(event.username));
    emitEffect(NavigateToHome(event.username));
  }
}
