import 'package:flutter/material.dart';

class DefaultElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double borderRadius;
  final double width;
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const DefaultElevatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.borderRadius = 10.0,
    this.width = double.infinity,
    this.height = 50.0,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.black45,
          foregroundColor: foregroundColor ?? Colors.white,
          minimumSize: Size(width, height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: child,
      ),
    );
  }
}
