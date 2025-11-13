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

  void enviarMensaje(int? idProyecto) async {
    if (_mensajeController.text.trim().isEmpty) return;

    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('foro_mensajes').add({
        'texto': _mensajeController.text.trim(),
        'usuario': user.email,
        'timestamp': FieldValue.serverTimestamp(),
        'id_proyecto': idProyecto, // guardar id del proyecto para filtrar
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
