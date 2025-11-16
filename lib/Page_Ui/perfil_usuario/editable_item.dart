import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proyecto_final/Color/Color.dart';

/// Widget reusable para mostrar un campo con opcion de editar (salvo cuando editable=false).
class EditableItem extends StatefulWidget {
  final String label;
  final String value;
  final bool editable;
  final Future<void> Function(String newValue)? onSaved;

  /// Optional validator that returns an error message string when invalid, or null when valid.
  final String? Function(String value)? validator;

  /// Optional keyboard type for the edit input.
  final TextInputType? keyboardType;

  /// Optional input formatters (e.g., digits only).
  final List<TextInputFormatter>? inputFormatters;

  const EditableItem({
    Key? key,
    required this.label,
    required this.value,
    this.editable = true,
    this.onSaved,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
  }) : super(key: key);

  @override
  State<EditableItem> createState() => _EditableItemState();
}

class _EditableItemState extends State<EditableItem> {
  Future<void> _openEditDialog() async {
    final controller = TextEditingController(text: widget.value);
    String? errorText;

    final result = await showDialog<String?>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Editar ${widget.label}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  autofocus: true,
                  keyboardType: widget.keyboardType ?? TextInputType.text,
                  inputFormatters: widget.inputFormatters,
                  decoration: InputDecoration(
                    hintText: 'Ingrese ${widget.label}',
                    errorText: errorText,
                  ),
                ),
                if (widget.validator != null && errorText != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    errorText!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  final txt = controller.text.trim();
                  final v =
                      widget.validator != null ? widget.validator!(txt) : null;
                  if (v != null) {
                    setState(() {
                      errorText = v;
                    });
                    return;
                  }
                  Navigator.of(context).pop(txt);
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );

    if (result != null && widget.onSaved != null) {
      await widget.onSaved!(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: primaryOrange,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.value.isNotEmpty ? widget.value : '-',
                  style: TextStyle(color: Colors.grey[800], fontSize: 14),
                ),
              ],
            ),
          ),
          if (widget.editable)
            IconButton(
              icon: const Icon(Icons.edit),
              color: primaryOrange,
              onPressed: _openEditDialog,
            ),
        ],
      ),
    );
  }
}
