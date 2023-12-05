import 'package:formz/formz.dart';

enum PortValidationError { invalid }

class Port extends FormzInput<String, PortValidationError> {
  const Port.pure() : super.pure('');
  const Port.dirty([String value = '']) : super.dirty(value);

  @override
  PortValidationError? validator(String? value) {
    return (value?.isNotEmpty == true && RegExp(r'^[0-9]+$').hasMatch(value!)) ? null : PortValidationError.invalid;
  }
}