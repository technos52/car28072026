import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:DealMatee/app/locale/locale.dart';

class AppText extends StatelessWidget {
  const AppText(
    this.text, {
    super.key,
    this.hasAnimation = false,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.isRich = false,
    this.padding = EdgeInsets.zero,
    this.translate = true,
    this.spans = const [],
    this.isAutoSize = false,
  });

  final String? text;
  final TextStyle? style;
  final bool isRich;
  final bool translate;
  final bool isAutoSize;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final EdgeInsets padding;
  final List<TextSpan> spans;

  final bool hasAnimation;

  String get textStr => translate ? (text ?? '').translate : text ?? '';

  Widget _wText() {
    if (isRich) {
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(text: textStr, style: style, locale: locale),
            ...spans,
          ],
        ),
        softWrap: softWrap ?? true,
        textAlign: textAlign ?? TextAlign.start,
        overflow: overflow ?? TextOverflow.clip,
        maxLines: maxLines,
        textDirection: textDirection,
      );
    }
    if (isAutoSize) {
      return AutoSizeText(
        textStr,
        style: style,
        textAlign: textAlign,
        overflow: overflow,
        maxLines: maxLines,
        textDirection: textDirection,
        locale: locale,
        softWrap: softWrap,
        minFontSize: 8,
      );
    }
    return Text(
      textStr,
      style: style,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
    );
  }

  Widget _wPadding() {
    return Padding(padding: padding, child: _wText());
  }

  @override
  Widget build(BuildContext context) {
    if (hasAnimation) return Hero(tag: text ?? '', child: _wPadding());
    return _wPadding();
  }
}
