sealed class LoginEvent {}

class LoginSubmitted extends LoginEvent {
  LoginSubmitted(this.username, this.password);
  final String username;
  final String password;
}
