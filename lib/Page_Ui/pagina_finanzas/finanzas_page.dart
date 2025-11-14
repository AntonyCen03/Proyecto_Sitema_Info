import 'package:flutter/material.dart';
import 'package:proyecto_final/Page_Ui/pagina_finanzas/proyecto_finanzas.dart';
import 'package:proyecto_final/Page_Ui/widgets/metro_app_bar.dart';

class FinanzasProyectoPage extends StatelessWidget {
  const FinanzasProyectoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    String? docId;
    int? idProyecto;
    String? titulo;

    if (args is Map) {
      docId = args['docId']?.toString();
      final rawId = args['id_proyecto'];
      if (rawId is int) idProyecto = rawId;
      if (rawId is String) idProyecto = int.tryParse(rawId);
      titulo = args['title']?.toString();
    }

    return Scaffold(
      appBar: MetroAppBar(
        title: titulo != null && titulo.isNotEmpty
            ? 'Finanzas • $titulo'
            : 'Finanzas del proyecto',
      ),
      body: docId == null || docId.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Falta docId del proyecto para mostrar finanzas'),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: ProyectoFinanzasPanel(
                  docId: docId,
                  idProyecto: idProyecto,
                  nombreProyecto: titulo,
                ),
              ),
            ),
    );
  }
}
