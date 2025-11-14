import 'package:flutter/material.dart';
import 'package:proyecto_final/Page_Ui/lista_proyectos/Grafico_pizza.dart';
import 'package:proyecto_final/Page_Ui/lista_proyectos/TareasDialog.dart';
import 'package:proyecto_final/services/firebase_services.dart' as fs;
import 'package:proyecto_final/Page_Ui/crear_proyecto/archivo_dialog.dart';

//Esta clase se encarga de crear los InkWell que se usaran para la lista de proyectos en la interfaz de usuario.
class ProyectosDeLaLista extends StatefulWidget {
  final Map<String, dynamic> proyectos;
  final VoidCallback onTap;
  final bool isAdmin;
  final bool canAddLink;
  final String? currentUserEmail;

  const ProyectosDeLaLista({
    super.key,
    required this.proyectos,
    required this.onTap,
    this.isAdmin = false,
    this.canAddLink = false,
    this.currentUserEmail,
  });

  @override
  State<ProyectosDeLaLista> createState() => PLista();
}

class PLista extends State<ProyectosDeLaLista> {
  bool _isHovering = false;

  final co = <List<Color>>[
    [Colors.blue, Colors.red],
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: widget.onTap,
        onHover: (isHovering) {
          setState(() {
            _isHovering = isHovering;
          });
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 10.0),
          decoration: BoxDecoration(
            color: _isHovering ? Colors.grey[200] : Colors.transparent,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              GraficoPizza(proyectos: widget.proyectos),
              SizedBox(width: 16),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.proyectos['title'],
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Text('Likes: ${widget.proyectos['like'] ?? 0}',
                                style: TextStyle(fontSize: 16)),
                            SizedBox(width: 8),
                            IconButton(
                              tooltip: 'Dar like',
                              icon: Icon(Icons.thumb_up_alt_outlined,
                                  color: Colors.blueAccent),
                              onPressed: () async {
                                final docId =
                                    widget.proyectos['docId']?.toString();
                                if (docId != null && docId.isNotEmpty) {
                                  await fs.incrementarLikeProyecto(docId);
                                }
                              },
                            ),
                            SizedBox(width: 8),
                            IconButton(
                              tooltip: 'Comentarios',
                              icon: Icon(Icons.chat_bubble_outline,
                                  color: Colors.deepPurple),
                              onPressed: () {
                                final args = {
                                  'docId':
                                      widget.proyectos['docId']?.toString(),
                                  'id_proyecto':
                                      widget.proyectos['id_proyecto'],
                                  'title': widget.proyectos['title'],
                                };
                                Navigator.pushNamed(context, '/foro_page',
                                    arguments: args);
                              },
                            ),
                            SizedBox(width: 8),
                            IconButton(
                              tooltip: 'Tareas',
                              icon: Icon(Icons.assignment_turned_in_outlined,
                                  color: Colors.green),
                              onPressed: () {
                                final docId =
                                    widget.proyectos['docId']?.toString();
                                if (docId != null && docId.isNotEmpty) {
                                  showDialog(
                                    context: context,
                                    builder: (_) => TareasDialog(
                                      docId: docId,
                                      tituloProyecto:
                                          widget.proyectos['title'] ?? '',
                                    ),
                                  );
                                }
                              },
                            ),
                            if (!widget.isAdmin && widget.canAddLink) ...[
                              SizedBox(width: 8),
                              IconButton(
                                tooltip: 'Agregar enlace',
                                icon: const Icon(Icons.add_link,
                                    color: Colors.blueGrey),
                                onPressed: () async {
                                  final docId =
                                      widget.proyectos['docId']?.toString();
                                  if (docId == null || docId.isEmpty) return;
                                  final result =
                                      await showDialog<Map<String, String>>(
                                    context: context,
                                    builder: (_) => const ArchivoDialog(),
                                  );
                                  if (result != null) {
                                    final url = result['url']?.trim();
                                    if (url != null && url.isNotEmpty) {
                                      try {
                                        await fs.addLinkProyecto(docId, url);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Enlace agregado: ${result['nombre'] ?? 'Recurso'}')),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Error al guardar enlace: $e'),
                                              backgroundColor: Colors.red),
                                        );
                                      }
                                    }
                                  }
                                },
                              ),
                            ],
                            if (widget.isAdmin) ...[
                              SizedBox(width: 8),
                              IconButton(
                                tooltip: 'Estado/Tareas masivo',
                                icon: const Icon(Icons.rule_folder_outlined,
                                    color: Colors.orangeAccent),
                                onPressed: () async {
                                  final docId =
                                      widget.proyectos['docId']?.toString();
                                  if (docId == null || docId.isEmpty) return;
                                  final action = await showDialog<String>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Acción masiva'),
                                      content: const Text(
                                          'Aplicar a TODAS las tareas del proyecto:'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, 'cancel'),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, 'reset'),
                                          child: const Text('Reiniciar'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, 'complete'),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green),
                                          child: const Text('Completados'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (action == 'complete') {
                                    try {
                                      await fs.setTodasLasTareas(docId, true);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Todas las tareas completadas'),
                                              backgroundColor: Colors.green));
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text('Error: $e'),
                                              backgroundColor: Colors.red));
                                    }
                                  } else if (action == 'reset') {
                                    try {
                                      await fs.setTodasLasTareas(docId, false);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Todas las tareas reiniciadas'),
                                              backgroundColor: Colors.orange));
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text('Error: $e'),
                                              backgroundColor: Colors.red));
                                    }
                                  }
                                },
                              ),
                              SizedBox(width: 8),
                              IconButton(
                                tooltip: 'Borrar proyecto',
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red),
                                onPressed: () async {
                                  final docId =
                                      widget.proyectos['docId']?.toString();
                                  final nombre =
                                      widget.proyectos['title']?.toString() ??
                                          'este proyecto';
                                  if (docId == null || docId.isEmpty) return;
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Confirmar borrado'),
                                      content: Text(
                                          '¿Seguro que deseas borrar "$nombre"? Esta acción no se puede deshacer.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: const Text('Borrar'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    try {
                                      await fs.deleteProyecto(docId);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Proyecto borrado correctamente'),
                                            backgroundColor: Colors.green),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content:
                                                Text('Error al borrar: $e'),
                                            backgroundColor: Colors.red),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Icon(Icons.calendar_today, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Inicio: ${widget.proyectos['fecha_inicio']}',
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Entrega: ${widget.proyectos['fecha_entrega']}',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
