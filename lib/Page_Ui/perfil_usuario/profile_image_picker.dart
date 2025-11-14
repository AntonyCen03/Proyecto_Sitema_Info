import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_final/services/auth_service.dart';
import 'package:proyecto_final/services/firebase_services.dart'; // Asegúrate de que aquí esté tu función 'uploadProfileImage'

class ProfileImagePicker extends StatefulWidget {
  final String? photoUrl;
  final double radius;
  final ValueChanged<String>? onUploaded;
  const ProfileImagePicker(
      {super.key, this.photoUrl, this.radius = 40.0, this.onUploaded});

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  String? _photoUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _photoUrl = widget.photoUrl;
  }

  // Esto soluciona el problema si la 'photoUrl' del widget padre
  // se carga después de que este widget se inicializa.
  @override
  void didUpdateWidget(ProfileImagePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.photoUrl != oldWidget.photoUrl && widget.photoUrl != _photoUrl) {
      setState(() {
        _photoUrl = widget.photoUrl;
      });
    }
  }

  // --- COMIENZA CÓDIGO DE DEPURACIÓN ---

  Future<void> _pickAndUpload(ImageSource source) async {
    final picker = ImagePicker();

    print("--- 2. Abriendo el selector de imagen (Fuente: $source) ---");

    final XFile? picked = await picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (picked == null) {
      print(
          "--- 3. ERROR SILENCIOSO: El usuario canceló o picked es null. ---");
      return;
    }

    print("--- 4. Imagen seleccionada: ${picked.path} ---");

    final file = File(picked.path);
    final bytes = await file.length();
    const maxBytes = 2 * 1024 * 1024; // 2 MB

    if (bytes > maxBytes) {
      print(
          "--- 5. ERROR SILENCIOSO: La imagen es muy grande ($bytes bytes). Límite: $maxBytes bytes. ---");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('La imagen supera 2 MB. Elija otra más ligera.')),
      );
      return;
    }

    print("--- 6. Imagen válida. Tamaño: $bytes bytes. Subiendo... ---");
    setState(() => _isUploading = true);

    try {
      final currentUser = AuthService().currentUser;
      if (currentUser == null) {
        print("--- 7. ERROR EN TRY: No hay usuario autenticado. ---");
        throw Exception('No hay un usuario autenticado');
      }

      final uid = currentUser.uid;
      print("--- 8. Usuario: $uid. Llamando a uploadProfileImage... ---");

      // Aquí se llama a tu función de servicio, que ya sube Y actualiza Firestore
      final url = await uploadProfileImage(file, uid);

      print("--- 9. ¡ÉXITO! URL obtenida: $url ---");

      if (!mounted) return;
      setState(() {
        _photoUrl = url;
        _isUploading = false;
      });

      // Notifica al widget padre (opcional, pero buena práctica)
      if (url.isNotEmpty) widget.onUploaded?.call(url);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Foto de perfil actualizada exitosamente.')),
      );
    } catch (e, stackTrace) {
      if (!mounted) return;
      setState(() => _isUploading = false);

      print('----------- ERROR CATASTRÓFICO AL SUBIR -----------');
      print('ERROR: $e');
      print('STACKTRACE: $stackTrace');
      print('---------------------------------------------');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error subiendo la imagen: $e')),
      );
    }
  }

  void _showPickerOptions() {
    print("--- 1. Mostrando opciones (Galería/Cámara) ---");
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Seleccionar de la galería'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickAndUpload(ImageSource.gallery);
              },
            ),
            // He añadido la opción de cámara como sugerencia
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar una foto'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickAndUpload(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancelar'),
              onTap: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }

  // --- FIN CÓDIGO DE DEPURACIÓN ---

  @override
  Widget build(BuildContext context) {
    final radius = widget.radius;
    final avatar = _photoUrl != null && _photoUrl!.isNotEmpty
        ? CircleAvatar(
            radius: radius,
            backgroundImage: NetworkImage(_photoUrl!),
            onBackgroundImageError: (e, s) {
              // Añadido para depurar errores de carga de imagen de red
              print("Error cargando NetworkImage: $e");
            },
          )
        : CircleAvatar(
            radius: radius,
            backgroundImage: const AssetImage('assets/images/usuariopng.webp'),
          );

    return Column(
      children: [
        Stack(
          children: [
            avatar,
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _isUploading ? null : _showPickerOptions,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: _isUploading
                      ? SizedBox(
                          width: radius * 0.4,
                          height: radius * 0.4,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Icon(Icons.camera_alt,
                          color: Colors.white, size: radius * 0.45),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
