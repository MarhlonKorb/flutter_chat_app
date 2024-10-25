import 'package:flutter/material.dart';

class DefaultTextFormField extends StatelessWidget {
  final String labelText;
  final IconData? icon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final Color? iconColor;
  final bool obscureText;
  final FocusNode? focusNode;
  final void Function()? onTap;

  const DefaultTextFormField({
    super.key,
    required this.labelText,
    required this.icon,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.iconColor,
    this.obscureText = false,
    this.focusNode, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: onTap,
      controller: controller,
      focusNode: focusNode,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: Icon(
          size: 20,
          icon,
          color: iconColor ?? Colors.indigoAccent,
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.indigoAccent),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );
  }
}
