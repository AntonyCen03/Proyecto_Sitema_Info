import 'package:flutter/material.dart';
import 'package:proyecto_final/Page_Ui/lista_proyectos/proyectos_de_la_lista.dart';
import 'package:proyecto_final/Color/Color.dart';
import 'dart:math';
import 'package:number_pagination/number_pagination.dart';
import 'package:proyecto_final/Page_Ui/widgets/metro_app_bar.dart';
import 'package:proyecto_final/services/firebase_services.dart';
import 'dart:async';

//Esta clase se encaraa de crear la lista de proyectos en la interfaz de usuario.
class ListaProyectos extends StatefulWidget {
  const ListaProyectos({super.key});

  @override
  State<ListaProyectos> createState() => ListaProyectosUi();
}

enum Filtro { views, percentaje, creation, finish, misproyectos }

class ListaProyectosUi extends State<ListaProyectos> {
  int paginaActual = 1;
  int numero = 0;
  bool administrador = true;
  List<Map<String, dynamic>> proyectos = [];
  StreamSubscription<List<Map<String, dynamic>>>? _proyectosSub;
  List<int> ids = [];
  List<Widget> listaproyectos = [];
  String filtro = "like";
  Widget listadeproyectos = Container();
  String usuarioActual = "Ana García";

  @override
  void initState() {
    administrador = false;
    // Suscribirse al stream de proyectos de Firestore y mapear al formato de UI
    _proyectosSub = streamProyecto().listen((lista) {
      final mapeados = _mapearProyectosUI(lista);
      setState(() {
        proyectos = mapeados;
        ids.clear();
        arrreglarlista();
        // Reaplicar filtro actual sobre la nueva data
        reorganizarlista();
        arreglarlistaproyectos();
        listadeproyectos = proyectoslist();
      });
    });
    // Inicializar lista vacía
    arrreglarlista();
    arreglarlistaproyectos();
    listadeproyectos = proyectoslist();
    super.initState();
  }

  @override
  void dispose() {
    _proyectosSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: colorFondo,
        extendBodyBehindAppBar: false,
        appBar: _buildAppBar(context),
        body: Padding(
          padding: EdgeInsetsGeometry.all(35),
          child: cuerpo(),
        ));
  }

  Widget cuerpo() {
    //Este metodo crea el cuerpo de la UI de la lista de proyectos
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 1),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        children: [
          Align(
            alignment: AlignmentGeometry.topLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(width: 26),
                    Text(
                      "Proyectos",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: primaryOrange,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/crear_proyecto');
                  },
                  icon: Icon(Icons.add, color: primaryOrange),
                  label: Text("Crear Proyecto", style: TextStyle(color: primaryOrange)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: primaryOrange, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    textStyle:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.0),
          Divider(),
          SizedBox(height: 10.0),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(
              children: [
                filtros(),
                SizedBox(
                  width: 10,
                ),
                SizedBox(
                  width: 300,
                  height: 37,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: Text('Buscar proyecto',
                              style: TextStyle(fontSize: 11))
                          .data,
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                    ),
                    onChanged: (value) {
                      buscador(value);
                    },
                  ),
                ),
              ],
            ),
            Visibility(
              visible: administrador,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Aqui hacer para unir lo de crear nuevo proyecto
                },
                icon: Icon(Icons.add),
                label: Text("Nuevo Proyecto"),
              ),
            )
          ]),
          SizedBox(height: 5.0),
          listadeproyectos,
          cambiosdepagina(),
        ],
      ),
    );
  }

  // Mapea documentos de Firestore al formato que espera la UI existente
  List<Map<String, dynamic>> _mapearProyectosUI(
      List<Map<String, dynamic>> lista) {
    String fmt(DateTime? d) {
      if (d == null) return '';
      final y = d.year.toString().padLeft(4, '0');
      final m = d.month.toString().padLeft(2, '0');
      final day = d.day.toString().padLeft(2, '0');
      return '$y-$m-$day';
    }

    double calcPercent(Map<String, dynamic>? tareasRaw) {
      if (tareasRaw == null || tareasRaw.isEmpty) return 0.0;
      int total = 0;
      int done = 0;
      tareasRaw.forEach((_, v) {
        total += 1;
        // Si viene en formato enriquecido {done: bool, ...}
        if (v is Map) {
          if (v['done'] == true) done += 1;
        } else if (v == true) {
          done += 1;
        }
      });
      if (total == 0) return 0.0;
      return (done * 100.0) / total;
    }

    final salida = <Map<String, dynamic>>[];
    for (int i = 0; i < lista.length; i++) {
      final p = lista[i];
      final participantes =
          (p['integrante'] as List?)?.map((e) => e.toString()).toList() ??
              <String>[];
      final percent =
          calcPercent((p['tareas'] as Map?)?.cast<String, dynamic>());
      salida.add({
        'id': i, // Importante: el algoritmo de la UI usa id como índice
        'title': (p['nombre_proyecto'] ?? '').toString(),
        'percent': percent,
        'like': (p['like'] is int) ? p['like'] as int : 0,
        'fecha_inicio': fmt(p['fecha_creacion'] as DateTime?),
        'fecha_entrega': fmt(p['fecha_entrega'] as DateTime?),
        'participantes': participantes,
        // Extras por si se requieren luego
        'docId': p['docId'],
        'id_proyecto': p['id_proyecto'],
      });
    }
    return salida;
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    //Este metodo crea la barra de navegacion superior
    return MetroAppBar(
      title: 'Lista de Proyectos',
      onBackPressed: () => Navigator.pushNamedAndRemoveUntil(
          context, '/principal', (route) => false),
      actions: [], //actions
    );
  }

  Widget proyectoslist() {
    //Este metodo crea la lista de proyectos que se mostrara en la UI
    final int inicio = numero;
    final int fin = min(numero + 5, listaproyectos.length);
    return ListView(
        shrinkWrap: true,
        primary: false,
        padding: const EdgeInsets.all(16),
        children: listaproyectos.sublist(inicio, fin));
  }

  Widget cambiosdepagina() {
    //Este metodo crea la paginacion de la lista de proyectos
    return NumberPagination(
      totalPages: (listaproyectos.length / 5).ceil(),
      currentPage: paginaActual,
      fontSize: 16.0,
      buttonRadius: 50.0,
      onPageChanged: (int page) {
        setState(() {
          numero = (page - 1) * 5;
          paginaActual = page;
          listadeproyectos = proyectoslist();
        });
      },
    );
  }

  Widget filtros() {
    //Este metodo crea el menu de filtros para la lista de proyectos
    return PopupMenuButton<Filtro>(
      onSelected: (Filtro result) {
        switch (result) {
          case Filtro.views:
            filtro = "like";
            reorganizarlista();
            break;
          case Filtro.percentaje:
            filtro = "percent";
            reorganizarlista();
            break;
          case Filtro.creation:
            filtro = "creation";
            reorganizarlista();
            break;
          case Filtro.finish:
            filtro = "finish";
            reorganizarlista();
            break;
          case Filtro.misproyectos:
            filtro = "misproyectos";
            reorganizarlista();
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<Filtro>>[
        const PopupMenuItem<Filtro>(
          value: Filtro.views,
          child: Text('Más Likes'),
        ),
        const PopupMenuItem<Filtro>(
          value: Filtro.percentaje,
          child: Text('Proyectos Finalizados'),
        ),
        const PopupMenuItem<Filtro>(
            value: Filtro.creation, child: Text('Más Recientes')),
        const PopupMenuItem<Filtro>(
            value: Filtro.finish, child: Text('Fecha de Entrega')),
        const PopupMenuItem<Filtro>(
            value: Filtro.misproyectos, child: Text('Mis Proyectos')),
      ],
      icon: Icon(Icons.filter_list),
      tooltip: "Filtrar Proyectos",
    );
  }

  void arreglarlistaproyectos() {
    //Aqui se crea la lista con la clase de proyectos_de_la_lista que se usara para mostrar los proyectos en el widget proyectoslist
    listaproyectos.clear();
    for (int i = 0; i < ids.length; i++) {
      listaproyectos.add(
        ProyectosDeLaLista(
          proyectos: proyectos[ids[i]],
          onTap: () {
            //Aqui antony debes de dar para que el usuario de click y se muestre la ventana con los datos del proyecto
          },
        ),
      );
    }
  }

  void arrreglarlista() {
    //Aqui se crea la lista de ids de los proyectos
    for (int i = 0; i < proyectos.length; i++) {
      ids.add(proyectos[i]['id']);
    }
  }

  void reorganizarlista() {
    //Aqui se reorganiza la lista de proyectos segun el filtro seleccionado
    ids.clear();
    arrreglarlista();
    if (filtro == 'like') {
      for (int i = 0; i < proyectos.length - 1; i++) {
        int posicion = i;
        for (int j = i + 1; j < proyectos.length; j++) {
          if (proyectos[ids[posicion]][filtro] < proyectos[ids[j]][filtro]) {
            posicion = j;
          }
        }
        if (posicion != i) {
          int aux = ids[i];
          ids[i] = ids[posicion];
          ids[posicion] = aux;
        }
      }
    } else if (filtro == 'percent') {
      ids.clear();
      for (int i = 0; i < proyectos.length; i++) {
        if (proyectos[i]['percent'] == 100.0) {
          ids.add(proyectos[i]['id']);
        }
      }
    } else if (filtro == 'creation') {
      for (int i = 0; i < proyectos.length - 1; i++) {
        int posicion = i;
        for (int j = i + 1; j < proyectos.length; j++) {
          DateTime fechaPosicion =
              DateTime.parse(proyectos[ids[posicion]]['fecha_inicio']);
          DateTime fechaJ = DateTime.parse(proyectos[ids[j]]['fecha_inicio']);
          if (fechaPosicion.isBefore(fechaJ)) {
            posicion = j;
          }
        }
        if (posicion != i) {
          int aux = ids[i];
          ids[i] = ids[posicion];
          ids[posicion] = aux;
        }
      }
    } else if (filtro == 'finish') {
      for (int i = 0; i < proyectos.length - 1; i++) {
        int posicion = i;
        for (int j = i + 1; j < proyectos.length; j++) {
          DateTime fechaPosicion =
              DateTime.parse(proyectos[ids[posicion]]['fecha_entrega']);
          DateTime fechaJ = DateTime.parse(proyectos[ids[j]]['fecha_entrega']);
          if (fechaPosicion.isAfter(fechaJ)) {
            posicion = j;
          }
        }
        if (posicion != i) {
          int aux = ids[i];
          ids[i] = ids[posicion];
          ids[posicion] = aux;
        }
      }
    } else if (filtro == 'misproyectos') {
      ids.clear();
      for (int i = 0; i < proyectos.length; i++) {
        if (proyectos[i]['participantes'].contains(usuarioActual)) {
          ids.add(proyectos[i]['id']);
        }
      }
    }

    setState(() {
      arreglarlistaproyectos();
      listadeproyectos = proyectoslist();
    });
  }

  void buscador(String value) {
    //Aqui se busca en la lista de proyectos el texto introducido en el buscador
    ids.clear();
    for (int i = 0; i < proyectos.length; i++) {
      if (proyectos[i]['title'].toLowerCase().contains(value.toLowerCase())) {
        ids.add(proyectos[i]['id']);
      }
    }
    setState(() {
      arreglarlistaproyectos();
      listadeproyectos = proyectoslist();
    });
  }
}
