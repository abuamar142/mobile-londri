extension EmailValidation on String {
  bool isValidEmail() {
    if (isEmpty) return false;

    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    return emailRegExp.hasMatch(this);
  }
}
