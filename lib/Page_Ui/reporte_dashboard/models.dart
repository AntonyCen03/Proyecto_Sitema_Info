import 'package:flutter/material.dart';

class Proyecto {
  final int idProyecto;
  final String nombreProyecto;
  final String descripcion;
  final List<String> integrante;
  final String nombreEquipo;
  final Map<String, bool> tareas;
  final bool estado;
  final DateTime? fechaCreacion;
  final DateTime? fechaEntrega;
  final String docId;

  Proyecto({
    required this.idProyecto,
    required this.nombreProyecto,
    required this.descripcion,
    required this.integrante,
    required this.nombreEquipo,
    required this.tareas,
    required this.estado,
    required this.fechaCreacion,
    required this.fechaEntrega,
    required this.docId,
  });

  factory Proyecto.fromMap(Map<String, dynamic> map) {
    return Proyecto(
      idProyecto: map['id_proyecto'] is int
          ? map['id_proyecto'] as int
          : int.tryParse(map['id_proyecto']?.toString() ?? '') ?? 0,
      nombreProyecto: (map['nombre_proyecto'] ?? '').toString(),
      descripcion: (map['descripcion'] ?? '').toString(),
      integrante: map['integrante'] is List
          ? List<String>.from(map['integrante'])
          : <String>[],
      nombreEquipo: (map['nombre_equipo'] ?? '').toString(),
      tareas: map['tareas'] is Map
          ? Map<String, bool>.from(map['tareas'])
          : <String, bool>{},
      estado: (map['estado'] ?? false) == true,
      fechaCreacion: map['fecha_creacion'] is DateTime
          ? map['fecha_creacion'] as DateTime
          : null,
      fechaEntrega: map['fecha_entrega'] is DateTime
          ? map['fecha_entrega'] as DateTime
          : null,
      docId: (map['docId'] ?? '').toString(),
    );
  }
}

class ProyectoFilter {
  final String? query;
  final DateTimeRange? dateRange; // por fecha_creacion
  final bool? estado; // null: todos, true: completado, false: activo

  const ProyectoFilter({
    this.query,
    this.dateRange,
    this.estado,
  });

  ProyectoFilter copyWith({
    String? query,
    DateTimeRange? dateRange,
    bool? estado,
  }) =>
      ProyectoFilter(
        query: query ?? this.query,
        dateRange: dateRange ?? this.dateRange,
        estado: estado ?? this.estado,
      );
}

class DashboardStats {
  final int totalProyectos;
  final int proyectosActivos;
  final int proyectosCompletados;
  final int tareasTotales;
  final int tareasPendientes; // suma de tareas en proyectos activos

  const DashboardStats({
    required this.totalProyectos,
    required this.proyectosActivos,
    required this.proyectosCompletados,
    required this.tareasTotales,
    required this.tareasPendientes,
  });
}
