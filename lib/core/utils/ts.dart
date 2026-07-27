import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart'; // Temporarily commented out

/// This class handles text styling and sizing of the app.
///
/// The main styles are:
/// - [_regular] - Regular text having [FontWeight.w400]
/// - [_medium] - Medium text having [FontWeight.w500]
/// - [_semiBold] - Light text having [FontWeight.w600]
/// - [_bold] - Bold text having [FontWeight.w700]
class Ts {
  static TextStyle _style({
    double? size,
    Color? color,
    FontWeight? fontWeight,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    // If app font style needs to be changed in future, change it here and in [textTheme]
    return TextStyle(
      fontWeight: fontWeight,
      fontSize: size,
      color: color,
      decoration: isUnderline ? TextDecoration.underline : null,
      fontStyle: isItalic ? FontStyle.italic : null,
      backgroundColor: bgColor,
    );
  }

  /// Applies the given font family to every [TextStyle] in the given [textTheme].
  static TextTheme textTheme([TextTheme? textTheme]) =>
      textTheme ?? const TextTheme(); // Temporarily using default theme

  /// The font family used throughout the app.
  static String? fontFamily = _style().fontFamily;

  /// Textstyle without any font weight or size.
  static TextStyle style({
    double? size,
    Color? color,
    FontWeight? fontWeight,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _style(
      size: size,
      color: color,
      fontWeight: fontWeight,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle _regular(
    double? size, {
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _style(
      size: size,
      color: color,
      fontWeight: FontWeight.w400,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle _medium(
    double? size, {
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _style(
      size: size,
      color: color,
      fontWeight: FontWeight.w500,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle _semiBold(
    double? size, {
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _style(
      size: size,
      color: color,
      fontWeight: FontWeight.w600,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle _bold(
    double? size, {
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _style(
      size: size,
      color: color,
      fontWeight: FontWeight.w700,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle bold({
    double? size,
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _bold(
      size,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle bold10({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _bold(
      10,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle bold11({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _bold(
      11,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle bold12({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _bold(
      12,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle bold13({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _bold(
      13,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle bold14({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _bold(
      14,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle bold15({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _bold(
      15,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle bold16({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _bold(
      16,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle bold17({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _bold(
      17,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle bold18({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _bold(
      18,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle bold19({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _bold(
      19,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle bold20({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _bold(
      20,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle bold21({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _bold(
      21,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle bold22({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _bold(
      22,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle bold23({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _bold(
      23,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle bold24({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _bold(
      24,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle bold25({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _bold(
      25,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle bold26({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _bold(
      26,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle bold27({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _bold(
      27,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle bold28({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _bold(
      28,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle bold29({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _bold(
      29,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle bold30({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _bold(
      30,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle bold31({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _bold(
      31,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle bold32({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _bold(
      32,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle semiBold({
    double? size,
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _semiBold(
      size,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle semiBold8({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _semiBold(
      8,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle semiBold10({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _semiBold(
      10,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle semiBold11({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _semiBold(
      11,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle semiBold12({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _semiBold(
      12,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle semiBold13({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _semiBold(
      13,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle semiBold14({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _semiBold(
      14,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle semiBold15({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _semiBold(
      15,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle semiBold16({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _semiBold(
      16,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle semiBold17({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _semiBold(
      17,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle semiBold18({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _semiBold(
      18,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle semiBold19({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _semiBold(
      19,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle semiBold20({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _semiBold(
      20,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle semiBold21({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _semiBold(
      21,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle semiBold22({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _semiBold(
      22,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle semiBold23({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _semiBold(
      23,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle semiBold24({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _semiBold(
      24,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle semiBold25({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _semiBold(
      25,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle semiBold26({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _semiBold(
      26,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle semiBold27({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _semiBold(
      27,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle semiBold28({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _semiBold(
      28,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle semiBold29({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _semiBold(
      29,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle semiBold30({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _semiBold(
      30,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle semiBold31({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _semiBold(
      31,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle semiBold32({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _semiBold(
      32,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle regular({
    double? size,
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _regular(
      size,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle regular8({
    double? size,
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _regular(
      8,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle regular10({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _regular(
      10,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle regular11({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _regular(
      11,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle regular12({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _regular(
      12,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle regular13({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _regular(
      13,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle regular14({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _regular(
      14,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle regular15({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _regular(
      15,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle regular16({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _regular(
      16,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle regular17({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _regular(
      17,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle regular18({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _regular(
      18,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle regular19({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _regular(
      19,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle regular20({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _regular(
      20,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle regular21({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _regular(
      21,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle regular22({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _regular(
      22,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle regular23({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _regular(
      23,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle regular24({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _regular(
      24,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle regular25({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _regular(
      25,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle regular26({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _regular(
      26,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle regular27({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _regular(
      27,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle regular28({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _regular(
      28,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle regular29({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _regular(
      29,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle regular30({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _regular(
      30,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle regular31({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _regular(
      31,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle regular32({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _regular(
      32,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle medium({
    double? size,
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _medium(
      size,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle medium10({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _medium(
      10,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle medium11({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _medium(
      11,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle medium12({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _medium(
      12,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle medium13({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _medium(
      13,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle medium14({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _medium(
      14,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle medium15({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _medium(
      15,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle medium16({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _medium(
      16,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle medium17({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _medium(
      17,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle medium18({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _medium(
      18,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle medium19({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _medium(
      19,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle medium20({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _medium(
      20,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle medium21({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _medium(
      21,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle medium22({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _medium(
      22,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle medium23({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _medium(
      23,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle medium24({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _medium(
      24,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle medium25({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _medium(
      25,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle medium26({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _medium(
      26,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle medium27({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _medium(
      27,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle medium28({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _medium(
      28,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle medium29({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _medium(
      29,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle medium30({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _medium(
      30,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle medium31({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _medium(
      31,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }

  static TextStyle medium32({
    Color? color,
    bool isUnderline = false,
    bool isItalic = false,
    Color? bgColor,
  }) {
    return _medium(
      32,
      color: color,
      isUnderline: isUnderline,
      isItalic: isItalic,
      bgColor: bgColor,
    );
  }
}
