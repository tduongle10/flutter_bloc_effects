sealed class LoginEffect {}

class ShowLoginError extends LoginEffect {
  ShowLoginError(this.message);
  final String message;
}

class NavigateToHome extends LoginEffect {
  NavigateToHome(this.username);
  final String username;
}
