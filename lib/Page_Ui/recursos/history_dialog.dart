import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_final/Color/Color.dart';
import 'package:proyecto_final/services/firebase_services.dart' as api;

Future<void> showHistoryDialog(
    BuildContext context, Map<String, dynamic> resource) async {
  final docId = (resource['docId'] ?? '').toString();
  if (docId.isEmpty) return;

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Historial: ${resource['nombre']}'),
        content: SizedBox(
          width: 500,
          height: 400,
          child: StreamBuilder<QuerySnapshot>(
            stream: api.db
                .collection('recursos_materiales')
                .doc(docId)
                .collection('asignaciones')
                .orderBy('fecha', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return const Center(child: Text('Sin historial de uso.'));
              }
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final cantidad = data['cantidad'] ?? 0;
                  final tarea = data['tarea_key'] ?? 'Unknown';
                  final asignadoPor = data['asignado_por'] ?? 'Unknown';
                  final fechaTs = data['fecha'] as Timestamp?;
                  final fecha =
                      fechaTs?.toDate().toString().split('.')[0] ?? '';
                  final proyectoId = data['proyecto_docId'] as String?;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: primaryOrange,
                        child: Text('$cantidad',
                            style: const TextStyle(color: Colors.white)),
                      ),
                      title: FutureBuilder<DocumentSnapshot>(
                        future: proyectoId != null
                            ? api.db
                                .collection('list_proyecto')
                                .doc(proyectoId)
                                .get()
                            : null,
                        builder: (context, snap) {
                          if (!snap.hasData) {
                            return const Text('Cargando proyecto...');
                          }
                          final pData =
                              snap.data!.data() as Map<String, dynamic>?;
                          return Text(pData?['nombre_proyecto'] ??
                              'Proyecto eliminado');
                        },
                      ),
                      subtitle: Text(
                          'Tarea: $tarea\nPor: $asignadoPor\nFecha: $fecha'),
                      isThreeLine: true,
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      );
    },
  );
}
