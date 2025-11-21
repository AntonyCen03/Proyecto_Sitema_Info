import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  Future<String> _uploadToImgBB(XFile picked) async {
    // ---------------------------------------------------------
    // 1. Ve a https://api.imgbb.com/
    // 2. Crea una cuenta o inicia sesión.
    // 3. Obtén tu "API Key" (botón "Get API Key" o "Crear clave").
    // 4. Pégala aquí abajo:
    // ---------------------------------------------------------
    const apiKey =
        '12bfd2a3556a84a5bdce706c3d1376ec'; // Reemplaza con tu API Key

    final uri = Uri.parse('https://api.imgbb.com/1/upload');
    final request = http.MultipartRequest('POST', uri);

    request.fields['key'] = apiKey;

    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'image', // ImgBB espera el campo 'image'
        bytes,
        filename: picked.name,
      ));
    } else {
      request.files
          .add(await http.MultipartFile.fromPath('image', picked.path));
    }

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonMap = jsonDecode(responseString);
      if (jsonMap['success'] == true) {
        return jsonMap['data']['url'];
      } else {
        throw Exception('Error ImgBB: ${jsonMap['status']}');
      }
    } else {
      throw Exception('Error subiendo a ImgBB: ${response.statusCode}');
    }
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
      // Subir a ImgBB (Gratis)
      final url = await _uploadToImgBB(picked);

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
