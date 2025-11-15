import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

Future<String?> saveCsv(
    BuildContext context, String fileName, String content) async {
  try {
    // Prefer Downloads directory on desktop, else Documents.
    Directory? base;
    try {
      base = await getDownloadsDirectory();
    } catch (_) {
      base = null; // Not available on this platform
    }
    base ??= await getApplicationDocumentsDirectory();

    // Ensure .csv extension
    final name = fileName.endsWith('.csv') ? fileName : '$fileName.csv';
    final file = File('${base.path}/$name');
    await file.writeAsString(content, flush: true);

    return file.path;
  } catch (e) {
    debugPrint('saveCsv failed: $e');
    // As a fallback, show a dialog with the CSV so user can copy manually
    if (context.mounted) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('CSV generado'),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(child: SelectableText(content)),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar')),
          ],
        ),
      );
    }
    return null;
  }
}
