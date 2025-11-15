import 'package:flutter/material.dart';
import 'package:proyecto_final/services/firebase_services.dart' as api;
import 'models.dart';

class ProyectoRepository {
  const ProyectoRepository();

  Future<List<Proyecto>> fetch(BuildContext context) async {
    final raw = await api.getProyecto(context);
    return raw.map((e) => Proyecto.fromMap(e)).toList(growable: false);
  }

  Stream<List<Proyecto>> stream() {
    return api.streamProyecto().map(
          (raw) => raw.map((e) => Proyecto.fromMap(e)).toList(growable: false),
        );
  }

  // Filtra por email del integrante si se proporciona; si email es null, devuelve todos.
  Stream<List<Proyecto>> streamFilteredByEmail(String? email) {
    return api.streamProyecto().map((raw) {
      final filtered = (email == null || email.isEmpty)
          ? raw
          : raw.where((m) {
              final det = m['integrantes_detalle'];
              if (det is! List) return false;
              for (final e in det) {
                if (e is Map) {
                  final em = (e['email'] ?? '').toString().trim().toLowerCase();
                  if (em == email.toLowerCase()) return true;
                }
              }
              return false;
            }).toList(growable: false);
      return filtered.map((e) => Proyecto.fromMap(e)).toList(growable: false);
    });
  }

  DashboardStats computeStats(List<Proyecto> proyectos) {
    final total = proyectos.length;
    final activos = proyectos.where((p) => p.estado == false).length;
    final completados = proyectos.where((p) => p.estado == true).length;
    final tareasTotales =
        proyectos.fold<int>(0, (acc, p) => acc + p.tareas.length);
    final tareasPendientes = proyectos.fold<int>(
        0,
        (acc, p) =>
            acc + p.tareas.values.where((done) => done == false).length);
    return DashboardStats(
      totalProyectos: total,
      proyectosActivos: activos,
      proyectosCompletados: completados,
      tareasTotales: tareasTotales,
      tareasPendientes: tareasPendientes,
    );
  }

  List<Proyecto> applyFilter(List<Proyecto> list, ProyectoFilter f) {
    Iterable<Proyecto> it = list;

    if (f.query != null && f.query!.trim().isNotEmpty) {
      final q = f.query!.trim().toLowerCase();
      final asInt = int.tryParse(q);
      it = it.where((p) {
        final matchId = asInt != null
            ? p.idProyecto == asInt
            : p.idProyecto.toString().contains(q);
        final matchNombre = p.nombreProyecto.toLowerCase().contains(q);
        final matchEquipo = p.nombreEquipo.toLowerCase().contains(q);
        final matchIntegrantes =
            p.integrante.map((s) => s.toLowerCase()).any((s) => s.contains(q));
        return matchId || matchNombre || matchEquipo || matchIntegrantes;
      });
    }

    if (f.estado != null) {
      it = it.where((p) => p.estado == f.estado);
    }

    if (f.dateRange != null) {
      final start = f.dateRange!.start;
      final end = f.dateRange!.end;
      it = it.where((p) {
        final d = p.fechaCreacion;
        if (d == null) return false;
        return !d.isBefore(start) && !d.isAfter(end);
      });
    }

    return it.toList(growable: false);
  }
}
