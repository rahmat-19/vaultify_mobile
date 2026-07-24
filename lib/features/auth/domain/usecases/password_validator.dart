abstract final class PasswordValidator {
  static bool hasMinimumLength(String value) => value.length >= 8;
  static bool hasUppercase(String value) => RegExp('[A-Z]').hasMatch(value);
  static bool hasLowercase(String value) => RegExp('[a-z]').hasMatch(value);
  static bool hasNumber(String value) => RegExp('[0-9]').hasMatch(value);
  static bool hasSymbol(String value) =>
      RegExp(r'[!@#$%^&*(),.?":{}|<>\-_=+\[\]\\;/`~]').hasMatch(value);
  static bool isStrong(String value) =>
      hasMinimumLength(value) &&
      hasUppercase(value) &&
      hasLowercase(value) &&
      hasNumber(value) &&
      hasSymbol(value);
}
