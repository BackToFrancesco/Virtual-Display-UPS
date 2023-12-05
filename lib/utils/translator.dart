import 'package:excel/excel.dart';

import 'excel_reader.dart';

class Translator {
  Sheet? _translationSheet;

  String _targetLanguage = "English";

  late final Map<String, int> _langToLangId;

  late final List<String> _textId;

  static bool _initialized = false;

  static late final Translator _translator;

  factory Translator() {
    return _translator;
  }

  Translator._internal(this._translationSheet) {
    Map<String, int> temp = {};
    List<Data?> langNameRow = _translationSheet!.rows.elementAt(412);
    for (int i = 7; i < langNameRow.length; i += 4) {
      temp[langNameRow.elementAt(i)!.value.toString()] = i;
    }
    _langToLangId = temp;
    int rowCount = _translationSheet!.maxRows;
    List<dynamic> ids = _translationSheet!.selectRangeValues(
        CellIndex.indexByString("B4"),
        end: CellIndex.indexByString("B$rowCount"));
    _textId = ids
        .map((s) => s.toString().substring(1, s.toString().length - 1))
        .toList();
  }

  static Future<void> init() async {
    if (!_initialized) {
      _translator = Translator._internal(getSheet(
          await getExcel("assets/traduction_file/texts.xlsm"), "Translation"));
      _initialized = true;
    }
  }

  String get targetLanguage => _targetLanguage;

  List<String> getLanguages() {
    return List<String>.from(_langToLangId.keys);
  }

  void setTargetLanguageIfExists(String targetLanguage) {
    if (_langToLangId.containsKey(targetLanguage)) {
      _targetLanguage = targetLanguage;
    }
  }

  String translateIfExists(String word, {bool capitalize = true}) {
    int rowIndex = _textId.indexOf(word.toUpperCase());
    String toRet;
    if (rowIndex != -1) {
      toRet = _translationSheet!
          .cell(CellIndex.indexByColumnRow(
              columnIndex: _langToLangId[_targetLanguage],
              rowIndex: 3 + rowIndex))
          .value;
    } else {
      toRet = word.replaceAll("_", " ");
    }
    if (capitalize && toRet.isNotEmpty) {
      if (toRet.length > 1) {
        toRet = toRet[0].toUpperCase() + toRet.substring(1).toLowerCase();
      } else {
        toRet = toRet[0].toUpperCase();
      }
    }
    return toRet;
  }
}
