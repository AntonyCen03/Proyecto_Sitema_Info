import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_final/Color/Color.dart';
import 'package:proyecto_final/services/firebase_services.dart' as api;

class ProfileImagePicker extends StatefulWidget {
  final String? photoUrl;
  final double radius;
  final ValueChanged<String>? onUploaded;

  const ProfileImagePicker({
    Key? key,
    this.photoUrl,
    this.radius = 36,
    this.onUploaded,
  }) : super(key: key);

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  bool _uploading = false;

  Future<String> _uploadDirectToStorage(XFile picked, String contentType) async {
    final user = FirebaseAuth.instance.currentUser!;
    final storage = FirebaseStorage.instance;
    final name = picked.name.toLowerCase();
    String ext = 'jpg';
    if (name.endsWith('.png')) ext = 'png';
    if (name.endsWith('.webp')) ext = 'webp';
    if (name.endsWith('.gif')) ext = 'gif';
    final ts = DateTime.now().millisecondsSinceEpoch;
    final path = 'user_photos/${user.uid}/$ts.$ext';
    final ref = storage.ref().child(path);
    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      await ref
          .putData(bytes, SettableMetadata(contentType: contentType))
          .timeout(const Duration(seconds: 30));
    } else {
      final file = File(picked.path);
      await ref
          .putFile(file, SettableMetadata(contentType: contentType))
          .timeout(const Duration(seconds: 60));
    }
    final url = await ref.getDownloadURL().timeout(const Duration(seconds: 15));
    return url;
  }

  Future<void> _pickAndUpload() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final picker = ImagePicker();
    XFile? picked;
    try {
      picked = await picker.pickImage(
          source: ImageSource.gallery, maxWidth: 1024, imageQuality: 85);
    } catch (_) {
      picked = null;
    }
    if (picked == null) return;

    setState(() => _uploading = true);
    try {
        // Leer bytes y determinar contentType
        // Prepara bytes si necesitas validar tamaño en el futuro
        // final bytes = kIsWeb
        //   ? await picked.readAsBytes()
        //   : await File(picked.path).readAsBytes();
      // Detectar contentType por extensión simple
      final name = picked.name.toLowerCase();
      String contentType = 'image/jpeg';
      if (name.endsWith('.png')) contentType = 'image/png';
      if (name.endsWith('.webp')) contentType = 'image/webp';
      if (name.endsWith('.gif')) contentType = 'image/gif';

        // Subir directo a Firebase Storage
        final url = await _uploadDirectToStorage(picked, contentType);

      // Actualizar el documento correcto en 'user' buscando por email
      String? docId;
      try {
        final users = await api.getUser(context);
        final emailLower = (user.email ?? '').trim().toLowerCase();
        final match = users.cast<Map<String, dynamic>>().firstWhere(
              (u) =>
                  (u['email'] ?? '').toString().trim().toLowerCase() ==
                  emailLower,
              orElse: () => {},
            );
        docId = (match['uid'] ?? '').toString();
      } catch (_) {
        docId = null;
      }

      if (docId != null && docId.isNotEmpty) {
        await api.setUserPhotoUrl(docId, url);
      } else {
        // Fallback: intentar con uid de FirebaseAuth (si coincide con docId en colección user)
        await api.setUserPhotoUrl(user.uid, url);
      }

      if (widget.onUploaded != null) widget.onUploaded!(url);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto actualizada')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error subiendo imagen: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.radius;

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        InkWell(
          customBorder: const CircleBorder(),
          onTap: _uploading ? null : _pickAndUpload,
          child: CircleAvatar(
            radius: radius,
            backgroundColor: grisClaro,
            backgroundImage:
                (widget.photoUrl != null && widget.photoUrl!.isNotEmpty)
                    ? NetworkImage(widget.photoUrl!)
                    : null,
            child: (widget.photoUrl == null || widget.photoUrl!.isEmpty)
                ? Icon(Icons.person, size: radius, color: Colors.grey[600])
                : null,
          ),
        ),
        Positioned(
          right: 2,
          bottom: 2,
          child: CircleAvatar(
            radius: 14,
            backgroundColor: primaryOrange,
            child: _uploading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.camera_alt, size: 16, color: Colors.white),
          ),
        )
      ],
    );
  }
}
