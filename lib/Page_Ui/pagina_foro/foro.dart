import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_final/Page_Ui/widgets/metro_app_bar.dart';
import 'package:proyecto_final/Color/Color.dart';

class ForoPage extends StatefulWidget {
  const ForoPage({Key? key}) : super(key: key);

  @override
  State<ForoPage> createState() => _ForoPageState();
}

class _ForoPageState extends State<ForoPage> {
  final TextEditingController _mensajeController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Integrantes del proyecto para facilitar menciones
  final List<Map<String, String>> _integrantes = [];
  bool _cargandoIntegrantes = false;
  int? _idProyectoCargado;

  void enviarMensaje(int? idProyecto) async {
    if (_mensajeController.text.trim().isEmpty) return;

    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('foro_mensajes').add({
        'texto': _mensajeController.text.trim(),
        'usuario': user.email,
        'timestamp': FieldValue.serverTimestamp(),
        'id_proyecto': idProyecto, // guardar id del proyecto para filtrar
        'notificar': true,
      });
      _mensajeController.clear();
    }
  }

  Widget construirBurbujaMensajeConHora(
      String texto, String nombreUsuario, String hora, bool esPropio) {
    return Align(
      alignment: esPropio ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: esPropio ? const Color(0xFFDCF8C6) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(esPropio ? 12 : 0),
            bottomRight: Radius.circular(esPropio ? 0 : 12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 3,
              offset: const Offset(1, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              esPropio ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              texto,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  esPropio ? 'tú' : nombreUsuario,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 8),
                Text(
                  hora,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cargarIntegrantesProyecto(int idProyecto) async {
    if (_cargandoIntegrantes) return;
    setState(() {
      _cargandoIntegrantes = true;
    });
    try {
      final q = await _firestore
          .collection('list_proyecto')
          .where('id_proyecto', isEqualTo: idProyecto)
          .limit(1)
          .get();
      _integrantes.clear();
      if (q.docs.isNotEmpty) {
        final data = q.docs.first.data();
        final raw = data['integrante'];
        if (raw is List) {
          for (final e in raw) {
            if (e is Map) {
              final nombre = (e['nombre'] ?? e['name'] ?? '').toString();
              final email = (e['email'] ?? '').toString();
              if (email.isNotEmpty || nombre.isNotEmpty) {
                _integrantes.add({
                  'nombre': nombre,
                  'email': email,
                });
              }
            }
          }
        }
      }
    } catch (_) {
      // silencioso; opcionalmente mostrar snackbar
    } finally {
      if (mounted) {
        setState(() {
          _cargandoIntegrantes = false;
        });
      }
    }
  }

  void _insertMention(String email) {
    final text = _mensajeController.text;
    final sel = _mensajeController.selection;
    final insert = '@$email ';
    int base = sel.baseOffset;
    int extent = sel.extentOffset;
    if (base < 0 || extent < 0) {
      // sin selección previa, agregar al final
      _mensajeController.text = text + insert;
      _mensajeController.selection = TextSelection.fromPosition(
        TextPosition(offset: _mensajeController.text.length),
      );
      return;
    }
    final start = base < extent ? base : extent;
    final end = base < extent ? extent : base;
    final newText = text.replaceRange(start, end, insert);
    _mensajeController.text = newText;
    final caret = start + insert.length;
    _mensajeController.selection = TextSelection.fromPosition(
      TextPosition(offset: caret),
    );
  }

  Future<void> _abrirSelectorMencion(int? idProyecto) async {
    if (idProyecto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un proyecto para mencionar')),
      );
      return;
    }
    if (_idProyectoCargado != idProyecto) {
      _idProyectoCargado = idProyecto;
      await _cargarIntegrantesProyecto(idProyecto);
    }
    if (!mounted) return;
    if (_cargandoIntegrantes) return;

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        if (_integrantes.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No hay integrantes para mencionar.'),
          );
        }
        return SafeArea(
          child: ListView.separated(
            itemCount: _integrantes.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final it = _integrantes[i];
              final nombre = it['nombre'] ?? '';
              final email = it['email'] ?? '';
              return ListTile(
                leading: const Icon(Icons.alternate_email),
                title: Text(nombre.isNotEmpty ? nombre : email),
                subtitle:
                    nombre.isNotEmpty && email.isNotEmpty ? Text(email) : null,
                onTap: () {
                  Navigator.pop(context);
                  if (email.isNotEmpty) {
                    _insertMention(email);
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final dynamic rawId = args != null ? args['id_proyecto'] : null;
    final int? idProyecto =
        rawId is int ? rawId : (rawId is String ? int.tryParse(rawId) : null);
    final String? tituloProyecto =
        args != null ? args['title'] as String? : null;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          backgroundColor: Colors.orange,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            tituloProyecto != null && tituloProyecto.isNotEmpty
                ? 'Foro: ' + tituloProyecto
                : 'Foro General',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        body: Center(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.login),
            label: const Text('Iniciar sesión para usar el foro'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ),
      );
    }

    return Scaffold(
      appBar: MetroAppBar(
        title: (tituloProyecto != null && tituloProyecto.isNotEmpty)
            ? 'Foro: ' + tituloProyecto
            : 'Foro General',
        backgroundColor: grisClaro,
        foregroundColor: primaryOrange,
        onBackPressed: () => Navigator.pushNamedAndRemoveUntil(
            context, '/proyectos_lista', (route) => false),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: (idProyecto != null)
                  ? _firestore
                      .collection('foro_mensajes')
                      .where('id_proyecto', isEqualTo: idProyecto)
                      .snapshots()
                  : _firestore.collection('foro_mensajes').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final mensajes = snapshot.data!.docs.toList();
                // Ordenar por timestamp ascendente en cliente para evitar requerir índice compuesto
                mensajes.sort((a, b) {
                  final ta = a['timestamp'] as Timestamp?;
                  final tb = b['timestamp'] as Timestamp?;
                  final da = ta?.toDate();
                  final db = tb?.toDate();
                  if (da == null && db == null) return 0;
                  if (da == null) return -1;
                  if (db == null) return 1;
                  return da.compareTo(db);
                });

                Map<String, List<QueryDocumentSnapshot>> mensajesPorDia = {};

                for (var msg in mensajes) {
                  final timestamp = msg['timestamp'] as Timestamp?;
                  final fecha = timestamp?.toDate();
                  final dia = fecha != null
                      ? '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}'
                      : 'Sin fecha';

                  mensajesPorDia.putIfAbsent(dia, () => []).add(msg);
                }

                return ListView(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  children: mensajesPorDia.entries.map((entry) {
                    final dia = entry.key;
                    final mensajesDelDia = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            dia,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        ...mensajesDelDia.map((msg) {
                          final texto = msg['texto'];
                          final usuario = msg['usuario'];
                          final timestamp = msg['timestamp'] as Timestamp?;
                          final hora = timestamp != null
                              ? TimeOfDay.fromDateTime(timestamp.toDate())
                                  .format(context)
                              : '';

                          final esPropio = user.email == usuario;
                          final nombreUsuario = usuario;

                          return construirBurbujaMensajeConHora(
                              texto, nombreUsuario, hora, esPropio);
                        }).toList(),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Mencionar integrante',
                  icon: const Icon(Icons.alternate_email, color: Colors.orange),
                  onPressed: () => _abrirSelectorMencion(idProyecto),
                ),
                Expanded(
                  child: TextField(
                    controller: _mensajeController,
                    decoration: const InputDecoration(
                      hintText: 'Escribe tu mensaje...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.orange),
                  onPressed: () => enviarMensaje(idProyecto),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
