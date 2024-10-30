import 'package:flutter/material.dart';

class DefaultElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double borderRadius;
  final double width;
  final double height;
  final IconData? icon;
  final double iconSpacing;
  final bool iconBefore;
  final bool isWhiteStyle;

  const DefaultElevatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.borderRadius = 14.0,
    this.width = double.infinity,
    this.height = 50.0,
    this.icon,
    this.iconSpacing = 8.0,
    this.iconBefore = true,
    this.isWhiteStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonBackgroundColor = isWhiteStyle ? Colors.white : Colors.indigo;
    final buttonForegroundColor = isWhiteStyle ? Colors.indigo : Colors.white;

    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(maximumSize: Size(width, height),
          backgroundColor: buttonBackgroundColor,
          foregroundColor: buttonForegroundColor,
          minimumSize: Size(width, height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: isWhiteStyle
                ? const BorderSide(color: Colors.indigo)
                : BorderSide.none,
          ),
        ),
        child: icon == null
            ? child
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: iconBefore
                    ? [
                        Icon(icon),
                        SizedBox(width: iconSpacing),
                        child,
                      ]
                    : [
                        child,
                        SizedBox(width: iconSpacing),
                        Icon(icon),
                      ],
              ),
      ),
    );
  }
}
