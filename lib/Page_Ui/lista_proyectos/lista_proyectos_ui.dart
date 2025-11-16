import 'package:flutter/material.dart';
import 'package:proyecto_final/Page_Ui/lista_proyectos/proyectos_de_la_lista.dart';
import 'package:proyecto_final/Color/Color.dart';
import 'dart:math';
import 'package:number_pagination/number_pagination.dart';
import 'package:proyecto_final/Page_Ui/widgets/metro_app_bar.dart';
import 'package:proyecto_final/services/firebase_services.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

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
  String usuarioEmailLower = "";

  @override
  void initState() {
    super.initState();
    administrador = false;
    _setupAdminAndStream();
  }

  Future<void> _setupAdminAndStream() async {
    // Obtener si el usuario es admin y su email en minúsculas
    final isAdmin = await isCurrentUserAdmin(context);
    final emailLower =
        FirebaseAuth.instance.currentUser?.email?.trim().toLowerCase() ?? '';
    setState(() {
      administrador = isAdmin;
      usuarioEmailLower = emailLower;
    });

    // Suscribirse al stream y filtrar por email si no es admin
    _proyectosSub = streamProyecto().listen((lista) {
      final filtrados = administrador
          ? lista
          : lista.where((p) {
              final integrantes = (p['integrantes_detalle'] ?? []) as List;
              for (final i in integrantes) {
                if (i is Map) {
                  final mail =
                      (i['email'] ?? '').toString().trim().toLowerCase();
                  if (mail.isNotEmpty && mail == usuarioEmailLower) return true;
                }
              }
              return false;
            }).toList();

      final mapeados = _mapearProyectosUI(filtrados);
      setState(() {
        proyectos = mapeados;
        ids.clear();
        arrreglarlista();
        reorganizarlista();
        arreglarlistaproyectos();
        listadeproyectos = proyectoslist();
      });
    });
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
        padding: const EdgeInsets.all(24),
        child: cuerpo(),
      ),
    );
  }

  Widget cuerpo() {
    // Este metodo crea el cuerpo de la UI de la lista de proyectos (responsive)
    return LayoutBuilder(builder: (context, constraints) {
      final double maxW = constraints.maxWidth;
      final bool isWide = maxW >= 1200;
      final bool isMedium = maxW >= 800 && maxW < 1200;
      final bool isNarrow = maxW < 800;

      // Tamaños más compactos para la barra de proyecto
      final double titleSize = isWide ? 36 : (isMedium ? 28 : 22);
      final double searchHeight = 40;
      final double searchMaxWidth =
          isWide ? 360 : (isMedium ? 280 : double.infinity);

      return Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(255, 255, 255, 1),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título + Botón Crear Proyecto
            isNarrow
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 16),
                          Text(
                            "Proyectos",
                            style: TextStyle(
                              color: primaryOrange,
                              fontSize: titleSize,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (administrador) ...[
                              _crearProyectoButton(),
                              const SizedBox(width: 8),
                            ],
                            _recursosButton(),
                          ],
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 16),
                          Text(
                            "Proyectos",
                            style: TextStyle(
                              color: primaryOrange,
                              fontSize: titleSize,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (administrador) ...[
                            _crearProyectoButton(),
                            const SizedBox(width: 8),
                          ],
                          _recursosButton(),
                        ],
                      ),
                    ],
                  ),

            const SizedBox(height: 10.0),
            const Divider(),
            const SizedBox(height: 10.0),

            // Filtros + Buscador + (opcional) botón admin
            isNarrow
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          filtros(),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ConstrainedBox(
                              constraints:
                                  BoxConstraints(maxWidth: searchMaxWidth),
                              child: SizedBox(
                                height: searchHeight,
                                child: _searchField(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          filtros(),
                          const SizedBox(width: 10),
                          ConstrainedBox(
                            constraints:
                                BoxConstraints(maxWidth: searchMaxWidth),
                            child: SizedBox(
                                height: searchHeight, child: _searchField()),
                          ),
                        ],
                      ),
                    ],
                  ),

            const SizedBox(height: 8.0),
            // Lista de proyectos
            Expanded(child: listadeproyectos),
            const SizedBox(height: 12.0),
            // Paginación
            cambiosdepagina(),
          ],
        ),
      );
    });
  }

  // Campo de búsqueda reutilizable
  Widget _searchField() {
    return TextField(
      decoration: InputDecoration(
        hintText:
            const Text('Buscar proyecto', style: TextStyle(fontSize: 12)).data,
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onChanged: (value) => buscador(value),
    );
  }

  // Botón de crear proyecto reutilizable
  Widget _crearProyectoButton() {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.pushNamed(context, '/crear_proyecto');
      },
      icon: Icon(Icons.add, color: primaryOrange, size: 16),
      label: Text("Crear Proyecto",
          style: TextStyle(color: primaryOrange, fontSize: 14)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        side: BorderSide(color: primaryOrange, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        textStyle: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
      ),
    );
  }

  // Botón para abrir la página de recursos materiales
  Widget _recursosButton() {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.pushNamed(context, '/recursos');
      },
      icon: Icon(Icons.inventory_2_outlined, color: primaryBlue, size: 16),
      label:
          Text("Recursos", style: TextStyle(color: primaryBlue, fontSize: 14)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        side: BorderSide(color: primaryBlue, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        textStyle: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
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
      final participantesEmails = ((p['integrantes_detalle'] ?? []) as List)
          .whereType<Map>()
          .map((m) => (m['email'] ?? '').toString().trim().toLowerCase())
          .where((s) => s.isNotEmpty)
          .toList();
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
        'participantes_emails': participantesEmails,
        // Extras por si se requieren luego
        'docId': p['docId'],
        'id_proyecto': p['id_proyecto'],
        'presupuesto_solicitado': p['presupuesto_solicitado'],
        'presupuesto_aprobado': p['presupuesto_aprobado'],
        'presupuesto_motivo': p['presupuesto_motivo'],
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
      padding: const EdgeInsets.all(16),
      children: listaproyectos.sublist(inicio, fin),
    );
  }

  Widget cambiosdepagina() {
    //Este metodo crea la paginacion de la lista de proyectos
    return NumberPagination(
      totalPages: (listaproyectos.length / 5).ceil(),
      currentPage: paginaActual,
      fontSize: 13.0,
      buttonRadius: 20.0,
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
            final docId = proyectos[ids[i]]['docId']?.toString();
            if (docId != null && docId.isNotEmpty) {
              Navigator.pushNamed(
                context,
                '/crear_proyecto',
                arguments: {
                  'docId': docId,
                },
              );
            }
          },
          isAdmin: administrador,
          canAddLink: !administrador &&
              ((proyectos[ids[i]]['participantes_emails'] as List?)
                      ?.cast<String>()
                      .contains(usuarioEmailLower) ??
                  false),
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
        final emails =
            (proyectos[i]['participantes_emails'] as List?)?.cast<String>() ??
                const <String>[];
        if (emails.contains(usuarioEmailLower)) {
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
