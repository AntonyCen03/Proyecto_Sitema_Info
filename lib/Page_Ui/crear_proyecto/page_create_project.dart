import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_final/Color/Color.dart';

class Integrante {
  final String nombre;
  final String rol;

  Integrante({required this.nombre, required this.rol});
}

class PageCreateProject extends StatefulWidget {
  const PageCreateProject({super.key});

  @override
  State<PageCreateProject> createState() => _PageCreateProjectState();
}

class _PageCreateProjectState extends State<PageCreateProject> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _teamNameController = TextEditingController();

  DateTime? _startDate;
  DateTime? _deliveryDate;

  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _deliveryDateController = TextEditingController();

  final List<String> _availableRoles = [
    'Líder',
    'Desarrollador',
    'Diseñador',
    'Tester',
    'Documentador',
    'Otro',
  ];

  final List<Integrante> _integrantes = [];
  final TextEditingController _newIntegranteController =
      TextEditingController();
  String _selectedRole = 'Desarrollador';

  final Map<String, bool> _tareas = {};
  final TextEditingController _newTaskController = TextEditingController();

  @override
  void dispose() {
    _projectNameController.dispose();
    _descriptionController.dispose();
    _teamNameController.dispose();
    _newIntegranteController.dispose();
    _newTaskController.dispose();
    _startDateController.dispose();
    _deliveryDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime minDate;
    if (isStartDate) {
      minDate = DateTime(2000);
    } else {
      minDate = _startDate ?? DateTime.now();
    }

    DateTime initialDate;
    if (isStartDate) {
      initialDate = _startDate ?? DateTime.now();
    } else {
      initialDate = _deliveryDate ?? (_startDate ?? DateTime.now());
    }

    if (initialDate.isBefore(minDate)) {
      initialDate = minDate;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: minDate,
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget? child) {
        return Theme(
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
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_deliveryDate != null && _deliveryDate!.isBefore(_startDate!)) {
            _deliveryDate = _startDate!.add(const Duration(days: 1));
            _deliveryDateController.text = DateFormat(
              'dd/MM/yyyy',
            ).format(_deliveryDate!);
          }
          _startDateController.text = DateFormat(
            'dd/MM/yyyy',
          ).format(_startDate!);
        } else {
          _deliveryDate = picked;
          if (_startDate != null && _startDate!.isAfter(_deliveryDate!)) {
            _startDate = _deliveryDate!.subtract(const Duration(days: 1));
            _startDateController.text = DateFormat(
              'dd/MM/yyyy',
            ).format(_startDate!);
          }
          _deliveryDateController.text = DateFormat(
            'dd/MM/yyyy',
          ).format(_deliveryDate!);
        }
      });
    }
  }

  void _addIntegrante() {
    final name = _newIntegranteController.text.trim();
    if (name.isNotEmpty) {
      setState(() {
        final rolAsignado = _integrantes.isEmpty ? 'Líder' : _selectedRole;

        if (rolAsignado == 'Líder' &&
            _integrantes.any((i) => i.rol == 'Líder')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Ya existe un Líder en el equipo. Por favor, asigne otro rol.',
              ),
            ),
          );
          return;
        }

        _integrantes.add(Integrante(nombre: name, rol: rolAsignado));
        _newIntegranteController.clear();
        if (_integrantes.length == 1 && rolAsignado == 'Líder') {
          _selectedRole = 'Desarrollador';
        }
      });
    }
  }

  void _removeIntegrante(int index) {
    setState(() {
      _integrantes.removeAt(index);
    });
  }

  void _addTask() {
    if (_newTaskController.text.trim().isNotEmpty) {
      setState(() {
        _tareas[_newTaskController.text.trim()] = false;
        _newTaskController.clear();
      });
    }
  }

  void _removeTask(String taskName) {
    setState(() {
      _tareas.remove(taskName);
    });
  }

  void _toggleTaskStatus(String taskName) {
    setState(() {
      _tareas[taskName] = !_tareas[taskName]!;
    });
  }

  void _createProject() {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _deliveryDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Por favor, seleccione las fechas de inicio y entrega',
            ),
          ),
        );
        return;
      }
      if (_integrantes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debe agregar al menos un integrante (el Líder)'),
          ),
        );
        return;
      }

      print('Proyecto a guardar:');
      print('Nombre: ${_projectNameController.text}');
      print('Equipo: ${_teamNameController.text}');
      print('Inicio: $_startDate');
      print('Entrega: $_deliveryDate');
      print(
        'Integrantes: ${_integrantes.map((i) => '${i.nombre} (${i.rol})').toList()}',
      );
      print('Tareas: $_tareas');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proyecto creado exitosamente (simulado)'),
        ),
      );
      Navigator.pop(context);
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
                  children: <Widget>[
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
                      controller: _projectNameController,
                      labelText: 'Nombre del Proyecto',
                      icon: Icons.lightbulb_outline,
                    ),
                    const SizedBox(height: 25),

                    _buildTextField(
                      controller: _teamNameController,
                      labelText: 'Nombre del Equipo',
                      icon: Icons.group,
                    ),
                    const SizedBox(height: 25),

                    _buildIntegrantesField(),
                    const SizedBox(height: 25),

                    _buildTextField(
                      controller: _descriptionController,
                      labelText: 'Descripción del Proyecto',
                      icon: Icons.description,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 25),

                    Row(
                      children: [
                        Expanded(child: _buildDateField(context, true)),
                        const SizedBox(width: 15),
                        Expanded(child: _buildDateField(context, false)),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: maxLines > 1 ? TextInputType.multiline : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: labelText,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, ingrese $labelText';
        }
        return null;
      },
    );
  }

  Widget _buildDateField(BuildContext context, bool isStartDate) {
    final String label = isStartDate ? 'Fecha de Inicio' : 'Fecha de Entrega';

    final TextEditingController controller = isStartDate
        ? _startDateController
        : _deliveryDateController;

    return TextFormField(
      controller: controller,
      readOnly: true,

      decoration: InputDecoration(
        labelText: label,
        hintText: 'Seleccione la fecha',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.calendar_today),
        suffixIcon: const Icon(Icons.arrow_drop_down),
      ),

      onTap: () async {
        FocusScope.of(context).unfocus();
        await _selectDate(context, isStartDate);
      },

      validator: (value) {
        final DateTime? date = isStartDate ? _startDate : _deliveryDate;
        if (date == null) {
          return 'Seleccione una fecha';
        }
        return null;
      },
    );
  }

  Widget _buildIntegrantesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Integrantes del Proyecto y Roles',
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
                controller: _newIntegranteController,
                decoration: const InputDecoration(
                  hintText: 'Nombre del integrante',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 0,
                  ),
                ),
                onFieldSubmitted: (_) => _addIntegrante(),
              ),
            ),
            const SizedBox(width: 10),

            // CORRECCIÓN: Se envuelve el DropdownButtonFormField en Expanded.
            Expanded(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Rol a asignar',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 18,
                  ),
                ),
                items: _availableRoles
                    .map(
                      (role) =>
                          DropdownMenuItem(value: role, child: Text(role)),
                    )
                    .toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedRole = newValue;
                    });
                  }
                },
              ),
            ),

            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: _addIntegrante,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
              ),
              child: const Text('Añadir'),
            ),
          ],
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
                  (entry) => Chip(
                    backgroundColor: entry.value.rol == 'Líder'
                        ? Colors.red.shade100
                        : Colors.blue.shade100,
                    label: Text('${entry.value.nombre} (${entry.value.rol})'),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => _removeIntegrante(entry.key),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildTareasField() {
    return Column(
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
                controller: _newTaskController,
                decoration: const InputDecoration(
                  hintText: 'Agregar tarea (ej: Maquetación UI)',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 0,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
              ),
              child: const Text('Añadir'),
            ),
          ],
        ),
        if (_tareas.isNotEmpty) ...[
          const SizedBox(height: 10),
          Column(
            children: _tareas.entries.map((entry) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8.0),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            decoration: entry.value
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                      ),
                      Checkbox(
                        value: entry.value,
                        onChanged: (bool? newValue) {
                          _toggleTaskStatus(entry.key);
                        },
                        activeColor: primaryOrange,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeTask(entry.key),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildCreateProjectButton() {
    return SizedBox(
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
}
