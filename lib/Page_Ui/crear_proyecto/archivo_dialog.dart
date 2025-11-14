import 'package:flutter/material.dart';
import 'package:proyecto_final/Color/Color.dart';

/// Dialogo reutilizable para agregar un recurso (archivo via link).
/// Retorna un Map { 'nombre': String, 'url': String } si se confirma,
/// o null si se cancela.
class ArchivoDialog extends StatefulWidget {
  const ArchivoDialog({super.key});

  @override
  State<ArchivoDialog> createState() => _ArchivoDialogState();
}

class _ArchivoDialogState extends State<ArchivoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  bool _validating = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  String? _validateNombre(String? v) {
    if (v == null || v.trim().isEmpty) return 'Nombre requerido';
    if (v.trim().length > 60) return 'Máx 60 caracteres';
    return null;
  }

  String? _validateUrl(String? v) {
    if (v == null || v.trim().isEmpty) return 'URL requerida';
    final url = v.trim();
    final pattern = RegExp(r'^(https?:\/\/)[^\s]+$');
    if (!pattern.hasMatch(url)) {
      return 'URL inválida (debe iniciar con http/https)';
    }
    return null;
  }

  void _submit() async {
    setState(() => _validating = true);
    try {
      if (!_formKey.currentState!.validate()) return; // muestra errores
      final nombre = _nombreCtrl.text.trim();
      final url = _urlCtrl.text.trim();
      Navigator.pop(context, {'nombre': nombre, 'url': url});
    } finally {
      if (mounted) setState(() => _validating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Agregar Recurso',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryOrange,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nombreCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre descriptivo',
                    hintText: 'Ej: Documentación UI',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateNombre,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _urlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'URL del recurso',
                    hintText: 'https://...',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateUrl,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed:
                          _validating ? null : () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _validating ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 14),
                      ),
                      child: _validating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Agregar'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
