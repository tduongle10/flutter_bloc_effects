sealed class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  LoginSuccess(this.username);
  final String username;
}

class LoginFailure extends LoginState {
  LoginFailure(this.message);
  final String message;
}
