import 'package:flutter/material.dart';
import 'package:proyecto_final/Page_Ui/widgets/metro_app_bar.dart';
import 'package:proyecto_final/services/auth_service.dart';
import 'package:proyecto_final/services/firebase_services.dart';
import 'package:flutter/services.dart';

import 'perfil_header.dart';
import 'editable_item.dart';
import 'package:proyecto_final/Color/Color.dart';

class PerfilUsuarioNew extends StatefulWidget {
  const PerfilUsuarioNew({Key? key}) : super(key: key);

  @override
  State<PerfilUsuarioNew> createState() => _PerfilUsuarioNewState();
}

class _PerfilUsuarioNewState extends State<PerfilUsuarioNew> {
  String nombre = '';
  String correo = '';
  String? photoUrl;
  String carnet = '';
  String cedula = '';
  String grado = '';
  String ultimaConexion = '';
  String uid = '';
  bool _isLoading = true;


  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final users = await getUser(context);
      if (!mounted) return;
      final currentEmail = AuthService().currentUser?.email?.toString().trim();
      Map<String, dynamic>? user;
      if (currentEmail != null && currentEmail.isNotEmpty) {
        try {
          user = users.cast<Map<String, dynamic>>().firstWhere(
                (u) => (u['email'] ?? '').toString().trim() == currentEmail,
              );
        } catch (_) {
          user = users.isNotEmpty ? users.first : null;
        }
      } else {
        user = users.isNotEmpty ? users.first : null;
      }

      setState(() {
        correo = user?['email']?.toString() ?? '';
        nombre = user?['name']?.toString() ?? '';
        photoUrl = user?['photo_url']?.toString() ?? '';
        carnet = user?['id_carnet']?.toString() ?? '';
        cedula = user?['cedula']?.toString() ?? '';
        ultimaConexion = user?['date_login']?.toString() ?? '';
        uid = user?['uid']?.toString() ?? '';
        grado = (user?['isadmin'] == true) ? 'Administrador' : 'Usuario';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        correo = AuthService().currentUser?.email ?? '';
        _isLoading = false;
      });
    }
  }

  Future<void> _persistAll() async {
    // Invoca updateUser con los valores actuales en memoria (nombre, carnet, cedula, uid)
    // Normalizar: eliminar cualquier caracter que no sea dígito antes de convertir
    final carnetDigits = carnet.replaceAll(RegExp(r'\D'), '');
    final carnetInt = int.tryParse(carnetDigits) ?? 0;
    // Asegurar que la cédula solo contenga dígitos
    final cedulaDigits = cedula.replaceAll(RegExp(r'\D'), '');
    try {
      await updateUser(nombre, carnetInt, cedulaDigits, uid);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Usuario actualizado')));
      await _loadUser();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error actualizando: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      appBar: MetroAppBar(
        title: 'Perfil Usuario',
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryOrange),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context, '/principal', (route) => false),
        ),
      ),
      body: _isLoading
          ? SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(height: 200),
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Cargando perfil...'),
                  ],
                ),
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Container(
                    width: 720,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        // Información del usuario (arriba) — avatar integrado a la izquierda
                        PerfilHeader(
                          nombre: nombre.isNotEmpty ? nombre : 'Sin nombre',
                          grado: grado,
                          photoUrl: photoUrl,
                          onSettings: () {},
                          onUploaded: (url) async {
                            // Refrescar de inmediato la imagen sin esperar a Firestore
                            setState(() => photoUrl = url);
                            // Opcional: recargar para asegurar consistencia con Firestore
                            await _loadUser();
                          },
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: grisClaro,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              EditableItem(
                                label: 'Nombre',
                                value: nombre,
                                editable: true,
                                onSaved: (v) async {
                                  setState(() => nombre = v);
                                  await _persistAll();
                                },
                              ),
                              const SizedBox(height: 10),
                              EditableItem(
                                label: 'Correo Electrónico',
                                value: correo,
                                editable: false,
                              ),
                              const SizedBox(height: 10),
                              EditableItem(
                                label: 'Carnet',
                                value: carnet,
                                editable: true,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (v) {
                                  if (v.isEmpty) return 'Ingrese el carnet';
                                  if (!RegExp(r'^\d+$').hasMatch(v))
                                    return 'El carnet solo puede contener números.';
                                  if (v.length != 11)
                                    return 'El carnet debe tener exactamente 11 dígitos.';
                                  return null;
                                },
                                onSaved: (v) async {
                                  setState(() => carnet = v);
                                  await _persistAll();
                                },
                              ),
                              const SizedBox(height: 10),
                              EditableItem(
                                label: 'Cedula',
                                value: cedula,
                                editable: true,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (v) {
                                  if (v.isEmpty) return 'Ingrese la cédula';
                                  if (!RegExp(r'^\d+$').hasMatch(v))
                                    return 'La cédula solo puede contener números.';
                                  if (v.length < 6 || v.length > 8)
                                    return 'La cédula debe tener entre 6 y 8 dígitos.';
                                  return null;
                                },
                                onSaved: (v) async {
                                  setState(() => cedula = v);
                                  await _persistAll();
                                },
                              ),
                              const SizedBox(height: 10),
                              EditableItem(
                                label: 'Ultima Conexion',
                                value: ultimaConexion,
                                editable: false,
                              ),
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, '/cambiar_contrasena');
                                },
                                child: const Text('Cambiar Contraseña'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
