import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

// _toStringList removido: ya no se usa tras migrar integrantes a lista de mapas

Map<String, bool> _toTasks(dynamic raw) {
  if (raw is Map) {
    final out = <String, bool>{};
    raw.forEach((k, val) {
      final key = k?.toString() ?? '';
      if (key.isEmpty) return;
      if (val is Map) {
        // Nuevo formato: {done: bool, nombre: String?, cedula: String?}
        out[key] = _toBool(val['done']);
      } else {
        out[key] = _toBool(val);
      }
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

/// Envuelve tareas simples (Map<String,bool>) al nuevo formato para Firestore
/// { "tarea": { done: true/false, nombre: null, cedula: null } }
Map<String, Map<String, dynamic>> _wrapTasks(
  Map<String, bool> tareas, {
  Map<String, String?>? nombres,
  Map<String, String?>? cedulas,
}) {
  final out = <String, Map<String, dynamic>>{};
  tareas.forEach((k, v) {
    out[k] = {
      'done': _toBool(v),
      'nombre': nombres != null ? nombres[k] : null,
      'cedula': cedulas != null ? cedulas[k] : null,
      'fecha_termino': null,
    };
  });
  return out;
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

/// Agrega un proyecto donde "integrante" ahora es una lista de mapas
/// con las llaves: nombre, email, cedula. Ej:
/// [ {"nombre":"Ana","email":"ana@x.com","cedula":"123"}, ... ]
Future<void> addProyecto(
    int idProyecto,
    String nombreProyecto,
    String descripcion,
    List<Map<String, String>> integrantesDetalle,
    String nombreEqipo,
    Map<String, bool> tareas,
    bool estado,
    DateTime fechaCreacion,
    DateTime fechaEntrega,
    [List<String> links = const []]) async {
  await db.collection('list_proyecto').add({
    'id_proyecto': idProyecto,
    'nombre_proyecto': nombreProyecto,
    'descripcion': descripcion,
    'integrante': integrantesDetalle, // se guarda la lista de mapas
    'nombre_equipo': nombreEqipo,
    // Guardar tareas en formato enriquecido (nombre/cedula por defecto null)
    'tareas': _wrapTasks(tareas),
    'estado': estado,
    'fecha_creacion': fechaCreacion,
    'fecha_entrega': fechaEntrega,
    'like': 0, // nuevo campo inicializado en 0
    'links': links,
  });
}

/// Obtiene el siguiente id_proyecto secuencial basado en el mayor actual.
/// Si no hay proyectos, retorna 1.
Future<int> getNextProyectoId() async {
  try {
    final snap = await db
        .collection('list_proyecto')
        .orderBy('id_proyecto', descending: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return 1;
    final data = snap.docs.first.data() as Map<String, dynamic>? ?? {};
    final raw = data['id_proyecto'];
    int maxVal = 0;
    if (raw is int) {
      maxVal = raw;
    } else if (raw is String) {
      maxVal = int.tryParse(raw) ?? 0;
    } else if (raw is num) {
      maxVal = raw.toInt();
    }
    return (maxVal + 1);
  } catch (_) {
    // En caso de error, fallback a 1 para no bloquear la creación
    return 1;
  }
}

/// Actualiza un proyecto usando la nueva estructura de integrantes detalle
Future<void> updateProyecto(
    int idProyecto,
    String nombreProyecto,
    String descripcion,
    List<Map<String, String>> integrantesDetalle,
    String nombreEqipo,
    Map<String, bool> tareas,
    bool estado,
    DateTime fechaCreacion,
    DateTime fechaEntrega,
    String docId,
    [List<String> links = const []]) async {
  await db.collection('list_proyecto').doc(docId).update({
    'id_proyecto': idProyecto,
    'nombre_proyecto': nombreProyecto,
    'descripcion': descripcion,
    'integrante': integrantesDetalle,
    'nombre_equipo': nombreEqipo,
    'estado': estado,
    // Guardar tareas en formato enriquecido (nombre/cedula por defecto null)
    'tareas': _wrapTasks(tareas),
    'fecha_creacion': fechaCreacion,
    'fecha_entrega': fechaEntrega,
    'links': links,
  });
}

Future<void> deleteProyecto(String docId) async {
  await db.collection('list_proyecto').doc(docId).delete();
}

/// Devuelve los proyectos donde el email (en minúsculas) aparece en `integrantes_detalle`
Future<List<Map<String, dynamic>>> getProyectosByMemberEmail(
    BuildContext context, String emailLower) async {
  final all = await getProyecto(context);
  final filtered = <Map<String, dynamic>>[];
  for (final p in all) {
    final List integrantesDetalle = (p['integrantes_detalle'] ?? []) as List;
    for (final i in integrantesDetalle) {
      if (i is Map) {
        final mail = (i['email'] ?? '').toString().trim().toLowerCase();
        if (mail.isNotEmpty && mail == emailLower) {
          filtered.add(p);
          break;
        }
      }
    }
  }
  return filtered;
}

/// Devuelve los proyectos donde participa el usuario autenticado (por email)
Future<List<Map<String, dynamic>>> getProyectosDelUsuarioActual(
    BuildContext context) async {
  final current = FirebaseAuth.instance.currentUser;
  if (current == null) return [];
  final emailLower = current.email?.trim().toLowerCase();
  if (emailLower == null || emailLower.isEmpty) return [];
  return getProyectosByMemberEmail(context, emailLower);
}

/// Construye un mapa de eventos de entrega para el usuario (clave = fecha normalizada)
/// Cada evento es un Map con: title, date, docId, id_proyecto, nombre_proyecto
Future<Map<DateTime, List<Map<String, dynamic>>>> getEventosEntregaUsuario(
    BuildContext context,
    {String? emailLower}) async {
  String? email = emailLower;
  if (email == null || email.isEmpty) {
    final current = FirebaseAuth.instance.currentUser;
    email = current?.email?.trim().toLowerCase();
  }
  if (email == null || email.isEmpty) return {};

  final proyectos = await getProyectosByMemberEmail(context, email);
  final out = <DateTime, List<Map<String, dynamic>>>{};
  for (final p in proyectos) {
    final DateTime? fechaEntrega = p['fecha_entrega'] as DateTime?;
    if (fechaEntrega == null) continue;
    final normalized =
        DateTime.utc(fechaEntrega.year, fechaEntrega.month, fechaEntrega.day);
    final bool estado = p['estado'] == true; // true = completado?
    final bool vencido = !estado && fechaEntrega.isBefore(DateTime.now());
    final event = <String, dynamic>{
      'title': 'Entrega: ' + (p['nombre_proyecto']?.toString() ?? ''),
      'date': fechaEntrega,
      'docId': p['docId']?.toString(),
      'id_proyecto': p['id_proyecto'],
      'nombre_proyecto': p['nombre_proyecto'],
      'vencido': vencido,
      'estado': estado,
    };
    out.putIfAbsent(normalized, () => <Map<String, dynamic>>[]);
    out[normalized]!.add(event);
  }
  return out;
}

/// Genera notificaciones basadas en proximidad a fecha_entrega.
/// Regresa lista de mapas con: mensaje, proyecto, docId, tipo, dateEntrega, horasRestantes, minutosRestantes.
Future<List<Map<String, dynamic>>> generarNotificacionesEntrega(
    BuildContext context,
    {String? emailLower}) async {
  final now = DateTime.now();
  String? email = emailLower;
  if (email == null || email.isEmpty) {
    final current = FirebaseAuth.instance.currentUser;
    email = current?.email?.trim().toLowerCase();
  }
  if (email == null || email.isEmpty) return [];

  final proyectos = await getProyectosByMemberEmail(context, email);
  final notifs = <Map<String, dynamic>>[];
  for (final p in proyectos) {
    final DateTime? entrega = p['fecha_entrega'] as DateTime?;
    final bool estado = p['estado'] == true; // completado => no avisar
    if (entrega == null || estado) continue; // no avisar si ya completado

    final diff = entrega.difference(now); // positiva si futuro
    final horas = diff.inHours;
    final minutos = diff.inMinutes;

    // Notificación a 1 día (entre 24h y <25h para evitar repetir; simple ventana)
    if (horas == 24) {
      notifs.add({
        'tipo': '24h',
        'mensaje': 'Falta 1 día para entregar: ${p['nombre_proyecto']}',
        'proyecto': p['nombre_proyecto'],
        'docId': p['docId'],
        'dateEntrega': entrega,
        'horasRestantes': horas,
        'minutosRestantes': minutos,
      });
    }

    // Notificación a 1 hora (exacta)
    if (horas == 1 && minutos >= 60 && minutos < 120) {
      notifs.add({
        'tipo': '1h',
        'mensaje': 'Falta 1 hora para entregar: ${p['nombre_proyecto']}',
        'proyecto': p['nombre_proyecto'],
        'docId': p['docId'],
        'dateEntrega': entrega,
        'horasRestantes': horas,
        'minutosRestantes': minutos,
      });
    }

    // Notificación vencido (entrega pasada y estado false)
    if (entrega.isBefore(now)) {
      notifs.add({
        'tipo': 'vencido',
        'mensaje': 'Proyecto vencido: ${p['nombre_proyecto']}',
        'proyecto': p['nombre_proyecto'],
        'docId': p['docId'],
        'dateEntrega': entrega,
        'horasRestantes': horas,
        'minutosRestantes': minutos,
      });
    }
  }
  return notifs;
}

// Funciones de FCM removidas a pedido del usuario

/// Convierte la lista dinámica de integrantes en una lista de mapas estandarizada
List<Map<String, String>> _toIntegrantesDetalle(dynamic raw) {
  final out = <Map<String, String>>[];
  if (raw is List) {
    for (final e in raw) {
      if (e is Map) {
        final nombre = (e['nombre'] ?? e['name'] ?? '').toString();
        final email = (e['email'] ?? '').toString();
        final cedula = (e['cedula'] ?? '').toString();
        if (nombre.isEmpty && email.isEmpty && cedula.isEmpty) continue;
        out.add({
          'nombre': nombre,
          'email': email,
          'cedula': cedula,
        });
      } else if (e is String) {
        // Compatibilidad con antiguo formato (solo nombre)
        final nombre = e.trim();
        if (nombre.isNotEmpty) {
          out.add({'nombre': nombre, 'email': '', 'cedula': ''});
        }
      }
    }
  }
  return out;
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
      final integrantesDetalle = _toIntegrantesDetalle(data['integrante']);
      final integrante = integrantesDetalle
          .map((m) => (m['nombre'] ?? '').trim())
          .where((s) => s.isNotEmpty)
          .toList();
      final nombreEquipo = (data['nombre_equipo'] ?? '').toString();
      final tareas = _toTasks(data['tareas']);
      final estado = _toBool(data['estado']);
      final fechaCreacion = _toDate(data['fecha_creacion']);
      final fechaEntrega = _toDate(data['fecha_entrega']);
      final docId = doc.id;
      final likeRaw = data['like'];
      int like = 0;
      if (likeRaw is int) {
        like = likeRaw;
      } else if (likeRaw is num) {
        like = likeRaw.toInt();
      } else if (likeRaw is String) {
        like = int.tryParse(likeRaw) ?? 0;
      }

      final proyecto = {
        'id_proyecto': idProyecto,
        'nombre_proyecto': nombreProyecto,
        'descripcion': descripcion,
        'integrante': integrante,
        'integrantes_detalle':
            integrantesDetalle, // nuevo campo con detalle completo
        'nombre_equipo': nombreEquipo,
        'tareas': tareas,
        'estado': estado,
        'fecha_creacion': fechaCreacion,
        'fecha_entrega': fechaEntrega,
        'docId': docId,
        'like': like,
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

/// Stream en tiempo real de los proyectos, con la misma normalización de getProyecto
Stream<List<Map<String, dynamic>>> streamProyecto() {
  return db.collection('list_proyecto').snapshots().map((querySnapshot) {
    final proyectos = <Map<String, dynamic>>[];
    for (final doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final idProyecto = data['id_proyecto'] != null
          ? int.tryParse(data['id_proyecto'].toString()) ?? 0
          : 0;
      final nombreProyecto = (data['nombre_proyecto'] ?? '').toString();
      final descripcion = (data['descripcion'] ?? '').toString();
      final integrantesDetalle = _toIntegrantesDetalle(data['integrante']);
      final integrante = integrantesDetalle
          .map((m) => (m['nombre'] ?? '').trim())
          .where((s) => s.isNotEmpty)
          .toList();
      final nombreEquipo = (data['nombre_equipo'] ?? '').toString();
      final tareas = _toTasks(data['tareas']);
      final estado = _toBool(data['estado']);
      final fechaCreacion = _toDate(data['fecha_creacion']);
      final fechaEntrega = _toDate(data['fecha_entrega']);
      final docId = doc.id;
      final likeRaw = data['like'];
      int like = 0;
      if (likeRaw is int) {
        like = likeRaw;
      } else if (likeRaw is num) {
        like = likeRaw.toInt();
      } else if (likeRaw is String) {
        like = int.tryParse(likeRaw) ?? 0;
      }

      final proyecto = {
        'id_proyecto': idProyecto,
        'nombre_proyecto': nombreProyecto,
        'descripcion': descripcion,
        'integrante': integrante,
        'integrantes_detalle': integrantesDetalle,
        'nombre_equipo': nombreEquipo,
        'tareas': tareas,
        'estado': estado,
        'fecha_creacion': fechaCreacion,
        'fecha_entrega': fechaEntrega,
        'docId': docId,
        'like': like,
      };
      proyectos.add(proyecto);
    }
    return proyectos;
  });
}

/// Stream del documento de un proyecto específico por `docId` (datos crudos)
Stream<Map<String, dynamic>?> streamProyectoDoc(String docId) {
  return db
      .collection('list_proyecto')
      .doc(docId)
      .snapshots()
      .map((doc) => doc.data());
}

/// Incrementa en 1 el campo "like" de un proyecto por docId
Future<void> incrementarLikeProyecto(String docId) async {
  await db
      .collection('list_proyecto')
      .doc(docId)
      .update({'like': FieldValue.increment(1)});
}

/// Agrega un enlace (URL) al arreglo 'links' de un proyecto.
/// Usa arrayUnion para evitar duplicados exactos.
Future<void> addLinkProyecto(String docId, String url) async {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return;
  await db.collection('list_proyecto').doc(docId).update({
    'links': FieldValue.arrayUnion([trimmed])
  });
}

/// Verifica si el usuario autenticado es administrador (isadmin == true)
/// Busca al usuario en la colección `user` utilizando la lista de `getUser`
/// y compara por email. Si no hay usuario autenticado o no se encuentra,
/// devuelve false.
Future<bool> isCurrentUserAdmin(BuildContext context) async {
  try {
    final current = FirebaseAuth.instance.currentUser;
    if (current == null) return false;
    final email = current.email?.trim().toLowerCase();
    if (email == null || email.isEmpty) return false;

    final users = await getUser(context);
    for (final u in users) {
      final uEmail = (u['email'] ?? '').toString().trim().toLowerCase();
      if (uEmail == email) {
        final v = u['isadmin'];
        return v == true ||
            v == 1 ||
            (v is String && (v.toLowerCase() == 'true' || v == '1'));
      }
    }
    return false;
  } catch (e) {
    // Opcional: avisar en UI; retornar false por seguridad
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error verificando permisos: $e')),
    );
    return false;
  }
}

/// Actualiza el estado de una tarea de un proyecto y guarda/limpia datos del responsable
/// - tareaKey: llave exacta de la tarea en el mapa `tareas`
/// - done: nuevo estado
/// - nombre/cedula: datos de la persona que marca la tarea (se guardan solo si done=true)
Future<void> setTareaEstado(
  String docId,
  String tareaKey,
  bool done, {
  String? nombre,
  String? cedula,
}) async {
  final Map<String, Object?> updates = {
    'tareas.$tareaKey.done': done,
    'tareas.$tareaKey.nombre': done ? (nombre ?? '') : null,
    'tareas.$tareaKey.cedula': done ? (cedula ?? '') : null,
    'tareas.$tareaKey.fecha_termino':
        done ? FieldValue.serverTimestamp() : null,
  };
  await db.collection('list_proyecto').doc(docId).update(updates);
  await checkAndUpdateProyectoEstado(docId);
}

/// Mantiene el campo 'estado' del proyecto en sincronía con sus tareas.
/// - Si TODAS las tareas están done=true (y hay al menos una), pone estado=true.
/// - Si ALGUNA tarea está en false, pone estado=false.
Future<void> checkAndUpdateProyectoEstado(String docId) async {
  final snap = await db.collection('list_proyecto').doc(docId).get();
  if (!snap.exists) return;
  final data = snap.data() ?? <String, dynamic>{};
  final tareas = data['tareas'];
  if (tareas is! Map || tareas.isEmpty)
    return; // si no hay tareas, no tocar estado

  bool allDone = true;
  tareas.forEach((key, value) {
    bool done = false;
    if (value is Map) {
      done = _toBool(value['done']);
    } else if (value is bool) {
      done = value;
    }
    if (!done) allDone = false;
  });
  final bool nuevoEstado = allDone;
  if (data['estado'] != nuevoEstado) {
    await snap.reference.update({'estado': nuevoEstado});
  }
}

/// Marca todas las tareas de un proyecto como hechas (true) o no hechas (false).
/// Si done=true: establece done=true y fecha_termino=serverTimestamp (para cada tarea).
/// Si done=false: establece done=false y limpia nombre, cedula y fecha_termino.
/// Luego sincroniza el campo 'estado' del proyecto.
Future<void> setTodasLasTareas(String docId, bool done) async {
  final snap = await db.collection('list_proyecto').doc(docId).get();
  if (!snap.exists) return;
  final data = snap.data() ?? <String, dynamic>{};
  final tareas = data['tareas'];
  if (tareas is! Map || tareas.isEmpty) return;

  final Map<String, Object?> updates = {};
  tareas.forEach((key, value) {
    final k = key?.toString();
    if (k == null || k.isEmpty) return;
    updates['tareas.$k.done'] = done;
    if (done) {
      // Mantener nombre/cedula existentes si ya estaban; no sobrescribir con null.
      // Sólo actualizamos fecha_termino para reflejar la marca masiva.
      updates['tareas.$k.fecha_termino'] = FieldValue.serverTimestamp();
    } else {
      updates['tareas.$k.nombre'] = null;
      updates['tareas.$k.cedula'] = null;
      updates['tareas.$k.fecha_termino'] = null;
    }
  });
  await db.collection('list_proyecto').doc(docId).update(updates);
  await checkAndUpdateProyectoEstado(docId);
}
