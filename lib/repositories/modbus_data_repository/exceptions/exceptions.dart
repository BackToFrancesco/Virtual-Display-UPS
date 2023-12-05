class ModbusException implements Exception {
  final String _msg;

  const ModbusException(this._msg);

  String get msg => _msg;

  @override
  String toString() => msg;
}

class ModbusUnreachableIpPortException extends ModbusException {
  ModbusUnreachableIpPortException(
      {required String ipAddress, required int port})
      : super("Cannot reach $ipAddress:$port");
}

class ModbusBadSlaveIdException extends ModbusException {
  ModbusBadSlaveIdException() : super("Bad slave id");
}

class ModbusIllegalFunctionException extends ModbusException {
  ModbusIllegalFunctionException() : super('Illegal Function');
}

class ModbusIllegalAddressException extends ModbusException {
  ModbusIllegalAddressException() : super('Illegal Address');
}

class ModbusConnectorErrorException extends ModbusException {
  ModbusConnectorErrorException(String cause) : super(cause);
}

class ModbusInvalidDataException extends ModbusException {
  ModbusInvalidDataException() : super('Invalid data');
}

class ModbusUnknownErrorCodeException extends ModbusException {
  ModbusUnknownErrorCodeException(String errorCode)
      : super('Unknown error code: $errorCode');
}
