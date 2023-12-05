import 'dart:typed_data';
import '../../../../../utils/translator.dart';
import '../../../utils/utils.dart' as utils;

class StatesManager {
  late Uint8List _states;
  late String _statesBinary;
  final Translator _translator = Translator();

  set states(Uint8List states) {
    String statesBinary = "";
    for (var i = 1; i < states.length; i++) {
      statesBinary += utils.uIntTo8bitString(states[i]);
    }
    _states = states;
    _statesBinary = statesBinary;
  }

  Uint8List get states => _states;

  List<String> getStates() {
    List<String> temp = [];
    for (int i = 0; i < _statesBinary.length; i++) {
      if (_statesBinary[i].compareTo("1") == 0) {
        temp.add("S" +
            utils.fillStringPaddingLeft(i.toString(), 3, "0") +
            ": " +
            _translator.translateIfExists(
                "S" + utils.fillStringPaddingLeft(i.toString(), 3, "0")));
      }
    }
    return temp;
  }

  int getStateValueByIndex(int index) {
    return int.parse(_statesBinary[index]);
  }
}
