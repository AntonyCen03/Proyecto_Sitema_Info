import 'package:flutter/material.dart';
import 'package:proyecto_final/Color/Color.dart';

/// AppBar reutilizable para toda la app.
///
/// Uso básico:
///   appBar: MetroAppBar(title: 'Dashboard');
/// Con acciones:
///   appBar: MetroAppBar(title: 'Reportes', actions: [IconButton(...)])
class MetroAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final List<Widget>? actions;
  final bool implyLeading;
  final VoidCallback? onBackPressed;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;

  const MetroAppBar({
    super.key,
    required this.title,
    this.centerTitle = true,
    this.actions,
    this.implyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0.5,
    this.onBackPressed,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ??
        Theme.of(context).appBarTheme.backgroundColor ??
        colorFondo;
    final fg = foregroundColor ??
        Theme.of(context).appBarTheme.foregroundColor ??
        primaryOrange;
    final Widget? leadingWidget = leading ??
        (onBackPressed != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBackPressed,
              )
            : null);
    return AppBar(
      automaticallyImplyLeading: implyLeading && leadingWidget == null,
      leading: leadingWidget,
      backgroundColor: bg,
      foregroundColor: fg,
      elevation: elevation,
      title: Text(title),
      centerTitle: centerTitle,
      actions: actions,
    );
  }
}
