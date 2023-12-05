import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_display/repositories/modbus_data_repository/models/modbus_data_manager/managers/states_manager.dart';
import 'package:virtual_display/utils/translator.dart';
import '../modbus_helper.dart';

void main() async{
  TestWidgetsFlutterBinding.ensureInitialized();
  await Translator.init();

  StatesManager statesManager = StatesManager();

  statesManager.states = ExpectedState.states;
  
  test('set states sets the correct states', () {
    expect(statesManager.states, ExpectedState.states);
  });

  test('getStates returns the correct states, the second state in a "Load supplied in normal mode"', () {
    expect(statesManager.getStates(), ExpectedState.getState);
  });

  test('getStateValueByIndex returns the correct states values', () {
    for (var index = 0; index < 128; index++) {
      expect(statesManager.getStateValueByIndex(index), ExpectedState.getStateValueByIndex[index]);
    }
  });
}