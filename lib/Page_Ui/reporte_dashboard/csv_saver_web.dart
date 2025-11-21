// Web download using dart:html
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:proyecto_final/Page_Ui/widgets/custom_message_dialog.dart';

Future<String?> saveCsv(
    BuildContext context, String fileName, String content) async {
  final name = fileName.endsWith('.csv') ? fileName : '$fileName.csv';
  final bytes = utf8.encode(content);
  final blob = html.Blob([bytes], 'text/csv');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', name)
    ..click();
  html.Url.revokeObjectUrl(url);
  // Optional UI hint
  if (context.mounted) {
    showMessageDialog(context, 'Descarga iniciada: $name');
  }
  return null;
}
