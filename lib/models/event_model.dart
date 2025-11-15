import 'package:flutter/material.dart';
import 'package:proyecto_final/Color/Color.dart';

class EventModel {
  final String title;
  final DateTime date;
  final Color color;
  final bool destacado; // indica si pertenece al usuario autenticado
  final String? proyectoDocId;
  final int? idProyecto;

  EventModel({
    required this.title,
    required this.date,
    this.color = primaryBlue,
    this.destacado = false,
    this.proyectoDocId,
    this.idProyecto,
  });
}
