import 'package:formz/formz.dart';

enum SlaveIdValidationError { invalid }

class SlaveId extends FormzInput<String, SlaveIdValidationError> {
  const SlaveId.pure() : super.pure('');
  const SlaveId.dirty([String value = '']) : super.dirty(value);

  @override
  SlaveIdValidationError? validator(String? value) {
    return (value?.isNotEmpty == true && RegExp(r'^[0-9]+$').hasMatch(value!)) ? null : SlaveIdValidationError.invalid;
  }
}
