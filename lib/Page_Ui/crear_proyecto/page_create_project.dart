import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_final/Color/Color.dart';
// Reemplazado acceso directo a Firestore por servicios centralizados
import 'package:proyecto_final/services/firebase_services.dart' as api;

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
  // Users cache for email autocomplete
  List<Map<String, dynamic>> _users = [];

  bool _memberLocked = true; // siempre bloqueado: sólo selección desde getUser
  TextEditingController?
      _memberSearchCtrl; // referencia al textCtrl del buscador
  FocusNode? _memberSearchFocus; // referencia al focus del buscador

  @override
  void dispose() {
    _controllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadUsers();
    // Rebuild to reflect readiness when names change
    _controllers['projectName']!.addListener(_onFormFieldChanged);
    _controllers['teamName']!.addListener(_onFormFieldChanged);
  }

  Future<void> _loadUsers() async {
    try {
      final users = await api.getUser(context);
      if (!mounted) return;
      setState(() {
        _users = users;
      });
    } catch (_) {
      // Silencio, ya getUser maneja snackbars
    }
  }

  Map<String, dynamic>? _findUserByEmail(String email) {
    final q = email.trim().toLowerCase();
    if (q.isEmpty) return null;
    for (final u in _users) {
      final e = (u['email'] ?? '').toString().trim().toLowerCase();
      if (e == q) return u;
    }
    return null;
  }

  void _applyUserSelection(Map<String, dynamic> u) {
    final email = (u['email'] ?? '').toString();
    final name = (u['name'] ?? '').toString();
    final cedula = (u['cedula'] ?? '').toString();
    setState(() {
      _controllers['newCorreo']!.text = email;
      _controllers['newIntegrante']!.text = name;
      _controllers['newCedula']!.text = cedula;
      _memberLocked = true;
    });
  }

  void _clearSelectedMember() {
    setState(() {
      // Mantener bloqueado siempre; solo limpiar valores
      _controllers['newCorreo']!.clear();
      _controllers['newIntegrante']!.clear();
      _controllers['newCedula']!.clear();
      _memberSearchCtrl?.clear();
    });
    // devolver el foco al buscador para agilizar el siguiente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _memberSearchFocus?.requestFocus();
    });
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
    final correo = _controllers['newCorreo']!.text.trim();
    final selected = _findUserByEmail(correo);

    if (selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione un integrante válido desde el buscador'),
        ),
      );
      return;
    }

    final name = (selected['name'] ?? '').toString().trim();
    final cedula = (selected['cedula'] ?? '').toString().trim();

    String? nameError = name.isEmpty ? 'Debe seleccionar un integrante.' : null;
    String? cedulaError =
        cedula.isEmpty ? 'Cédula inválida.' : _validateCedula(cedula);
    String? correoError =
        correo.isEmpty ? 'Correo inválido.' : _validateEmail(correo);

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

    // Evitar integrantes duplicados en el proyecto (por correo o cédula)
    final correoLower = correo.toLowerCase();
    final exists = _integrantes.any((i) =>
        i.correo.toLowerCase() == correoLower ||
        (cedula.isNotEmpty && i.cedula == cedula));
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El integrante ya fue agregado a este proyecto.'),
        ),
      );
      return;
    }

    setState(() {
      _integrantes.add(Integrante(
        nombre: name,
        rol: rol,
        cedula: cedula,
        correo: correo,
      ));
      _controllers['newIntegrante']!.clear();
      _controllers['newCedula']!.clear();
      _controllers['newCorreo']!.clear();
      // Mantener bloqueo; limpiar buscador para agregar otro desde getUser
      _memberSearchCtrl?.clear();
    });
    // Devolver foco al buscador tras añadir
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _memberSearchFocus?.requestFocus();
    });
  }

  void _removeIntegrante(int index) =>
      setState(() => _integrantes.removeAt(index));
  void _addTask() {
    final task = _controllers['newTask']!.text.trim();
    if (task.isNotEmpty) {
      // Evitar caracteres no permitidos en claves de Firestore: . # $ [ ] /
      final invalid = RegExp(r'[.#$/\[\]/]');
      if (invalid.hasMatch(task)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('El nombre de la tarea no puede contener . # \$ [ ] /'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      setState(() {
        _tareas[task] = false;
        _controllers['newTask']!.clear();
      });
    }
  }

  void _removeTask(String task) => setState(() => _tareas.remove(task));
  void _toggleTask(String task) =>
      setState(() => _tareas[task] = !_tareas[task]!);

  void _onFormFieldChanged() {
    // Actualiza el estado del botón "Crear Proyecto" al escribir
    if (mounted) setState(() {});
  }

  bool get _isFormReady {
    final project = _controllers['projectName']!.text.trim();
    final team = _controllers['teamName']!.text.trim();
    return project.isNotEmpty &&
        team.isNotEmpty &&
        _startDate != null &&
        _deliveryDate != null &&
        _integrantes.isNotEmpty &&
        _tareas.isNotEmpty;
  }

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
    if (_tareas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe agregar al menos una tarea')),
      );
      return;
    }
    try {
      // Obtener el siguiente id_proyecto secuencial (1 => 0001)
      final int idProyecto = await api.getNextProyectoId();

      // Mapear integrantes al formato requerido por addProyecto
      final integrantesDetalle = _integrantes
          .map((i) => {
                'nombre': i.nombre,
                'email': i.correo,
                'cedula': i.cedula,
              })
          .toList();

      await api.addProyecto(
        idProyecto,
        _controllers['projectName']!.text.trim(),
        _controllers['description']!.text.trim(),
        integrantesDetalle,
        _controllers['teamName']!.text.trim(),
        _tareas,
        false, // estado inicial: en curso
        _startDate!,
        _deliveryDate!,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Proyecto creado y guardado exitosamente.'),
          backgroundColor: Colors.green,
        ),
      );
      if (mounted) Navigator.pushNamed(context, '/principal');
    } catch (e) {
      if (!mounted) return;
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
            constraints: const BoxConstraints(maxWidth: 900.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.3),
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
                      customValidator: (v) => (v == null || v.trim().isEmpty)
                          ? 'El nombre del proyecto es obligatorio'
                          : null,
                    ),
                    const SizedBox(height: 25),
                    _buildTextField(
                      _controllers['teamName']!,
                      'Nombre del Equipo',
                      Icons.group,
                      customValidator: (v) => (v == null || v.trim().isEmpty)
                          ? 'El nombre del equipo es obligatorio'
                          : null,
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
    bool readOnly = false,
  }) =>
      TextFormField(
        controller: controller,
        keyboardType: maxLines > 1 ? TextInputType.multiline : keyboardType,
        maxLines: maxLines,
        maxLength: maxLength,
        readOnly: readOnly,
        validator: customValidator,
        decoration: InputDecoration(
          labelText: label,
          hintText: label,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon),
          counterText: maxLength != null ? '' : null,
        ),
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
          _buildIntegranteSearch(),
          if (_memberLocked)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _clearSelectedMember,
                  icon: const Icon(Icons.clear),
                  label: const Text('Limpiar selección'),
                ),
              ),
            ),
          const SizedBox(height: 10),
          _buildTextField(
            _controllers['newIntegrante']!,
            'Nombre Completo',
            Icons.person,
            readOnly: _memberLocked,
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
                  readOnly: _memberLocked,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildTextField(
                  _controllers['newCorreo']!,
                  'Correo Electrónico',
                  Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  readOnly: _memberLocked,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  _findUserByEmail(_controllers['newCorreo']!.text) != null
                      ? _addIntegrante
                      : null,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 19),
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 5,
          ),
          onPressed: _isFormReady ? _createProject : null,
          child: const Text(
            'Crear Proyecto',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      );

  // Buscador de integrantes por nombre, cédula o correo
  Widget _buildIntegranteSearch() {
    List<Map<String, dynamic>> filterUsers(String q) {
      final query = q.trim().toLowerCase();
      if (query.isEmpty) return _users;
      return _users.where((u) {
        final name = (u['name'] ?? '').toString().toLowerCase();
        final email = (u['email'] ?? '').toString().toLowerCase();
        final ced = (u['cedula'] ?? '').toString().toLowerCase();
        return name.contains(query) ||
            email.contains(query) ||
            ced.contains(query);
      }).toList(growable: false);
    }

    return Autocomplete<Map<String, dynamic>>(
      optionsBuilder: (TextEditingValue tev) {
        return filterUsers(tev.text);
      },
      displayStringForOption: (u) {
        final name = (u['name'] ?? '').toString();
        final ced = (u['cedula'] ?? '').toString();
        final email = (u['email'] ?? '').toString();
        return '$name – $ced – $email';
      },
      onSelected: (u) => _applyUserSelection(u),
      fieldViewBuilder: (context, textCtrl, focusNode, onFieldSubmitted) {
        // Guardar referencia para limpiar desde 'Añadir'
        _memberSearchCtrl = textCtrl;
        _memberSearchFocus = focusNode;
        return TextField(
          controller: textCtrl,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'Buscar integrante (nombre, cédula o correo)',
            hintText: 'Escribe para buscar y selecciona un integrante',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
          onTap: () {
            // Seleccionar todo el texto al presionar el buscador
            textCtrl.selection = TextSelection(
              baseOffset: 0,
              extentOffset: textCtrl.text.length,
            );
          },
          onSubmitted: (_) => onFieldSubmitted(),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240, maxWidth: 900),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final u = options.elementAt(index);
                  final name = (u['name'] ?? '').toString();
                  final ced = (u['cedula'] ?? '').toString();
                  final email = (u['email'] ?? '').toString();
                  return ListTile(
                    dense: true,
                    title: Text(name),
                    subtitle: Text('Cédula: $ced • $email'),
                    onTap: () => onSelected(u),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
