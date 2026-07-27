import 'package:flutter/material.dart';

class Hbox extends StatelessWidget {
  const Hbox(this.h, {this.width, super.key});
  final double h;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: h,
      width: width,
    );
  }
}

class Wbox extends StatelessWidget {
  const Wbox(this.w, {this.height, super.key});
  final double w;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: w,
      height: height,
    );
  }
}
