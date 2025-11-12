import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_final/Color/Color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Integrante {
  final String nombre;
  final String rol;
  final String cedula;
  final String correo;
  Integrante({
    required this.nombre,
    required this.rol,
    required this.cedula,
    required this.correo,
  });
}

class PageCreateProject extends StatefulWidget {
  const PageCreateProject({super.key});
  @override
  State<PageCreateProject> createState() => _PageCreateProjectState();
}

class _PageCreateProjectState extends State<PageCreateProject> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = {
    'projectName': TextEditingController(),
    'description': TextEditingController(),
    'teamName': TextEditingController(),
    'newIntegrante': TextEditingController(),
    'newCedula': TextEditingController(),
    'newCorreo': TextEditingController(),
    'newTask': TextEditingController(),
    'startDate': TextEditingController(),
    'deliveryDate': TextEditingController(),
  };
  DateTime? _startDate, _deliveryDate;

  final _integrantes = <Integrante>[];
  final _tareas = <String, bool>{};

  @override
  void dispose() {
    _controllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  String? _validateCedula(String? value) {
    if (value == null || value.isEmpty) return null;

    if (value.length < 6 || value.length > 8) {
      return 'La Cédula debe tener entre 6 y 8 dígitos.';
    }
    final isNumeric = RegExp(r'^[0-9]+$').hasMatch(value);
    if (!isNumeric) {
      return 'La Cédula solo puede contener números.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return null;

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Por favor, ingrese un correo electrónico válido.';
    }
    return null;
  }

  Future<void> _selectDate(bool isStart) async {
    final minDate = isStart ? DateTime(2000) : (_startDate ?? DateTime.now());
    final initialDate = isStart
        ? (_startDate ?? DateTime.now())
        : (_deliveryDate ?? (_startDate ?? DateTime.now()));
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(minDate) ? minDate : initialDate,
      firstDate: minDate,
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: primaryOrange,
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: primaryOrange),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_deliveryDate != null && _deliveryDate!.isBefore(_startDate!)) {
            _deliveryDate = _startDate!.add(const Duration(days: 1));
            _controllers['deliveryDate']!.text = DateFormat(
              'dd/MM/yyyy',
            ).format(_deliveryDate!);
          }
          _controllers['startDate']!.text = DateFormat(
            'dd/MM/yyyy',
          ).format(_startDate!);
        } else {
          _deliveryDate = picked;
          if (_startDate != null && _startDate!.isAfter(_deliveryDate!)) {
            _startDate = _deliveryDate!.subtract(const Duration(days: 1));
            _controllers['startDate']!.text = DateFormat(
              'dd/MM/yyyy',
            ).format(_startDate!);
          }
          _controllers['deliveryDate']!.text = DateFormat(
            'dd/MM/yyyy',
          ).format(_deliveryDate!);
        }
      });
    }
  }

  void _addIntegrante() {
    final name = _controllers['newIntegrante']!.text.trim();
    final cedula = _controllers['newCedula']!.text.trim();
    final correo = _controllers['newCorreo']!.text.trim();

    String? nameError = name.isEmpty
        ? 'Debe ingresar el nombre completo.'
        : null;

    String? cedulaError = cedula.isEmpty
        ? 'Debe ingresar la Cédula.'
        : _validateCedula(cedula);

    String? correoError = correo.isEmpty
        ? 'Debe ingresar el Correo.'
        : _validateEmail(correo);

    if (nameError != null || cedulaError != null || correoError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, complete y corrija todos los campos del integrante.',
          ),
        ),
      );
      return;
    }

    const rol = 'Miembro';

    setState(() {
      _integrantes.add(
        Integrante(nombre: name, rol: rol, cedula: cedula, correo: correo),
      );
      _controllers['newIntegrante']!.clear();
      _controllers['newCedula']!.clear();
      _controllers['newCorreo']!.clear();
    });
  }

  void _removeIntegrante(int index) =>
      setState(() => _integrantes.removeAt(index));
  void _addTask() {
    final task = _controllers['newTask']!.text.trim();
    if (task.isNotEmpty) {
      setState(() {
        _tareas[task] = false;
        _controllers['newTask']!.clear();
      });
    }
  }

  void _removeTask(String task) => setState(() => _tareas.remove(task));
  void _toggleTask(String task) =>
      setState(() => _tareas[task] = !_tareas[task]!);

  void _createProject() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _deliveryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, seleccione las fechas de inicio y entrega'),
        ),
      );
      return;
    }
    if (_integrantes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe agregar al menos un integrante')),
      );
      return;
    }
    final data = {
      'descripcion': _controllers['description']!.text.trim(),
      'estado': false,
      'fecha_creacion': _startDate,
      'fecha_entrega': _deliveryDate,
      'integrantes': _integrantes
          .map(
            (i) => {
              'nombre': i.nombre,
              'rol': i.rol,
              'cedula': i.cedula,
              'correo': i.correo,
            },
          )
          .toList(),
      'nombre_equipo': _controllers['teamName']!.text.trim(),
      'nombre_proyecto': _controllers['projectName']!.text.trim(),
      'tareas': _tareas,
    };
    try {
      await FirebaseFirestore.instance.collection('proyectos').add(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Proyecto creado y guardado exitosamente.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al crear el proyecto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryOrange),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Volver',
        ),
        title: const Text(
          'Crear Nuevo Proyecto',
          style: TextStyle(color: primaryOrange, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: const IconThemeData(color: primaryOrange),
      ),
      backgroundColor: Colors.grey[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 3,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detalles del Proyecto',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryOrange,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildTextField(
                      _controllers['projectName']!,
                      'Nombre del Proyecto',
                      Icons.lightbulb_outline,
                    ),
                    const SizedBox(height: 25),
                    _buildTextField(
                      _controllers['teamName']!,
                      'Nombre del Equipo',
                      Icons.group,
                    ),
                    const SizedBox(height: 25),
                    _buildIntegrantesField(),
                    const SizedBox(height: 25),
                    _buildTextField(
                      _controllers['description']!,
                      'Descripción del Proyecto',
                      Icons.description,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Expanded(child: _buildDateField(true)),
                        const SizedBox(width: 15),
                        Expanded(child: _buildDateField(false)),
                      ],
                    ),
                    const SizedBox(height: 25),
                    _buildTareasField(),
                    const SizedBox(height: 40),
                    _buildCreateProjectButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    String? Function(String?)? customValidator,
  }) => TextFormField(
    controller: controller,
    keyboardType: maxLines > 1 ? TextInputType.multiline : keyboardType,
    maxLines: maxLines,
    maxLength: maxLength,
    decoration: InputDecoration(
      labelText: label,
      hintText: label,
      border: const OutlineInputBorder(),
      prefixIcon: Icon(icon),
      counterText: maxLength != null ? '' : null,
    ),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Por favor, ingrese $label';
      }
      return customValidator?.call(value);
    },
  );

  Widget _buildDateField(bool isStart) => TextFormField(
    controller: _controllers[isStart ? 'startDate' : 'deliveryDate']!,
    readOnly: true,
    decoration: InputDecoration(
      labelText: isStart ? 'Fecha de Inicio' : 'Fecha de Entrega',
      hintText: 'Seleccione la fecha',
      border: const OutlineInputBorder(),
      prefixIcon: const Icon(Icons.calendar_today),
      suffixIcon: const Icon(Icons.arrow_drop_down),
    ),
    onTap: () => _selectDate(isStart),
    validator: (value) => (isStart ? _startDate : _deliveryDate) == null
        ? 'Seleccione una fecha'
        : null,
  );

  Widget _buildIntegrantesField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Integrantes del Proyecto',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 10),
      _buildTextField(
        _controllers['newIntegrante']!,
        'Nombre Completo',
        Icons.person,
      ),
      const SizedBox(height: 15),
      Row(
        children: [
          Expanded(
            child: _buildTextField(
              _controllers['newCedula']!,
              'Cédula',
              Icons.badge,
              keyboardType: TextInputType.number,
              maxLength: 8,
              customValidator: _validateCedula,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _buildTextField(
              _controllers['newCorreo']!,
              'Correo Electrónico',
              Icons.email,
              keyboardType: TextInputType.emailAddress,
              customValidator: _validateEmail,
            ),
          ),
        ],
      ),
      const SizedBox(height: 15),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _addIntegrante,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryOrange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
          child: const Text('Añadir Integrante'),
        ),
      ),
      if (_integrantes.isNotEmpty) ...[
        const SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: _integrantes
              .asMap()
              .entries
              .map(
                (e) => Chip(
                  backgroundColor: Colors.blue.shade100,
                  label: Text('${e.value.nombre} (${e.value.cedula})'),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => _removeIntegrante(e.key),
                ),
              )
              .toList(),
        ),
      ],
    ],
  );

  Widget _buildTareasField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Tareas del Proyecto',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _controllers['newTask']!,
              decoration: const InputDecoration(
                hintText: 'Agregar tarea (ej: Maquetación UI)',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 18,
                ),
              ),
              onFieldSubmitted: (_) => _addTask(),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: _addTask,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 19),
            ),
            child: const Text('Añadir'),
          ),
        ],
      ),
      if (_tareas.isNotEmpty) ...[
        const SizedBox(height: 10),
        Column(
          children: _tareas.entries
              .map(
                (e) => Card(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            e.key,
                            style: TextStyle(
                              decoration: e.value
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                        ),
                        Checkbox(
                          value: e.value,
                          onChanged: (_) => _toggleTask(e.key),
                          activeColor: primaryOrange,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeTask(e.key),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    ],
  );

  Widget _buildCreateProjectButton() => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: primaryOrange,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 5,
      ),
      onPressed: _createProject,
      child: const Text(
        'Crear Proyecto',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
