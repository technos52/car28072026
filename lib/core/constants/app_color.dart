import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppColor {
  static const primary = Color(0xFF73BAEE);
  static const secondary = Color(0xFF14256B);
  static const black = Color(0xFF000000);
  static const textcolor = Color(0xFF11183C);

  // Shades of grey
  static const gray600 = Color(0xFF212121);
  static const gray550 = Color(0xFF606060);
  static const gray500 = Color(0xFF7B7B7B);
  static const gray400 = Color(0xFFA4A5A8);
  static const gray350 = Color(0xFFC7C7C7);
  static const gray300 = Color(0xFFCECECE);
  static const gray200 = Color(0xFFE3E3E3);
  static const gray100 = Color(0xFFF4F4F4);
  static const white = Color(0xFFFFFFFF);
  static const textfieldDarkBg = Color(0xFF292929);
  static const cardDarkBg = Color(0xFF363636);
  static const Color grey = Color(0xFFB8B8B8);

  // Shades of blue
  static const blue900 = Color(0xFF0D47A1);
  static const blue800 = Color(0xFF003B4A);
  static const blue700 = Color(0xFF003B4A);
  static const blue600 = Color(0xFF003B4A);
  static const blue500 = Color(0xFF005A7E);
  static const blue400 = Color(0xFF0086C3);
  static const blue300 = Color(0xFF00A6E0);
  static const blue200 = Color(0xFF00B9F2);
  static const blue100 = Color(0xFF00C7FF);

  // Shades of green
  static const green600 = Color(0xFF0E7460);

  // System
  static const success = Color(0xFF0E7460);
  static const error = Color(0xFFB64040);
  static const warning = Color(0xFFCE9320);
  static const systemBlue = Color(0xFF007AFF);

  static const scaffoldBg = Colors.white;

  static Color themeColor(Color lightTheme, Color darkTheme) {
    return Get.theme.brightness == Brightness.dark ? darkTheme : lightTheme;
  }

  static Color contextThemeColor(
    BuildContext context,
    Color lightTheme,
    Color darkTheme,
  ) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTheme
        : lightTheme;
  }

  /// Converts [Color] to [MaterialColor]
  static MaterialColor buildMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}

const String iosPackage = 'com.visiondgtech.smsjewellery';
String projectName = "High Furries";
String aboutUSUrl = "https://highfurries.com/about/";
const String iosLink = 'https://apps.apple.com/id';
const String iosAppId = '1:901655269491:ios:addc91b7c566e8c86e9a06';
String appPackageName = "com.visiondgtech.phbr";
const String androidLink = 'https://play.google.com/store/apps/details?id=';
