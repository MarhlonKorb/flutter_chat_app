import 'package:flutter/material.dart';

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool? centerTitle;
  final bool? permiteRetornar;

  const DefaultAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle,
    this.permiteRetornar,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.indigo,
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      actions: actions,
      leading: leading,
    );
  }

  // Implementação do tamanho preferido da AppBar
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
