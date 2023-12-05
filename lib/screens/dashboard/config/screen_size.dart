import 'package:flutter/widgets.dart';

class SizeConfig {
  static MediaQueryData _mediaQueryData = const MediaQueryData();
  static double screenWidth = 0.0;
  static double screenHeight = 0.0;
  static double blockSizeHorizontal = 0.0;
  static double blockSizeVertical = 0.0;
  static double _safeAreaHorizontal = 0.0;
  static double _safeAreaVertical = 0.0;
  static double safeBlockHorizontal = 0.0;
  static double safeBlockVertical = 0.0;
  static double safeVBlocHorizontal = 0.0;

  void safeVBlockHorizontalSet() {
    if ((safeBlockVertical / safeBlockHorizontal) < 0.4) {
      safeVBlocHorizontal = safeBlockVertical * 2;
    }
    if ((safeBlockVertical / safeBlockHorizontal) >= 0.4 &&
        (safeBlockVertical / safeBlockHorizontal) < 0.5) {
      safeVBlocHorizontal = safeBlockVertical * 1.8;
    }
    if ((safeBlockVertical / safeBlockHorizontal) >= 0.5 &&
        (safeBlockVertical / safeBlockHorizontal) < 0.6) {
      safeVBlocHorizontal = safeBlockVertical * 1.6;
    }
    if ((safeBlockVertical / safeBlockHorizontal) >= 0.6 &&
        (safeBlockVertical / safeBlockHorizontal) < 0.7) {
      safeVBlocHorizontal = safeBlockVertical * 1.5;
    }
    if ((safeBlockVertical / safeBlockHorizontal) >= 0.7 &&
        (safeBlockVertical / safeBlockHorizontal) < 0.8) {
      safeVBlocHorizontal = safeBlockVertical * 1.4;
    }
    if ((safeBlockVertical / safeBlockHorizontal) >= 0.8) {
      safeVBlocHorizontal = safeBlockVertical * 1.2;
    }
  }

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;
    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
    safeVBlockHorizontalSet();
  }
}
