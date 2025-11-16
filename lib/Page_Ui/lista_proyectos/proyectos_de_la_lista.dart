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
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        decoration: BoxDecoration(
          color: _isHovering ? Colors.grey[200] : Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double w = constraints.maxWidth;
            final bool isMobile = w < 550;
            if (isMobile) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GraficoPizza(proyectos: widget.proyectos),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.proyectos['title'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildActions(compact: true),
                  const SizedBox(height: 6),
                  _buildFechasRow(compact: true),
                ],
              );
            }
            // Desktop / tablet layout
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GraficoPizza(proyectos: widget.proyectos),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.proyectos['title'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildActions(),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _buildFechasRow(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFechasRow({bool compact = false}) {
    final txtStyle = TextStyle(fontSize: compact ? 12 : 14);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.calendar_today, size: 16),
        Text('Inicio: ${widget.proyectos['fecha_inicio']}', style: txtStyle),
        Text('Entrega: ${widget.proyectos['fecha_entrega']}', style: txtStyle),
      ],
    );
  }

  Widget _buildActions({bool compact = false}) {
    final double iconSize = compact ? 20 : 24;
    final EdgeInsets padding = compact
        ? const EdgeInsets.symmetric(horizontal: 0)
        : const EdgeInsets.symmetric(horizontal: 4);
    return Wrap(
      spacing: compact ? 3 : 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Likes: ${widget.proyectos['like'] ?? 0}',
          style: TextStyle(fontSize: compact ? 14 : 16),
        ),
        _iconBtn(
          tooltip: 'Dar like',
          icon: Icons.thumb_up_alt_outlined,
          color: Colors.blueAccent,
          iconSize: iconSize,
          padding: padding,
          onPressed: () async {
            final docId = widget.proyectos['docId']?.toString();
            if (docId != null && docId.isNotEmpty) {
              await fs.incrementarLikeProyecto(docId);
            }
          },
        ),
        _iconBtn(
          tooltip: 'Comentarios',
          icon: Icons.chat_bubble_outline,
          color: Colors.deepPurple,
          iconSize: iconSize,
          padding: padding,
          onPressed: () {
            final args = {
              'docId': widget.proyectos['docId']?.toString(),
              'id_proyecto': widget.proyectos['id_proyecto'],
              'title': widget.proyectos['title'],
            };
            Navigator.pushNamed(context, '/foro_page', arguments: args);
          },
        ),
        if (!widget.isAdmin && widget.canAddLink)
          _iconBtn(
            tooltip: 'Presupuesto',
            icon: Icons.attach_money,
            color: Colors.orange,
            iconSize: iconSize,
            padding: padding,
            onPressed: () {
              final args = {
                'docId': widget.proyectos['docId']?.toString(),
                'id_proyecto': widget.proyectos['id_proyecto'],
                'title': widget.proyectos['title'],
              };
              Navigator.pushNamed(context, '/finanzas_proyecto',
                  arguments: args);
            },
          ),
        _iconBtn(
          tooltip: 'Tareas',
          icon: Icons.assignment_turned_in_outlined,
          color: Colors.green,
          iconSize: iconSize,
          padding: padding,
          onPressed: () {
            final docId = widget.proyectos['docId']?.toString();
            if (docId != null && docId.isNotEmpty) {
              showDialog(
                context: context,
                builder: (_) => TareasDialog(
                  docId: docId,
                  tituloProyecto: widget.proyectos['title'] ?? '',
                ),
              );
            }
          },
        ),
        if (!widget.isAdmin && widget.canAddLink)
          _iconBtn(
            tooltip: 'Agregar enlace',
            icon: Icons.add_link,
            color: Colors.blueGrey,
            iconSize: iconSize,
            padding: padding,
            onPressed: () async {
              final docId = widget.proyectos['docId']?.toString();
              if (docId == null || docId.isEmpty) return;
              final result = await showDialog<Map<String, String>>(
                context: context,
                builder: (_) => const ArchivoDialog(),
              );
              if (result != null) {
                final url = result['url']?.trim();
                if (url != null && url.isNotEmpty) {
                  try {
                    await fs.addLinkProyecto(docId, url);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Enlace agregado: ${result['nombre'] ?? 'Recurso'}',
                        ),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al guardar enlace: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
          ),
        if (widget.isAdmin)
          _iconBtn(
            tooltip: 'Estado/Tareas masivo',
            icon: Icons.rule_folder_outlined,
            color: Colors.orangeAccent,
            iconSize: iconSize,
            padding: padding,
            onPressed: () async {
              final docId = widget.proyectos['docId']?.toString();
              if (docId == null || docId.isEmpty) return;
              final action = await showDialog<String>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Acción masiva'),
                  content:
                      const Text('Aplicar a TODAS las tareas del proyecto:'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, 'cancel'),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, 'reset'),
                      child: const Text('Reiniciar'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, 'complete'),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Todas las tareas completadas'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } else if (action == 'reset') {
                try {
                  await fs.setTodasLasTareas(docId, false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Todas las tareas reiniciadas'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        if (widget.isAdmin)
          _iconBtn(
            tooltip: 'Borrar proyecto',
            icon: Icons.delete_outline,
            color: Colors.red,
            iconSize: iconSize,
            padding: padding,
            onPressed: () async {
              final docId = widget.proyectos['docId']?.toString();
              final nombre =
                  widget.proyectos['title']?.toString() ?? 'este proyecto';
              if (docId == null || docId.isEmpty) return;
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Confirmar borrado'),
                  content: Text(
                      '¿Seguro que deseas borrar "$nombre"? Esta acción no se puede deshacer.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Borrar'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                try {
                  await fs.deleteProyecto(docId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Proyecto borrado correctamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al borrar: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
      ],
    );
  }

  Widget _iconBtn({
    required String tooltip,
    required IconData icon,
    required Color color,
    required double iconSize,
    required EdgeInsets padding,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      tooltip: tooltip,
      padding: padding,
      iconSize: iconSize,
      constraints: const BoxConstraints(),
      visualDensity: VisualDensity.compact,
      icon: Icon(icon, color: color),
      onPressed: onPressed,
    );
  }
}
