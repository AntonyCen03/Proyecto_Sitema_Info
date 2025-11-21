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
      final photoUrl = (data['photo_url'] ?? '').toString();

      final person = {
        'name': name,
        'uid': uid,
        'email': email,
        'password': password,
        'isadmin': isadmin,
        'id_carnet': idCarnet,
        'cedula': cedula,
        'date_login': dateLogin,
        'photo_url': photoUrl,
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

/// Establece/actualiza la URL de la foto de perfil del usuario.
Future<void> setUserPhotoUrl(String uid, String photoUrl) async {
  await db.collection('user').doc(uid).update({'photo_url': photoUrl});
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
  final docRef = db.collection('list_proyecto').doc(docId);
  final snap = await docRef.get();
  if (!snap.exists) return;

  final data = snap.data() ?? {};

  // Verificar si el proyecto está completado
  if (_toBool(data['estado'])) {
    throw Exception('No se puede eliminar un proyecto completado.');
  }

  // Verificar si tiene tareas terminadas (avances)
  final tareas = data['tareas'];
  if (tareas is Map) {
    for (final val in tareas.values) {
      bool done = false;
      if (val is Map) {
        done = _toBool(val['done']);
      } else {
        done = _toBool(val);
      }
      if (done) {
        throw Exception(
            'No se puede eliminar un proyecto con tareas terminadas.');
      }
    }
  }

  await docRef.delete();
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
    final flag24h = (p['notif_24h'] ?? true) != false;
    if (flag24h && horas == 24) {
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
    final flag1h = (p['notif_1h'] ?? true) != false;
    if (flag1h && horas == 1 && minutos >= 60 && minutos < 120) {
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
    final flagVencido = (p['notif_vencido'] ?? true) != false;
    if (flagVencido && entrega.isBefore(now)) {
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

/// Retorna una lista de mensajes del foro donde el texto contiene
/// el email del usuario autenticado. Si [idProyecto] se pasa, filtra
/// por ese proyecto. Limita lectura a [limit] documentos más recientes.
Future<List<Map<String, dynamic>>> getForoMentions(
  BuildContext context, {
  int? idProyecto,
  int limit = 50,
}) async {
  try {
    final current = FirebaseAuth.instance.currentUser;
    final email = current?.email?.trim().toLowerCase();
    if (email == null || email.isEmpty) return [];

    Query query = db.collection('foro_mensajes');
    if (idProyecto != null) {
      query = query.where('id_proyecto', isEqualTo: idProyecto);
    }
    // Intentar ordenar por timestamp si existe
    try {
      query = query.orderBy('timestamp', descending: true);
    } catch (_) {
      // si no hay índice, continuamos sin orderBy
    }
    query = query.limit(limit);

    final snap = await query.get();
    final out = <Map<String, dynamic>>[];
    for (final doc in snap.docs) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final texto = (data['texto'] ?? '').toString();
      final usuario = (data['usuario'] ?? '').toString();
      final ts = data['timestamp'];
      DateTime? fecha;
      if (ts is Timestamp) fecha = ts.toDate();
      // Solo notificar si 'notificar' no es false (true o no existe)
      final shouldNotify = data['notificar'] != false;
      if (shouldNotify && texto.toLowerCase().contains(email)) {
        out.add({
          'tipo': 'foro',
          'mensaje': 'Te mencionaron en el foro',
          'texto': texto,
          'usuario': usuario,
          'docId': doc.id,
          'id_proyecto': data['id_proyecto'],
          'dateEntrega': fecha, // reutilizamos campo para mostrar fecha
        });
      }
    }
    return out;
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error leyendo menciones del foro: $e')),
    );
    return [];
  }
}

/// Marca un mensaje de foro para dejar de notificar (o reactivar) por docId
Future<void> setForoNotificar(String docId, bool value) async {
  await db.collection('foro_mensajes').doc(docId).update({'notificar': value});
}

/// Devuelve true/false si existen mensajes en el foro que contengan
/// el email del usuario autenticado (opcionalmente filtrado por proyecto).
Future<bool> foroHasUserMention(
  BuildContext context, {
  int? idProyecto,
  int limit = 200,
}) async {
  final mentions = await getForoMentions(
    context,
    idProyecto: idProyecto,
    limit: limit,
  );
  return mentions.isNotEmpty;
}

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

      // Presupuesto y finanzas
      final presupuestoRaw = data['presupuesto_solicitado'];
      double? presupuestoSolicitado;
      if (presupuestoRaw is num) {
        presupuestoSolicitado = presupuestoRaw.toDouble();
      } else if (presupuestoRaw is String) {
        presupuestoSolicitado = double.tryParse(presupuestoRaw);
      }
      final bool presupuestoAprobado =
          (data['presupuesto_aprobado'] ?? false) == true;
      final String presupuestoMotivo =
          (data['presupuesto_motivo'] ?? '').toString();

      // liked_by normalizado (una sola vez)
      final likedRaw = data['liked_by'];
      final likedBy = <String>[];
      if (likedRaw is List) {
        for (final e in likedRaw) {
          if (e == null) continue;
          final s = e.toString().trim().toLowerCase();
          if (s.isNotEmpty) likedBy.add(s);
        }
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
        'notif_24h': (data['notif_24h'] ?? true) != false,
        'notif_1h': (data['notif_1h'] ?? true) != false,
        'notif_vencido': (data['notif_vencido'] ?? true) != false,
        'presupuesto_solicitado': presupuestoSolicitado,
        'presupuesto_aprobado': presupuestoAprobado,
        'presupuesto_motivo': presupuestoMotivo,
        'liked_by': likedBy,
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

      // Presupuesto y finanzas (stream)
      final presupuestoRaw = data['presupuesto_solicitado'];
      double? presupuestoSolicitado;
      if (presupuestoRaw is num) {
        presupuestoSolicitado = presupuestoRaw.toDouble();
      } else if (presupuestoRaw is String) {
        presupuestoSolicitado = double.tryParse(presupuestoRaw);
      }
      final bool presupuestoAprobado =
          (data['presupuesto_aprobado'] ?? false) == true;
      final String presupuestoMotivo =
          (data['presupuesto_motivo'] ?? '').toString();

      // liked_by para streamProyecto
      final likedRaw = data['liked_by'];
      final likedBy = <String>[];
      if (likedRaw is List) {
        for (final e in likedRaw) {
          if (e == null) continue;
          final s = e.toString().trim().toLowerCase();
          if (s.isNotEmpty) likedBy.add(s);
        }
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
        'presupuesto_solicitado': presupuestoSolicitado,
        'presupuesto_aprobado': presupuestoAprobado,
        'presupuesto_motivo': presupuestoMotivo,
        'liked_by': likedBy,
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

/// Da like solo una vez por usuario (identificado por su email). Si ya existe en liked_by no hace nada.
Future<bool> likeProyectoUnaVez(String docId) async {
  final user = FirebaseAuth.instance.currentUser;
  final email = user?.email?.trim().toLowerCase();
  if (email == null || email.isEmpty) return false;
  return await db.runTransaction((tx) async {
    final ref = db.collection('list_proyecto').doc(docId);
    final snap = await tx.get(ref);
    if (!snap.exists) return false;
    final data = snap.data() ?? {};
    final raw = data['liked_by'];
    final current = <String>[];
    if (raw is List) {
      for (final e in raw) {
        if (e == null) continue;
        final s = e.toString().trim().toLowerCase();
        if (s.isNotEmpty) current.add(s);
      }
    }
    if (current.contains(email)) {
      return false; // ya dio like
    }
    current.add(email);
    final likeRaw = data['like'];
    int like = 0;
    if (likeRaw is int) {
      like = likeRaw;
    } else if (likeRaw is num) {
      like = likeRaw.toInt();
    } else if (likeRaw is String) {
      like = int.tryParse(likeRaw) ?? 0;
    }
    like += 1;
    tx.update(ref, {
      'like': like,
      'liked_by': current,
    });
    return true;
  });
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

/// Marca en el proyecto la notificación correspondiente como leída (false)
/// tipos soportados: '24h', '1h', 'vencido'
Future<void> setProyectoNotificacion(
    String docId, String tipo, bool value) async {
  String? field;
  switch (tipo) {
    case '24h':
      field = 'notif_24h';
      break;
    case '1h':
      field = 'notif_1h';
      break;
    case 'vencido':
      field = 'notif_vencido';
      break;
  }
  if (field == null) return;
  await db.collection('list_proyecto').doc(docId).update({field: value});
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

/// Registra una solicitud de presupuesto para un proyecto.
/// - Guarda `presupuesto_solicitado` (double), `presupuesto_motivo` (string opcional),
///   `presupuesto_fecha_solicitud` (serverTimestamp) y no toca `presupuesto_aprobado` si ya existe.
Future<void> solicitarPresupuestoProyecto(
  String docId,
  num monto, {
  String? motivo,
}) async {
  final updates = <String, Object?>{
    'presupuesto_solicitado': monto.toDouble(),
    'presupuesto_motivo': (motivo ?? '').trim(),
    'presupuesto_fecha_solicitud': FieldValue.serverTimestamp(),
  };
  await db.collection('list_proyecto').doc(docId).update(updates);
}

/// Registra un gasto en el subcolector `gastos` de un proyecto.
/// Cada gasto contiene: monto (double), descripcion (string), fecha (timestamp), created_by (string opcional)
Future<void> registrarGastoProyecto(
  String docId,
  double monto,
  String descripcion, {
  DateTime? fecha,
  String? usuarioEmail,
}) async {
  // No permitir registrar gasto si el presupuesto no está aprobado
  final proyectoSnap = await db.collection('list_proyecto').doc(docId).get();
  final aprobado =
      (proyectoSnap.data()?['presupuesto_aprobado'] ?? false) == true;
  if (!aprobado) {
    throw Exception('El presupuesto aún no está aprobado.');
  }
  final data = <String, Object?>{
    'monto': monto,
    'descripcion': descripcion.trim(),
    'fecha': fecha != null
        ? Timestamp.fromDate(fecha)
        : FieldValue.serverTimestamp(),
    'created_by': (usuarioEmail ?? '').trim(),
  };
  await db
      .collection('list_proyecto')
      .doc(docId)
      .collection('gastos')
      .add(data);
}

/// Calcula el total de gastos del proyecto sumando el subcolector `gastos`.
Future<double> calcularTotalGastosProyecto(String docId) async {
  final snap = await db
      .collection('list_proyecto')
      .doc(docId)
      .collection('gastos')
      .get();
  double total = 0.0;
  for (final d in snap.docs) {
    final data = d.data();
    final v = data['monto'];
    if (v is num) {
      total += v.toDouble();
    } else if (v is String) {
      total += double.tryParse(v) ?? 0.0;
    }
  }
  return total;
}

/// Retorna un resumen financiero del proyecto:
/// { presupuesto: double?, totalGastos: double, saldo: double?, sobrepasado: bool }
Future<Map<String, dynamic>> getResumenFinancieroProyecto(String docId) async {
  final doc = await db.collection('list_proyecto').doc(docId).get();
  double? presupuesto;
  bool aprobado = false;
  if (doc.exists) {
    final data = doc.data() ?? <String, dynamic>{};
    final raw = data['presupuesto_solicitado'];
    if (raw is num) presupuesto = raw.toDouble();
    if (raw is String) presupuesto = double.tryParse(raw);
    aprobado = (data['presupuesto_aprobado'] ?? false) == true;
  }
  final totalGastos = await calcularTotalGastosProyecto(docId);
  double? saldo;
  bool sobrepasado = false;
  if (presupuesto != null) {
    saldo = presupuesto - totalGastos;
    sobrepasado = saldo < 0;
  }
  return {
    'presupuesto': presupuesto,
    'presupuestoAprobado': aprobado,
    'totalGastos': totalGastos,
    'saldo': saldo,
    'sobrepasado': sobrepasado,
  };
}

/// Establece el estado de aprobación del presupuesto del proyecto.
/// También registra fecha y (opcional) quién aprobó/revocó.
Future<void> setPresupuestoAprobado(
  String docId,
  bool aprobado, {
  String? aprobadoPor,
}) async {
  final updates = <String, Object?>{
    'presupuesto_aprobado': aprobado,
    'presupuesto_aprobado_fecha': FieldValue.serverTimestamp(),
  };
  if (aprobadoPor != null && aprobadoPor.isNotEmpty) {
    updates['presupuesto_aprobado_por'] = aprobadoPor;
  }
  await db.collection('list_proyecto').doc(docId).update(updates);
}

/// Totales financieros para el usuario autenticado (suma por proyectos donde participa):
/// { totalSolicitado, totalAprobado, totalGasto, saldoRestante }
Future<Map<String, double>> getTotalesFinancierosUsuario(
    BuildContext context) async {
  final proyectos = await getProyectosDelUsuarioActual(context);
  double totalSolicitado = 0.0;
  double totalAprobado = 0.0;
  double totalGasto = 0.0;
  double saldoRestante = 0.0;

  for (final p in proyectos) {
    final docId = (p['docId'] ?? '').toString();
    final aprobado = (p['presupuesto_aprobado'] ?? false) == true;
    final presupRaw = p['presupuesto_solicitado'];
    double presupuesto = 0.0;
    if (presupRaw is num) presupuesto = presupRaw.toDouble();
    if (presupRaw is String) presupuesto = double.tryParse(presupRaw) ?? 0.0;

    if (presupuesto > 0) {
      totalSolicitado += presupuesto;
    }

    if (aprobado) {
      totalAprobado += presupuesto;
      if (docId.isNotEmpty) {
        final gastos = await calcularTotalGastosProyecto(docId);
        totalGasto += gastos;
        saldoRestante += (presupuesto - gastos);
      }
    }
  }

  return {
    'totalSolicitado': totalSolicitado,
    'totalAprobado': totalAprobado,
    'totalGasto': totalGasto,
    'saldoRestante': saldoRestante,
  };
}

/// Devuelve un conteo por día de tareas completadas en los últimos [dias].
/// Cuenta sólo proyectos donde participa el usuario autenticado.
/// La clave del mapa es la fecha normalizada (UTC, sin hora).
Future<Map<DateTime, int>> getTareasCompletadasPorDiaUltimos(
  BuildContext context, {
  int dias = 30,
}) async {
  // Rango de fechas
  final now = DateTime.now();
  final from = now.subtract(Duration(days: dias - 1));
  final startUtc = DateTime.utc(from.year, from.month, from.day);
  final endUtc = DateTime.utc(now.year, now.month, now.day);

  // Inicializa mapa con 0 para cada día del rango
  final counts = <DateTime, int>{};
  for (int i = 0; i < dias; i++) {
    final d = startUtc.add(Duration(days: i));
    counts[d] = 0;
  }

  // Proyectos del usuario
  final proyectos = await getProyectosDelUsuarioActual(context);
  for (final p in proyectos) {
    final docId = (p['docId'] ?? '').toString();
    if (docId.isEmpty) continue;
    try {
      final snap = await db.collection('list_proyecto').doc(docId).get();
      final data = snap.data() ?? <String, dynamic>{};
      final tareas = data['tareas'];
      if (tareas is! Map) continue;
      tareas.forEach((key, value) {
        if (value is Map) {
          final done = _toBool(value['done']);
          if (!done) return;
          final dt = _toDate(value['fecha_termino']);
          if (dt == null) return;
          final norm = DateTime.utc(dt.year, dt.month, dt.day);
          if (!norm.isBefore(startUtc) && !norm.isAfter(endUtc)) {
            counts[norm] = (counts[norm] ?? 0) + 1;
          }
        }
      });
    } catch (_) {
      // Ignorar errores de lectura individuales
    }
  }
  return counts;
}

// ==========================
// Recursos Materiales (colección separada)
// ==========================

/// Crea un recurso material con cantidad total y disponible inicial igual.
Future<void> addRecursoMaterial({
  required String nombre,
  String descripcion = '',
  required int cantidadTotal,
}) async {
  final now = FieldValue.serverTimestamp();
  await db.collection('recursos_materiales').add({
    'nombre': nombre.trim(),
    'descripcion': descripcion.trim(),
    'cantidad_total': cantidadTotal,
    'cantidad_disponible': cantidadTotal,
    'created_at': now,
    'updated_at': now,
  });
}

Future<void> updateRecursoMaterial(
  String docId, {
  String? nombre,
  String? descripcion,
  int? cantidadTotal,
  int? cantidadDisponible,
}) async {
  // Si nos pasan cantidadDisponible explícita, aplicamos actualización directa.
  // Si NO nos pasan cantidadDisponible pero SÍ cantidadTotal, ajustamos disponible
  // manteniendo constante la cantidad asignada: asignado = total - disponible.
  final ref = db.collection('recursos_materiales').doc(docId);

  if (cantidadDisponible == null && cantidadTotal != null) {
    await db.runTransaction((txn) async {
      final snap = await txn.get(ref);
      if (!snap.exists) return;
      final data = snap.data() ?? <String, dynamic>{};
      int toInt(dynamic v) {
        if (v is int) return v;
        if (v is num) return v.toInt();
        if (v is String) return int.tryParse(v) ?? 0;
        return 0;
      }

      final oldTotal = toInt(data['cantidad_total']);
      final oldDisp = toInt(data['cantidad_disponible']);
      int asignado = oldTotal - oldDisp;
      if (asignado < 0) asignado = 0;
      final int newTotal = cantidadTotal;
      int newDisp = newTotal - asignado;
      if (newDisp < 0) newDisp = 0;
      if (newDisp > newTotal) newDisp = newTotal;

      final updates = <String, Object?>{
        'updated_at': FieldValue.serverTimestamp(),
        'cantidad_total': newTotal,
        'cantidad_disponible': newDisp,
      };
      if (nombre != null) updates['nombre'] = nombre.trim();
      if (descripcion != null) updates['descripcion'] = descripcion.trim();
      txn.update(ref, updates);
    });
  } else {
    final updates = <String, Object?>{
      'updated_at': FieldValue.serverTimestamp()
    };
    if (nombre != null) updates['nombre'] = nombre.trim();
    if (descripcion != null) updates['descripcion'] = descripcion.trim();
    if (cantidadTotal != null) updates['cantidad_total'] = cantidadTotal;
    if (cantidadDisponible != null) {
      int cd = cantidadDisponible;
      if (cantidadTotal != null && cd > cantidadTotal) cd = cantidadTotal;
      if (cd < 0) cd = 0;
      updates['cantidad_disponible'] = cd;
    }
    await ref.update(updates);
  }
}

Stream<List<Map<String, dynamic>>> streamRecursosMateriales() {
  return db.collection('recursos_materiales').snapshots().map((snap) {
    return snap.docs.map((d) {
      final m = d.data();
      m['docId'] = d.id;
      return m;
    }).toList(growable: false);
  });
}

/// Asigna un recurso a una tarea de un proyecto, decrementando disponible atómicamente.
Future<void> asignarRecursoATarea({
  required String recursoId,
  required String proyectoDocId,
  required String tareaKey,
  required int cantidad,
  String? asignadoPorEmail,
}) async {
  await db.runTransaction((txn) async {
    final ref = db.collection('recursos_materiales').doc(recursoId);
    final snap = await txn.get(ref);
    if (!snap.exists) throw Exception('Recurso no existe');
    final data = snap.data() ?? <String, dynamic>{};
    final disp = (data['cantidad_disponible'] is int)
        ? data['cantidad_disponible'] as int
        : int.tryParse(data['cantidad_disponible']?.toString() ?? '0') ?? 0;
    if (cantidad <= 0) {
      throw FirebaseException(
          plugin: 'metrobox',
          code: 'invalcid-amount',
          message: 'Cantidad inválida');
    }
    if (disp < cantidad) {
      throw FirebaseException(
          plugin: 'metrobox',
          code: 'insufficient-funds',
          message: 'No hay suficiente disponible');
    }

    txn.update(ref, {
      'cantidad_disponible': disp - cantidad,
      'updated_at': FieldValue.serverTimestamp(),
    });

    final asignRef = ref.collection('asignaciones').doc();
    txn.set(asignRef, {
      'proyecto_docId': proyectoDocId,
      'tarea_key': tareaKey,
      'cantidad': cantidad,
      'asignado_por': (asignadoPorEmail ?? '').trim(),
      'fecha': FieldValue.serverTimestamp(),
    });

    // Opcional: registrar también en el proyecto para consulta invertida
    final projAssignRef = db
        .collection('list_proyecto')
        .doc(proyectoDocId)
        .collection('asignaciones_recursos')
        .doc();
    txn.set(projAssignRef, {
      'recurso_id': recursoId,
      'tarea_key': tareaKey,
      'cantidad': cantidad,
      'fecha': FieldValue.serverTimestamp(),
      'asignado_por': (asignadoPorEmail ?? '').trim(),
    });
  });
}
