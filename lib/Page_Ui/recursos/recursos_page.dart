import 'package:flutter/material.dart';
import 'package:proyecto_final/Color/Color.dart';
import 'package:proyecto_final/Page_Ui/widgets/metro_app_bar.dart';
import 'package:proyecto_final/services/firebase_services.dart' as api;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_final/Page_Ui/validator/validar_alfa_num.dart';
import 'package:proyecto_final/Page_Ui/widgets/custom_message_dialog.dart';
import 'package:proyecto_final/Page_Ui/recursos/history_dialog.dart';

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
      appBar: MetroAppBar(
        title: 'Recursos materiales',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context, '/proyectos_lista', (route) => false),
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
                    title: Text(nombre,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(desc.isEmpty ? 'Sin descripción' : desc),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Total: $total'),
                            Text('Disponible: $disp',
                                style: const TextStyle(color: Colors.teal)),
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
                            tooltip: 'Historial de uso',
                            icon: const Icon(Icons.history),
                            onPressed: () => showHistoryDialog(context, r),
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
    final nombreCtrl =
        TextEditingController(text: (resource?['nombre'] ?? '').toString());
    final descCtrl = TextEditingController(
        text: (resource?['descripcion'] ?? '').toString());
    final totalCtrl = TextEditingController(
        text: (resource?['cantidad_total'] ?? '').toString());
    final dispCtrl = TextEditingController(
        text: (resource?['cantidad_disponible'] ?? '').toString());
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(resource == null ? 'Nuevo recurso' : 'Editar recurso'),
          content: SizedBox(
            width: 420,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nombreCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    inputFormatters: alfaNumEsFormatters(maxLength: 60),
                    validator: (v) =>
                        validarAlfaNum(v, campo: 'Nombre', maxLength: 60),
                  ),
                  TextFormField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                    inputFormatters: alfaNumEsFormatters(maxLength: 120),
                    validator: (v) =>
                        validarAlfaNum(v, campo: 'Descripción', maxLength: 120),
                  ),
                  TextFormField(
                    controller: totalCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Cantidad total'),
                    keyboardType: TextInputType.number,
                    inputFormatters: soloNumerosFormatters(maxLength: 9),
                    validator: (v) =>
                        validarSoloNumeros(v, campo: 'Cantidad total'),
                  ),
                  if (resource != null && _isAdmin) ...[
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: dispCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Cantidad disponible (opcional)',
                        helperText:
                            'Si se deja vacío, se recalcula según total',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: soloNumerosFormatters(maxLength: 9),
                      validator: (v) {
                        final s = (v ?? '').trim();
                        if (s.isEmpty) return null; // opcional
                        return validarSoloNumeros(s,
                            campo: 'Cantidad disponible');
                      },
                    ),
                  ],
                ],
              ),
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
                if (!formKey.currentState!.validate()) return;
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
                    final dispTxt = dispCtrl.text.trim();
                    final disp = dispTxt.isEmpty ? null : int.tryParse(dispTxt);
                    // Validación simple en cliente
                    int? boundedDisp = disp;
                    if (boundedDisp != null) {
                      if (boundedDisp < 0) boundedDisp = 0;
                      if (boundedDisp > total) boundedDisp = total;
                    }
                    await api.updateRecursoMaterial(docId,
                        nombre: nombre,
                        descripcion: descCtrl.text.trim(),
                        cantidadTotal: total,
                        cantidadDisponible: boundedDisp);
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
    // Filtrar proyectos para usuarios normales: solo aquellos donde participa su correo
    if (!_isAdmin) {
      final emailLower = (_email ?? '').trim().toLowerCase();
      proyectos = proyectos.where((p) {
        final detalles = (p['integrantes_detalle'] ?? []) as List;
        for (final i in detalles) {
          if (i is Map) {
            final mail = (i['email'] ?? '').toString().trim().toLowerCase();
            if (mail.isNotEmpty && mail == emailLower) return true;
          }
        }
        return false;
      }).toList();
    }
    proyectos.sort((a, b) => (a['nombre_proyecto'] ?? '')
        .toString()
        .compareTo((b['nombre_proyecto'] ?? '').toString()));

    List<String> tareas = [];

    final assignFormKey = GlobalKey<FormState>();
    await showDialog(
      context: context,
      builder: (context) {
        String? errorMessage;
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Asignar recurso a tarea'),
            content: SizedBox(
              width: 480,
              child: Form(
                key: assignFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    DropdownButtonFormField<String>(
                      value: proyectoDocId,
                      decoration: const InputDecoration(labelText: 'Proyecto'),
                      items: proyectos
                          .map((p) => DropdownMenuItem<String>(
                                value: (p['docId'] ?? '').toString(),
                                child: Text(
                                    (p['nombre_proyecto'] ?? '').toString()),
                              ))
                          .toList(),
                      onChanged: (v) async {
                        proyectoDocId = v;
                        tareas = [];
                        if (v != null && v.isNotEmpty) {
                          final snap = await api.db
                              .collection('list_proyecto')
                              .doc(v)
                              .get();
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
                          .map((k) => DropdownMenuItem<String>(
                              value: k, child: Text(k)))
                          .toList(),
                      onChanged: (v) {
                        tareaKey = v;
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: '1',
                      decoration: const InputDecoration(
                          labelText: 'Cantidad a asignar'),
                      keyboardType: TextInputType.number,
                      inputFormatters: soloNumerosFormatters(maxLength: 9),
                      validator: (v) {
                        final err =
                            validarSoloNumeros(v, campo: 'Cantidad a asignar');
                        if (err != null) return err;
                        final n = int.tryParse(v ?? '');
                        if (n == null || n <= 0) return 'Debe ser mayor a 0';
                        return null;
                      },
                      onChanged: (v) {
                        final n = int.tryParse(v.trim());
                        cantidad = n ?? 0;
                      },
                    ),
                  ],
                ),
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
                  setState(() => errorMessage = null);
                  if (!assignFormKey.currentState!.validate()) return;
                  if (proyectoDocId == null ||
                      (tareaKey == null || tareaKey!.isEmpty)) {
                    setState(
                        () => errorMessage = 'Seleccione proyecto y tarea');
                    return;
                  }
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
                    showMessageDialog(context, 'Recurso asignado');
                  } catch (e) {
                    setState(() {
                      String msg = e.toString();
                      if (e is FirebaseException && e.message != null) {
                        msg = e.message!;
                      } else {
                        msg = msg.replaceAll('Exception: ', '');
                        // Manejo específico para el error de "converted Future" en Web
                        if (msg.contains(
                            'Dart exception thrown from converted Future')) {
                          msg = 'No hay suficiente disponible.';
                        }
                      }
                      errorMessage = msg;
                    });
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
