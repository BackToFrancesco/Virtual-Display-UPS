import 'package:formz/formz.dart';

enum IpAddressValidationError { invalid }

class IpAddress extends FormzInput<String, IpAddressValidationError> {
  const IpAddress.pure() : super.pure('');
  const IpAddress.dirty([String value = '']) : super.dirty(value);

  @override
  IpAddressValidationError? validator(String? value) {
    return (value?.isNotEmpty == true && RegExp(r'^[0-9.]+$').hasMatch(value!)) ? null : IpAddressValidationError.invalid;
  }
}