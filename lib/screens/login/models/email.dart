import 'package:formz/formz.dart';

enum EmailValidationError { invalid }

class Email extends FormzInput<String, EmailValidationError> {
  const Email.pure() : super.pure('');

  const Email.dirty([String value = '']) : super.dirty(value);

  @override
  EmailValidationError? validator(String? value) {
    return (value?.isNotEmpty == true &&
            RegExp(r'^[a-zA-Z0-9.@]+$').hasMatch(value!))
        ? null
        : EmailValidationError.invalid;
  }
}
