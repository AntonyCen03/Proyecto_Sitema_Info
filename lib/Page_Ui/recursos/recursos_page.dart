import 'package:flutter/material.dart';
import 'package:proyecto_final/Color/Color.dart';
import 'package:proyecto_final/services/firebase_services.dart' as api;
import 'package:firebase_auth/firebase_auth.dart';

class RecursosPage extends StatefulWidget {
  const RecursosPage({super.key});

  @override
  State<RecursosPage> createState() => _RecursosPageState();
}

class _RecursosPageState extends State<RecursosPage> {
  String? _email;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _email = FirebaseAuth.instance.currentUser?.email;
    _initPerms();
  }

  Future<void> _initPerms() async {
    try {
      final adm = await api.isCurrentUserAdmin(context);
      if (!mounted) return;
      setState(() => _isAdmin = adm);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isAdmin = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text('Recursos materiales'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: primaryOrange,
              icon: const Icon(Icons.add),
              label: const Text('Nuevo recurso'),
              onPressed: () => _showUpsertDialog(),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: api.streamRecursosMateriales(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snap.data ?? const [];
            if (data.isEmpty) {
              return const Center(child: Text('No hay recursos registrados'));
            }
            return ListView.separated(
              itemCount: data.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final r = data[i];
                final nombre = (r['nombre'] ?? '').toString();
                final desc = (r['descripcion'] ?? '').toString();
                final total = (r['cantidad_total'] ?? 0).toString();
                final disp = (r['cantidad_disponible'] ?? 0).toString();
                return Card(
                  color: Colors.white,
                  child: ListTile(
                    title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(desc.isEmpty ? 'Sin descripción' : desc),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Total: $total'),
                            Text('Disponible: $disp', style: const TextStyle(color: Colors.teal)),
                          ],
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          tooltip: 'Asignar a tarea',
                          icon: const Icon(Icons.assignment_turned_in_outlined),
                          onPressed: () => _showAssignDialog(r),
                        ),
                        if (_isAdmin)
                          IconButton(
                            tooltip: 'Editar',
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showUpsertDialog(resource: r),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _showUpsertDialog({Map<String, dynamic>? resource}) async {
    final nombreCtrl = TextEditingController(text: (resource?['nombre'] ?? '').toString());
    final descCtrl = TextEditingController(text: (resource?['descripcion'] ?? '').toString());
    final totalCtrl = TextEditingController(text: (resource?['cantidad_total'] ?? '').toString());

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(resource == null ? 'Nuevo recurso' : 'Editar recurso'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                TextField(
                  controller: totalCtrl,
                  decoration: const InputDecoration(labelText: 'Cantidad total'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryOrange),
              child: Text(resource == null ? 'Crear' : 'Guardar'),
              onPressed: () async {
                final nombre = nombreCtrl.text.trim();
                final total = int.tryParse(totalCtrl.text.trim());
                if (nombre.isEmpty || total == null || total < 0) return;
                if (resource == null) {
                  await api.addRecursoMaterial(
                    nombre: nombre,
                    descripcion: descCtrl.text.trim(),
                    cantidadTotal: total,
                  );
                } else {
                  final docId = (resource['docId'] ?? '').toString();
                  if (docId.isNotEmpty) {
                    await api.updateRecursoMaterial(docId,
                        nombre: nombre,
                        descripcion: descCtrl.text.trim(),
                        cantidadTotal: total);
                  }
                }
                if (mounted) Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAssignDialog(Map<String, dynamic> resource) async {
    String? proyectoDocId;
    String? tareaKey;
    int cantidad = 1;

    List<Map<String, dynamic>> proyectos = await api.getProyecto(context);
    proyectos.sort((a, b) => (a['nombre_proyecto'] ?? '').toString().compareTo((b['nombre_proyecto'] ?? '').toString()));

    List<String> tareas = [];

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Asignar recurso a tarea'),
            content: SizedBox(
              width: 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: proyectoDocId,
                    decoration: const InputDecoration(labelText: 'Proyecto'),
                    items: proyectos
                        .map((p) => DropdownMenuItem<String>(
                              value: (p['docId'] ?? '').toString(),
                              child: Text((p['nombre_proyecto'] ?? '').toString()),
                            ))
                        .toList(),
                    onChanged: (v) async {
                      proyectoDocId = v;
                      tareas = [];
                      if (v != null && v.isNotEmpty) {
                        final snap = await api.db.collection('list_proyecto').doc(v).get();
                        final data = snap.data() ?? <String, dynamic>{};
                        final t = data['tareas'];
                        if (t is Map) {
                          tareas = t.keys.map((e) => e.toString()).toList();
                          tareas.sort();
                        }
                      }
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: tareaKey,
                    decoration: const InputDecoration(labelText: 'Tarea'),
                    items: tareas
                        .map((k) => DropdownMenuItem<String>(value: k, child: Text(k)))
                        .toList(),
                    onChanged: (v) {
                      tareaKey = v;
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: '1',
                    decoration: const InputDecoration(labelText: 'Cantidad a asignar'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      final n = int.tryParse(v.trim());
                      cantidad = (n == null || n <= 0) ? 1 : n;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
                icon: const Icon(Icons.send),
                label: const Text('Asignar'),
                onPressed: () async {
                  if (proyectoDocId == null || (tareaKey == null || tareaKey!.isEmpty)) return;
                  final recursoId = (resource['docId'] ?? '').toString();
                  try {
                    await api.asignarRecursoATarea(
                      recursoId: recursoId,
                      proyectoDocId: proyectoDocId!,
                      tareaKey: tareaKey!,
                      cantidad: cantidad,
                      asignadoPorEmail: _email,
                    );
                    if (mounted) Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recurso asignado')));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }
}
