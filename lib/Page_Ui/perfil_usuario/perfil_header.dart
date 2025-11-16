import 'package:flutter/material.dart';
import 'package:proyecto_final/Color/Color.dart';
import 'profile_image_picker.dart';

class PerfilHeader extends StatelessWidget {
  final String nombre;
  final String grado;
  final VoidCallback? onSettings;
  final String? photoUrl;
  final ValueChanged<String>? onUploaded;

  const PerfilHeader({
    Key? key,
    required this.nombre,
    required this.grado,
    this.onSettings,
    this.photoUrl,
    this.onUploaded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final nameStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.grey[900],
    );
    final roleStyle = const TextStyle(
      color: primaryOrange,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    );

    return Row(
      children: [
        SizedBox(
          width: 76,
          height: 76,
          child: ProfileImagePicker(
            photoUrl: photoUrl,
            radius: 36,
            onUploaded: onUploaded,
          ),
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
              Icons.settings,
              size: 26,
              color: primaryOrange,
            ),
            onPressed: onSettings,
            tooltip: 'Ajustes',
          ),
      ],
    );
  }
}
