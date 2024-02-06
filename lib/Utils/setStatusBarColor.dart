import 'package:zipchat/Configs/app_constants.dart';
import 'package:zipchat/Utils/color_detector.dart';
import 'package:zipchat/Utils/theme_management.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

setStatusBarColor(SharedPreferences prefs) {
  if (Thm.isDarktheme(prefs) == true) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: zipchatAPPBARcolorDarkMode,
        statusBarIconBrightness: isDarkColor(zipchatAPPBARcolorDarkMode)
            ? Brightness.light
            : Brightness.dark));
  } else {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: zipchatAPPBARcolorLightMode,
        statusBarIconBrightness: isDarkColor(zipchatAPPBARcolorLightMode)
            ? Brightness.light
            : Brightness.dark));
  }
}
