import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

// Helpers de normalización para lecturas robustas desde Firestore
bool _toBool(dynamic v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) {
    final s = v.trim().toLowerCase();
    return s == 'true' || s == '1' || s == 'yes' || s == 'si';
  }
  return false;
}

DateTime? _toDate(dynamic v) {
  if (v == null) return null;
  if (v is Timestamp) return v.toDate();
  if (v is DateTime) return v;
  if (v is String) {
    try {
      return DateTime.tryParse(v);
    } catch (_) {
      return null;
    }
  }
  return null;
}

List<String> _toStringList(dynamic v) {
  if (v is List) {
    return v
        .map((e) => e?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .cast<String>()
        .toList();
  }
  return <String>[];
}

Map<String, bool> _toTasks(dynamic raw) {
  if (raw is Map) {
    final out = <String, bool>{};
    raw.forEach((k, val) {
      final key = k?.toString() ?? '';
      if (key.isEmpty) return;
      out[key] = _toBool(val);
    });
    return out;
  }
  if (raw is List) {
    final m = <String, bool>{};
    for (final e in raw) {
      final key = e?.toString() ?? '';
      if (key.isNotEmpty) m[key] = false;
    }
    return m;
  }
  return <String, bool>{};
}

Future<List<Map<String, dynamic>>> getUser(BuildContext context) async {
  final List<Map<String, dynamic>> users = [];
  try {
    final QuerySnapshot querySnapshot = await db.collection('user').get();
    for (final doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final email = (data['email'] ?? '').toString().trim();
      final password = (data['password'] ?? '').toString();
      final name = (data['name'] ?? '').toString();
      final isadmin = data['isadmin'] ?? false;
      final idCarnet = data['id_carnet'] != null
          ? int.tryParse(data['id_carnet'].toString()) ?? 0
          : 0;
      final cedula = data['cedula'] ?? '';
      final dateLogin =
          data['date_login'] != null && data['date_login'] is Timestamp
              ? (data['date_login'] as Timestamp).toDate()
              : null;
      final uid = doc.id;

      final person = {
        'name': name,
        'uid': uid,
        'email': email,
        'password': password,
        'isadmin': isadmin,
        'id_carnet': idCarnet,
        'cedula': cedula,
        'date_login': dateLogin,
      };
      users.add(person);
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error de conexion: $e')),
    );
    return [];
  }
  return users;
}

Future<void> addUser(
  String name,
  String email,
  bool isadmin,
  int idCarnet,
  String cedula,
  DateTime dateCreated,
  DateTime dateLogin,
) async {
  await db.collection('user').add({
    'name': name,
    'email': email,
    'isadmin': isadmin,
    'id_carnet': idCarnet,
    'cedula': cedula,
    'date_created': dateCreated,
    'date_login': dateLogin,
  });
}

Future<void> updateUser(
  String name,
  int idCarnet,
  String cedula,
  String uid,
) async {
  await db.collection('user').doc(uid).update({
    'name': name,
    'id_carnet': idCarnet,
    'cedula': cedula,
  });
}

Future<void> updateUserLoginDate(
  DateTime dateLogin,
  String uid,
) async {
  await db.collection('user').doc(uid).update({
    'date_login': dateLogin,
  });
}

Future<void> deleteUser(String uid) async {
  await db.collection('user').doc(uid).delete();
}

Future<void> addProyecto(
  int idProyecto,
  String nombreProyecto,
  String descripcion,
  List<String> integrante,
  String nombreEqipo,
  Map<String, bool> tareas,
  bool estado,
  DateTime fechaCreacion,
  DateTime fechaEntrega,
) async {
  await db.collection('list_proyecto').add({
    'id_proyecto': idProyecto,
    'nombre_proyecto': nombreProyecto,
    'descripcion': descripcion,
    'integrante': integrante,
    'nombre_equipo': nombreEqipo,
    'tareas': tareas,
    'estado': estado,
    'fecha_creacion': fechaCreacion,
    'fecha_entrega': fechaEntrega,
  });
}

Future<void> updateProyecto(
  int idProyecto,
  String nombreProyecto,
  String descripcion,
  List<String> integrante,
  String nombreEqipo,
  Map<String, bool> tareas,
  bool estado,
  DateTime fechaCreacion,
  DateTime fechaEntrega,
  String docId,
) async {
  await db.collection('list_proyecto').doc(docId).update({
    'id_proyecto': idProyecto,
    'nombre_proyecto': nombreProyecto,
    'descripcion': descripcion,
    'integrante': integrante,
    'nombre_equipo': nombreEqipo,
    'estado': estado,
    'tareas': tareas,
    'fecha_creacion': fechaCreacion,
    'fecha_entrega': fechaEntrega,
  });
}

Future<void> deleteProyecto(String docId) async {
  await db.collection('list_proyecto').doc(docId).delete();
}

Future<List<Map<String, dynamic>>> getProyecto(BuildContext context) async {
  final List<Map<String, dynamic>> proyectos = [];
  try {
    final QuerySnapshot querySnapshot =
        await db.collection('list_proyecto').get();
    for (final doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final idProyecto = data['id_proyecto'] != null
          ? int.tryParse(data['id_proyecto'].toString()) ?? 0
          : 0;
      final nombreProyecto = (data['nombre_proyecto'] ?? '').toString();
      final descripcion = (data['descripcion'] ?? '').toString();
      final integrante = _toStringList(data['integrante']);
      final nombreEquipo = (data['nombre_equipo'] ?? '').toString();
      final tareas = _toTasks(data['tareas']);
      final estado = _toBool(data['estado']);
      final fechaCreacion = _toDate(data['fecha_creacion']);
      final fechaEntrega = _toDate(data['fecha_entrega']);
      final docId = doc.id;

      final proyecto = {
        'id_proyecto': idProyecto,
        'nombre_proyecto': nombreProyecto,
        'descripcion': descripcion,
        'integrante': integrante,
        'nombre_equipo': nombreEquipo,
        'tareas': tareas,
        'estado': estado,
        'fecha_creacion': fechaCreacion,
        'fecha_entrega': fechaEntrega,
        'docId': docId,
      };
      proyectos.add(proyecto);
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error de conexion: $e')),
    );
    return [];
  }
  return proyectos;
}
