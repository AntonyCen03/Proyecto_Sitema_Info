import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_final/services/auth_service.dart';
import 'package:proyecto_final/services/firebase_services.dart';

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

  Future<void> _pickAndUpload(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (picked == null) return;

    final file = File(picked.path);
    final bytes = await file.length();
    const maxBytes = 2 * 1024 * 1024; // 2 MB
    if (bytes > maxBytes) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('La imagen supera 2 MB. Elija otra más ligera.')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final currentUser = AuthService().currentUser;
      if (currentUser == null) {
        throw Exception('No hay un usuario autenticado');
      }
      final uid = currentUser.uid;
      final url = await uploadProfileImage(file, uid);
      if (!mounted) return;
      setState(() {
        _photoUrl = url;
        _isUploading = false;
      });

      if (url.isNotEmpty) widget.onUploaded?.call(url);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Foto de perfil actualizada exitosamente.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error subiendo la imagen: $e')),
      );
    }
  }

  void _showPickerOptions() {
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

  @override
  Widget build(BuildContext context) {
    final radius = widget.radius;
    final avatar = _photoUrl != null && _photoUrl!.isNotEmpty
        ? CircleAvatar(
            radius: radius,
            backgroundImage: NetworkImage(_photoUrl!),
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
