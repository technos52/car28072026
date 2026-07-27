import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:DealMatee/core/constants/app_color.dart';

class TapWrapper extends StatelessWidget {
  const TapWrapper({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.keyLabel,
    this.borderRadius = 0,
    this.focusNode,
  });
  final Widget child;
  final VoidCallback? onTap;
  final void Function()? onLongPress;
  final String? keyLabel;
  final double borderRadius;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        focusNode: focusNode,
        splashFactory: InkRipple.splashFactory,
        overlayColor: WidgetStateProperty.all(
          AppColor.primary.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        key: child.key,
        onTap: onTap == null
            ? null
            : () {
                if (onTap != null) onTap!();
                SystemSound.play(SystemSoundType.click);
              },
        onLongPress: onLongPress,
        child: child,
      ),
    );
  }
}
