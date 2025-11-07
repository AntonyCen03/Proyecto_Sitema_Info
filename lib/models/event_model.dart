import 'package:flutter/material.dart';
import 'package:proyecto_final/Color/Color.dart';

class EventModel {
  final String title;
  final DateTime date;
  final Color color;

  EventModel({
    required this.title,
    required this.date,
    this.color = primaryBlue,
  });
}
