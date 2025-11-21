import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_final/services/firebase_services.dart' as fs;

class TareasDialog extends StatefulWidget {
  final String docId;
  final String tituloProyecto;
  const TareasDialog(
      {super.key, required this.docId, required this.tituloProyecto});

  @override
  State<TareasDialog> createState() => _TareasDialogState();
}

class _TareasDialogState extends State<TareasDialog> {
  String? _nombreActual;
  String? _cedulaActual;

  @override
  void initState() {
    super.initState();
    _cargarUsuarioActual();
  }

  Future<void> _cargarUsuarioActual() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final email = user?.email?.trim().toLowerCase();
      if (email == null || email.isEmpty) return;
      final usuarios = await fs.getUser(context);
      for (final u in usuarios) {
        final uEmail = (u['email'] ?? '').toString().trim().toLowerCase();
        if (uEmail == email) {
          setState(() {
            _nombreActual = (u['name'] ?? '').toString();
            _cedulaActual = (u['cedula'] ?? '').toString();
          });
          break;
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Tareas - ${widget.tituloProyecto}'),
      content: SizedBox(
        width: 500,
        height: 400,
        child: StreamBuilder<Map<String, dynamic>?>(
          stream: fs.streamProyectoDoc(widget.docId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data;
            if (data == null) {
              return const Center(child: Text('No se encontró el proyecto.'));
            }
            final tareasRaw = (data['tareas'] ?? {}) as Map?;
            final tareas = tareasRaw
                    ?.map((key, value) => MapEntry(key.toString(), value)) ??
                <String, dynamic>{};
            if (tareas.isEmpty) {
              return const Center(child: Text('No hay tareas registradas.'));
            }
            final keys = tareas.keys.toList()..sort();
            return ListView.builder(
              itemCount: keys.length,
              itemBuilder: (context, index) {
                final k = keys[index];
                final v = tareas[k];
                bool done = false;
                String nombre = '';
                String cedula = '';
                DateTime? fechaTermino;
                if (v is Map) {
                  done = v['done'] == true;
                  nombre = (v['nombre'] ?? '').toString();
                  cedula = (v['cedula'] ?? '').toString();
                  final ts = v['fecha_termino'];
                  if (ts is Timestamp) {
                    fechaTermino = ts.toDate();
                  }
                } else if (v is bool) {
                  done = v;
                }
                String? fechaTexto;
                if (fechaTermino != null) {
                  final d = fechaTermino;
                  String two(int n) => n.toString().padLeft(2, '0');
                  fechaTexto =
                      '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
                }
                return CheckboxListTile(
                  value: done,
                  title: Text(k),
                  subtitle: done &&
                          (nombre.isNotEmpty ||
                              cedula.isNotEmpty ||
                              fechaTexto != null)
                      ? Text(
                          'Completado por ${nombre}${cedula.isNotEmpty ? " ($cedula)" : ""}${fechaTexto != null ? " el " + fechaTexto : ""}')
                      : null,
                  onChanged: done
                      ? null
                      : (val) async {
                          final nuevo = val ?? false;
                          await fs.setTareaEstado(
                            widget.docId,
                            k,
                            nuevo,
                            nombre: nuevo ? (_nombreActual ?? '') : null,
                            cedula: nuevo ? (_cedulaActual ?? '') : null,
                          );
                        },
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}
