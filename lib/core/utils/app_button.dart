import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:DealMatee/core/constants/app_color.dart';
import 'package:DealMatee/core/utils/ts.dart';

import 'app_text.dart';
import 'size.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    this.text,
    this.onPressed,
    this.isDisabled = false,
    this.isInProgress = false,
    this.isFullWidth = true,
    this.elevation = 1.0,
    this.textColor,
    this.bgColor,
    this.borderColor,
    this.borderWidth,
    this.icon,
    this.iconColor,
    this.textStyle,
    this.svg,
    this.height = 50,
    this.borderRadius = 10,
    this.horizontalPadding = 10,
    this.isLoading = false,
    this.useGradient = true, // Default to true for gradient
  });

  final String? text;
  final VoidCallback? onPressed;
  final bool isDisabled;
  final double? height;
  final bool isInProgress;
  final double elevation;
  final Color? textColor;
  final Color? bgColor;
  final Color? borderColor;
  final double? borderWidth;
  final bool isFullWidth;
  final IconData? icon;
  final Color? iconColor;
  final SvgPicture? svg;
  final double borderRadius;
  final bool isLoading;
  final TextStyle? textStyle;
  final double? horizontalPadding;
  final bool useGradient;

  // Default gradient from your color scheme
  static const LinearGradient defaultGradient = LinearGradient(
    colors: [
      Color(0xFF2CADD6), // #2CADD6 (Blue)
      Color(0xFF32CD32), // #32CD32 (Green)
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  double? get _buttonHeight {
    return height;
  }

  double get _padHor {
    return horizontalPadding ?? 0;
  }

  Color get _borderColor {
    if (isDisabled && !isInProgress) {
      return AppColor.gray300;
    }

    return borderColor != null ? borderColor! : bgColor ?? AppColor.primary;
  }

  double get _borderWidth => borderWidth ?? 1;

  Color get _bgColor {
    return (isDisabled && !isInProgress)
        ? (bgColor ?? AppColor.primary).withOpacity(0.5)
        : bgColor ?? AppColor.primary;
  }

  Color? get _textColor => textColor ?? Colors.white;

  Widget _wChild() {
    if (isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: _padHor),
        child: CupertinoActivityIndicator(
          color: textStyle?.color ?? _textColor,
        ),
      );
    }

    if (svg != null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: _padHor),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            svg!,
            const Wbox(10),
            AppText(
              text,
              style: textStyle ?? Ts.semiBold17(color: _textColor),
              maxLines: 1,
              isAutoSize: true,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _padHor),
      child: AppText(
        text,
        style: textStyle ?? Ts.semiBold17(color: _textColor),
        isAutoSize: true,
        maxLines: 1,
      ),
    );
  }

  Widget _wGradientButton() {
    return Container(
      width: isFullWidth ? double.maxFinite : null,
      height: _buttonHeight,
      decoration: BoxDecoration(
        gradient: isDisabled && !isInProgress
            ? LinearGradient(
                colors: [
                  defaultGradient.colors[0].withOpacity(0.5),
                  defaultGradient.colors[1].withOpacity(0.5),
                ],
                begin: defaultGradient.begin,
                end: defaultGradient.end,
              )
            : defaultGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderWidth != null
            ? Border.all(color: _borderColor, width: _borderWidth)
            : null,
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: elevation,
                  offset: Offset(0, elevation / 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: !isDisabled ? onPressed : null,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: _padHor),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: iconColor ?? textStyle?.color ?? _textColor,
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(child: _wChild()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _wRegularButton() {
    ButtonStyle buttonStyle = ButtonStyle(
      overlayColor: WidgetStateProperty.all<Color>(
        Colors.grey.withOpacity(0.2),
      ),
      elevation: WidgetStateProperty.all<double>(elevation),
      backgroundColor: WidgetStateProperty.all<Color>(_bgColor),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero),
      shape: WidgetStateProperty.all<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(width: _borderWidth, color: _borderColor),
        ),
      ),
    );

    if (icon != null) {
      return SizedBox(
        width: isFullWidth ? double.maxFinite : null,
        height: _buttonHeight,
        child: ElevatedButton.icon(
          style: buttonStyle,
          label: _wChild(),
          icon: Icon(icon, color: iconColor ?? textStyle?.color ?? _textColor),
          onPressed: !isDisabled ? onPressed : null,
        ),
      );
    }

    return SizedBox(
      width: isFullWidth ? double.maxFinite : null,
      height: _buttonHeight,
      child: ElevatedButton(
        style: buttonStyle,
        onPressed: !isDisabled ? onPressed : null,
        child: _wChild(),
      ),
    );
  }

  Widget _wButton() {
    // Use gradient button by default, unless useGradient is false
    if (useGradient) {
      return _wGradientButton();
    }
    return _wRegularButton();
  }

  @override
  Widget build(BuildContext context) {
    if (isInProgress) {
      return Opacity(opacity: 0.4, child: _wButton());
    }

    return _wButton();
  }
}
