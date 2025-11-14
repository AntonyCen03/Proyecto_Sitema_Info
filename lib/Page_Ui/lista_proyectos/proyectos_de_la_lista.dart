import 'package:flutter/material.dart';
import 'package:proyecto_final/Page_Ui/lista_proyectos/Grafico_pizza.dart';
import 'package:proyecto_final/Page_Ui/lista_proyectos/TareasDialog.dart';
import 'package:proyecto_final/services/firebase_services.dart' as fs;

//Esta clase se encarga de crear los InkWell que se usaran para la lista de proyectos en la interfaz de usuario.
class ProyectosDeLaLista extends StatefulWidget {
  final Map<String, dynamic> proyectos;
  final VoidCallback onTap;

  const ProyectosDeLaLista({
    super.key,
    required this.proyectos,
    required this.onTap,
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
