import 'package:formz/formz.dart';

enum PasswordValidationError { invalid }

class Password extends FormzInput<String, PasswordValidationError> {
  const Password.pure() : super.pure('');

  const Password.dirty([String value = '']) : super.dirty(value);

  @override
  PasswordValidationError? validator(String? value) {
    return (value?.isNotEmpty == true &&
            RegExp(r'^[a-zA-Z0-9!$#?]+$').hasMatch(value!))
        ? null
        : PasswordValidationError.invalid;
  }
}
