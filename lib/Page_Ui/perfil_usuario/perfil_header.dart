import 'package:flutter/material.dart';

class PerfilHeader extends StatelessWidget {
  final String nombre;
  final String grado;
  final VoidCallback? onSettings;

  const PerfilHeader({
    Key? key,
    required this.nombre,
    required this.grado,
    this.onSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final nameStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.grey[900],
    );
    final roleStyle = const TextStyle(
      color: Color(0xFF06B6D4),
      fontSize: 13,
      fontWeight: FontWeight.w600,
    );

    return Row(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7DD3FC), Color(0xFF06B6D4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.person, size: 40, color: Colors.white),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(nombre, style: nameStyle),
            const SizedBox(height: 6),
            Text(grado, style: roleStyle),
          ],
        ),
        const Spacer(),
        if (onSettings != null)
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              size: 26,
              color: Color(0xFF06B6D4),
            ),
            onPressed: onSettings,
            tooltip: 'Ajustes',
          ),
      ],
    );
  }
}
