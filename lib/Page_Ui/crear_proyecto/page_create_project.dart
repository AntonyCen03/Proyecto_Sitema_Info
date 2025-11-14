import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proyecto_final/Page_Ui/validator/validar_alfa_num.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_final/Color/Color.dart';
// Reemplazado acceso directo a Firestore por servicios centralizados
import 'package:proyecto_final/services/firebase_services.dart' as api;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'archivo_dialog.dart';

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
    'newLink': TextEditingController(),
  };
  DateTime? _startDate, _deliveryDate;

  final _integrantes = <Integrante>[];
  final _tareas = <String, bool>{};
  final _links = <String>[];
  // Users cache for email autocomplete
  List<Map<String, dynamic>> _users = [];
  bool _editMode = false;
  String? _docId;
  int? _idProyecto;
  bool _prefillDone = false;
  bool _isAdmin = false; // determinado vía servicio
  bool _readOnly = false; // true cuando no es admin

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
    _initAdmin();
  }

  Future<void> _initAdmin() async {
    try {
      final adm = await api.isCurrentUserAdmin(context);
      if (!mounted) return;
      setState(() {
        _isAdmin = adm;
        _readOnly = !_isAdmin; // si no es admin: modo solo lectura
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isAdmin = false;
        _readOnly = true;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefillDone) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      final docId = args['docId']?.toString();
      if (docId != null && docId.isNotEmpty) {
        _editMode = true;
        _docId = docId;
        _prefillFromFirestore(docId);
      }
    }
    _prefillDone = true;
  }

  Future<void> _prefillFromFirestore(String docId) async {
    try {
      final raw = await api.streamProyectoDoc(docId).first;
      if (raw == null) return;
      // Campos básicos
      final nombre = (raw['nombre_proyecto'] ?? '').toString();
      final descripcion = (raw['descripcion'] ?? '').toString();
      final equipo = (raw['nombre_equipo'] ?? '').toString();
      final idP = raw['id_proyecto'];
      int? idParsed;
      if (idP is int)
        idParsed = idP;
      else if (idP is num)
        idParsed = idP.toInt();
      else if (idP is String) idParsed = int.tryParse(idP);

      DateTime? fInicio;
      DateTime? fEntrega;
      final fc = raw['fecha_creacion'];
      final fe = raw['fecha_entrega'];
      if (fc is Timestamp) fInicio = fc.toDate();
      if (fc is DateTime) fInicio = fc;
      if (fe is Timestamp) fEntrega = fe.toDate();
      if (fe is DateTime) fEntrega = fe;

      // Integrantes (lista de mapas con nombre, email, cedula)
      final integrantes = <Integrante>[];
      final listInt = raw['integrante'];
      if (listInt is List) {
        for (final e in listInt) {
          if (e is Map) {
            final nombre = (e['nombre'] ?? '').toString();
            final correo = (e['email'] ?? '').toString();
            final cedula = (e['cedula'] ?? '').toString();
            integrantes.add(Integrante(
              nombre: nombre,
              rol: 'Miembro',
              cedula: cedula,
              correo: correo,
            ));
          }
        }
      }

      // Tareas (puede venir como {tarea: true/false} o {tarea: {done:bool}})
      final tareas = <String, bool>{};
      final rawT = raw['tareas'];
      if (rawT is Map) {
        rawT.forEach((k, v) {
          final key = k?.toString() ?? '';
          if (key.isEmpty) return;
          if (v is Map) {
            final done = v['done'];
            tareas[key] = (done is bool)
                ? done
                : (done is num)
                    ? done != 0
                    : (done is String)
                        ? (done.toLowerCase() == 'true' || done == '1')
                        : false;
          } else if (v is bool) {
            tareas[key] = v;
          } else if (v is num) {
            tareas[key] = v != 0;
          } else if (v is String) {
            tareas[key] = (v.toLowerCase() == 'true' || v == '1');
          }
        });
      }

      // Links (lista de strings)
      final linksPrefill = <String>[];
      final rawLinks = raw['links'];
      if (rawLinks is List) {
        for (final l in rawLinks) {
          if (l is String) {
            final trimmed = l.trim();
            if (trimmed.isNotEmpty) linksPrefill.add(trimmed);
          }
        }
      }

      setState(() {
        _idProyecto = idParsed;
        _controllers['projectName']!.text = nombre;
        _controllers['description']!.text = descripcion;
        _controllers['teamName']!.text = equipo;
        _startDate = fInicio;
        _deliveryDate = fEntrega;
        if (_startDate != null) {
          _controllers['startDate']!.text =
              DateFormat('dd/MM/yyyy').format(_startDate!);
        }
        if (_deliveryDate != null) {
          _controllers['deliveryDate']!.text =
              DateFormat('dd/MM/yyyy').format(_deliveryDate!);
        }
        _integrantes
          ..clear()
          ..addAll(integrantes);
        _tareas
          ..clear()
          ..addAll(tareas);
        _links
          ..clear()
          ..addAll(linksPrefill);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando proyecto: $e')),
      );
    }
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
    // Usar validador centralizado (letras/números/espacios y no vacío)
    final err = validarAlfaNum(task, campo: 'Tarea', maxLength: 50);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: Colors.red),
      );
      return;
    }
    // Evitar caracteres prohibidos por Firestore en keys (defensa adicional)
    final invalid = RegExp(r'[.#$/\[\]/]');
    if (invalid.hasMatch(task)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre de la tarea no puede contener . # \$ [ ] /'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      _tareas[task] = false; // siempre inicializa en false
      _controllers['newTask']!.clear();
    });
  }

  void _addLink() {
    final link = _controllers['newLink']!.text.trim();
    if (link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El enlace no puede estar vacío.')),
      );
      return;
    }
    // Patrón simplificado para validar URL (empieza con http/https y sin espacios)
    final urlPattern = RegExp(r'^(https?:\/\/)[^\s]+$');
    if (!urlPattern.hasMatch(link)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Ingrese una URL válida (debe comenzar con http:// o https://)')),
      );
      return;
    }
    if (_links.contains(link)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El enlace ya fue agregado.')),
      );
      return;
    }
    setState(() {
      _links.add(link);
      _controllers['newLink']!.clear();
    });
  }

  void _removeLink(String link) => setState(() => _links.remove(link));

  void _removeTask(String task) => setState(() => _tareas.remove(task));

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
        _tareas.isNotEmpty; // links opcional
  }

  void _createProject() async {
    if (_readOnly) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Sin permisos para crear proyecto (solo lectura).')));
      return;
    }
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
        _links,
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

  Future<void> _updateProject() async {
    if (_readOnly) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Sin permisos para editar (solo lectura).')));
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    if (_docId == null || _docId!.isEmpty || _idProyecto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proyecto inválido para editar.')),
      );
      return;
    }
    if (_startDate == null || _deliveryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione fechas de inicio y entrega.')),
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
      final integrantesDetalle = _integrantes
          .map((i) => {
                'nombre': i.nombre,
                'email': i.correo,
                'cedula': i.cedula,
              })
          .toList();

      await api.updateProyecto(
        _idProyecto!,
        _controllers['projectName']!.text.trim(),
        _controllers['description']!.text.trim(),
        integrantesDetalle,
        _controllers['teamName']!.text.trim(),
        _tareas,
        false, // mantener estado gestionado por tareas
        _startDate!,
        _deliveryDate!,
        _docId!,
        _links,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('✅ Proyecto actualizado exitosamente.'),
            backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('❌ Error al actualizar: $e'),
            backgroundColor: Colors.red),
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
        title: Text(
          _editMode ? 'Editar Proyecto' : 'Crear Nuevo Proyecto',
          style: const TextStyle(
              color: primaryOrange, fontWeight: FontWeight.bold),
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
                      readOnly: _readOnly,
                      customValidator: (v) => validarAlfaNum(v,
                          campo: 'Nombre del Proyecto', maxLength: 50),
                      inputFormatters: alfaNumEsFormatters(maxLength: 50),
                    ),
                    const SizedBox(height: 25),
                    _buildTextField(
                      _controllers['teamName']!,
                      'Nombre del Equipo',
                      Icons.group,
                      readOnly: _readOnly,
                      customValidator: (v) => validarAlfaNum(v,
                          campo: 'Nombre del Equipo', maxLength: 30),
                      inputFormatters: alfaNumEsFormatters(maxLength: 30),
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
                    _buildIntegrantesField(),
                    const SizedBox(height: 25),
                    _buildTareasField(),
                    const SizedBox(height: 25),
                    _buildLinksField(),
                    const SizedBox(height: 25),
                    _buildCreateOrUpdateButton(),
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
    List<TextInputFormatter>? inputFormatters,
  }) =>
      TextFormField(
        controller: controller,
        keyboardType: maxLines > 1 ? TextInputType.multiline : keyboardType,
        maxLines: maxLines,
        maxLength: maxLength,
        readOnly: readOnly,
        validator: customValidator,
        inputFormatters: inputFormatters,
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
        onTap: _readOnly ? null : () => _selectDate(isStart),
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
              onPressed: _readOnly
                  ? null
                  : (_findUserByEmail(_controllers['newCorreo']!.text) != null
                      ? _addIntegrante
                      : null),
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
                      deleteIcon:
                          _readOnly ? null : const Icon(Icons.close, size: 18),
                      onDeleted:
                          _readOnly ? null : () => _removeIntegrante(e.key),
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
                  inputFormatters: alfaNumEsFormatters(maxLength: 50),
                  readOnly: _readOnly,
                  onFieldSubmitted: _readOnly ? null : (_) => _addTask(),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _readOnly ? null : _addTask,
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
                                // sin decoración: no se puede cambiar el estado aquí
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed:
                                  _readOnly ? null : () => _removeTask(e.key),
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

  Widget _buildLinksField() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enlaces / Recursos',
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
                  controller: _controllers['newLink']!,
                  decoration: const InputDecoration(
                    hintText:
                        'Agregar enlace (ej: https://docs.google.com/...)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 18,
                    ),
                  ),
                  keyboardType: TextInputType.url,
                  readOnly: _readOnly,
                  onFieldSubmitted: _readOnly ? null : (_) => _addLink(),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _readOnly ? null : _addLink,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 19),
                ),
                child: const Text('Añadir'),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: _readOnly
                    ? null
                    : () async {
                        final result = await showDialog<Map<String, String>>(
                          context: context,
                          builder: (_) => const ArchivoDialog(),
                        );
                        if (result != null) {
                          final url = result['url']?.trim();
                          if (url != null &&
                              url.isNotEmpty &&
                              !_links.contains(url)) {
                            setState(() => _links.add(url));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Recurso agregado: ${result['nombre'] ?? 'Recurso'}')),
                            );
                          }
                        }
                      },
                icon: const Icon(Icons.add_link, color: primaryOrange),
                label: const Text('Dialog'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryOrange,
                  side: const BorderSide(color: primaryOrange),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
              ),
            ],
          ),
          if (_links.isNotEmpty) ...[
            const SizedBox(height: 10),
            Column(
              children: _links
                  .map(
                    (link) => Card(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      elevation: 1,
                      child: ListTile(
                        leading: const Icon(Icons.link, color: primaryOrange),
                        title: Text(link,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: _readOnly ? null : () => _removeLink(link),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      );

  Widget _buildCreateOrUpdateButton() => SizedBox(
        width: double.infinity,
        child: _readOnly
            ? Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Modo solo lectura (sin permisos para editar)',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              )
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: primaryOrange,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 5,
                ),
                onPressed: _isFormReady
                    ? (_editMode ? _updateProject : _createProject)
                    : null,
                child: Text(
                  _editMode ? 'Guardar Cambios' : 'Crear Proyecto',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
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

    // Si está en modo lectura, devolver campo bloqueado sin Autocomplete interactivo
    if (_readOnly) {
      return TextField(
        enabled: false,
        decoration: const InputDecoration(
          labelText: 'Buscar integrante (solo lectura)',
          hintText: 'Sin permisos para modificar integrantes',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.lock),
        ),
      );
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
