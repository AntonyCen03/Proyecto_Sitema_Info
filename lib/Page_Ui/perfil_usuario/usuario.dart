import 'package:flutter/material.dart';
import 'package:proyecto_final/services/auth_service.dart';
import 'package:proyecto_final/services/firebase_services.dart';

const Color colorPrimario = Color(0xFF1A73E8);
const Color colorFondo = Color(0xFFF8F9FA);
const Color colorTextoPrincipal = Color(0xFF202124);
const Color colorTextoSecundario = Color(0xFF5F6368);
const Color colorNaranja = Color(0xFFFF6B35);
const Color colorAcento = Color(0xFF34A853);

class PerfilUsuario extends StatefulWidget {
  const PerfilUsuario({super.key});

  @override
  State<PerfilUsuario> createState() => _PerfilUsuarioState();
}

class _PerfilUsuarioState extends State<PerfilUsuario> {
  TextEditingController nombre = TextEditingController();
  TextEditingController cedulausuario = TextEditingController();
  TextEditingController carnetusuario = TextEditingController();
  late Widget infoperfil = Container();
  bool isvisibleci = false;
  bool isvisiblece = false;
  bool isvisiblenom = false;
  bool ajustando = true;
  String usuario = "Cargando...";
  String correo = "Cargando...";
  String cedula = "Cargando...";
  String nombreu = "Cargando...";
  String categoria = "";
  String carnet = "Cargando...";
  String grado = "Usuario";
  String ultimaconecion = "Cargando...";
  double espacioce = 16;
  double espaciocar = 16;
  double espacionomb = 16;
  double tamanofoto = 200;
  Text advertencianombre = const Text(
    'Introzca su nombre.',
    style: TextStyle(fontSize: 10, color: Colors.red),
  );
  Text advertenciacarnet = Text(
    "",
    style: TextStyle(fontSize: 10, color: Colors.red),
  );
  Text advertenciacedula = Text(
    "",
    style: TextStyle(fontSize: 10, color: Colors.red),
  );

  @override
  void initState() {
    super.initState();
    infoperfil = informacion();
    _loadUser();
  }

  Future<void> _loadUser() async {
    print("===== Iniciando _loadUser =====");
    try {
      print("Obteniendo usuarios...");
      final users = await getUser(context);
      print("Usuarios obtenidos: ${users.length}");

      if (!mounted) return;

      final currentEmail = AuthService().currentUser?.email?.toString().trim();
      print("Email actual: $currentEmail");

      Map<String, dynamic>? user;
      if (currentEmail != null && currentEmail.isNotEmpty) {
        try {
          user = users.cast<Map<String, dynamic>>().firstWhere(
                (u) => (u['email'] ?? '').toString().trim() == currentEmail,
              );
          print("Usuario encontrado por email");
        } catch (_) {
          user = users.isNotEmpty ? users.first : null;
          print("Usuario no encontrado por email, usando el primero");
        }
      } else {
        user = users.isNotEmpty ? users.first : null;
        print("Sin email, usando primer usuario");
      }

      print("Datos del usuario: $user");

      if (mounted) {
        setState(() {
          correo = user?['email']?.toString().trim() ?? 'sin correo';
          cedula = user?['cedula']?.toString() ?? "sin cedula";
          nombreu = user?['name']?.toString() ?? "Sin nombre";
          usuario = nombreu;
          carnet = user?['id_carnet']?.toString() ?? "sin carnet";
          if (user?['isadmin'] == true) {
            grado = "Administrador";
          } else {
            grado = "Usuario";
          }
          ultimaconecion = user?['date_login']?.toString() ?? 'sin fecha';
          advertenciacarnet = Text(
            "Introduzca el carnet",
            style: TextStyle(fontSize: 10, color: Colors.red),
          );
          advertenciacedula = Text(
            "Introduzca la cedula",
            style: TextStyle(fontSize: 10, color: Colors.red),
          );
          infoperfil = informacion();
        });
        print("Estado actualizado correctamente");
      }
    } catch (e, stackTrace) {
      print("===== ERROR en _loadUser =====");
      print("Error: $e");
      print("StackTrace: $stackTrace");

      if (!mounted) return;
      setState(() {
        correo = AuthService().currentUser?.email ?? 'error al cargar';
        nombreu = "Error al cargar";
        usuario = "Error al cargar";
        grado = "Usuario";
        infoperfil = informacion();
      });
    }
  }

  void verificacion() {
    setState(() {
      if (nombre.text.isEmpty ||
          cedulausuario.text.isEmpty ||
          carnetusuario.text.isEmpty) {
        if (nombre.text.isEmpty) {
          isvisiblenom = true;
          espacionomb = 0;
        }
        if (cedulausuario.text.isEmpty) {
          advertenciacedula = Text(
            "Introduzca la cedula",
            style: TextStyle(fontSize: 10, color: Colors.red),
          );
          isvisibleci = true;
          espacioce = 0;
        }
        if (carnetusuario.text.isEmpty) {
          advertenciacarnet = Text(
            "Introduzca el carnet",
            style: TextStyle(fontSize: 10, color: Colors.red),
          );
          isvisiblece = true;
          espaciocar = 0;
        }
        infoperfil = configuraciondeinformacion();
        return;
      }

      actualizarinfousuario();
    });
  }

  void verificacionnombre(String text) {
    setState(() {
      if (nombre.text.isEmpty) {
        isvisiblenom = false;
        espacionomb = 0;
        infoperfil = configuraciondeinformacion();
        return;
      }
    });
  }

  void verificacioncedula(String text) {
    setState(() {
      if (cedulausuario.text.isEmpty) {
        isvisibleci = false;
        espacioce = 0;
        infoperfil = configuraciondeinformacion();
        return;
      }
      final isNumeric = RegExp(r'^\d+$').hasMatch(text);
      if (isNumeric == false) {
        espacioce = 0;
        advertenciacedula = Text(
          'La Cedula solo puede tener números.',
          style: TextStyle(fontSize: 10, color: Colors.red),
        );
        isvisibleci = true;
      } else {
        espacioce = 0;
        isvisibleci = false;
      }
      infoperfil = configuraciondeinformacion();
    });
  }

  void verificacioncarnet(String text) {
    setState(() {
      if (carnetusuario.text.isEmpty) {
        isvisiblece = false;
        espaciocar = 0;
        infoperfil = configuraciondeinformacion();
        return;
      }
      final isNumeric = RegExp(r'^\d+$').hasMatch(text);
      if (isNumeric == false) {
        espaciocar = 0;
        advertenciacarnet = Text(
          'El carnet solo puede tener números.',
          style: TextStyle(fontSize: 10, color: Colors.red),
        );
        isvisiblece = true;
      } else {
        espaciocar = 0;
        isvisiblece = false;
      }
      infoperfil = configuraciondeinformacion();
    });
  }

  void actualizarinfousuario() {
    getUser(context).then((users) async {
      try {
        final currentEmail =
            AuthService().currentUser?.email?.toString().trim();
        Map<String, dynamic>? user;
        if (currentEmail != null && currentEmail.isNotEmpty) {
          try {
            user = users.cast<Map<String, dynamic>>().firstWhere(
                  (u) => (u['email'] ?? '').toString().trim() == currentEmail,
                );
          } catch (_) {
            user = users.isNotEmpty ? users.first : null;
          }
        } else {
          user = users.isNotEmpty ? users.first : null;
        }

        final String uid = user?['uid']?.toString() ?? "";
        // Normalizar entradas: eliminar todo lo que no sea dígito
        final carnetDigits = carnetusuario.text.replaceAll(
          RegExp(r'\D'),
          '',
        );
        final cedulaDigits = cedulausuario.text.replaceAll(
          RegExp(r'\D'),
          '',
        );
        final carnetInt = int.tryParse(carnetDigits) ?? 0;
        await updateUser(nombre.text, carnetInt, cedulaDigits, uid);

        setState(() {
          tamanofoto = 200;
          ajustando = true;
          nombre.clear();
          cedulausuario.clear();
          carnetusuario.clear();
          infoperfil = informacion();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar usuario: $e')),
        );
      }
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener usuarios: $e')),
      );
    });
  }

  PreferredSizeWidget appbar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: colorNaranja),
        onPressed: () => Navigator.pushNamed(context, '/principal'),
        tooltip: 'Volver',
      ),
      title: const Text(
        "MetroBox",
        style: TextStyle(
          color: colorNaranja,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, size: 26),
          color: colorTextoSecundario,
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorPrimario, colorAcento],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, size: 24, color: Colors.white),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget proyectosrealizados() {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.folder_outlined, color: colorNaranja, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Proyectos Activos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorTextoPrincipal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildProyectoItem('Proyecto 1', '85%', colorAcento),
                  _buildProyectoItem('Proyecto 2', '92%', colorPrimario),
                  _buildProyectoItem('Proyecto 3', '67%', colorNaranja),
                  _buildProyectoItem('Proyecto 4', '78%', colorAcento),
                  _buildProyectoItem('Proyecto 5', '95%', colorPrimario),
                  _buildProyectoItem('Proyecto 6', '73%', colorNaranja),
                  _buildProyectoItem('Proyecto 7', '88%', colorAcento),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProyectoItem(String nombre, String porcentaje, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              nombre,
              style: TextStyle(fontSize: 13, color: colorTextoPrincipal),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              porcentaje,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget configuraciondeinformacion() {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          _buildInputField(
            icon: Icons.person_outline,
            label: "Nombre",
            controller: nombre,
            keyboardType: TextInputType.text,
            onChanged: verificacionnombre,
            isVisible: isvisiblenom,
            advertencia: advertencianombre,
            espacio: espacionomb,
          ),
          const SizedBox(height: 16),
          _buildInfoItem(Icons.email_outlined, 'Correo Electrónico', correo),
          const SizedBox(height: 16),
          _buildInputField(
            icon: Icons.credit_card_outlined,
            label: 'Carnet del Usuario',
            controller: carnetusuario,
            keyboardType: TextInputType.number,
            onChanged: verificacioncarnet,
            isVisible: isvisiblece,
            advertencia: advertenciacarnet,
            espacio: espaciocar,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            icon: Icons.fingerprint,
            label: 'Cedula',
            controller: cedulausuario,
            keyboardType: TextInputType.number,
            onChanged: verificacioncedula,
            isVisible: isvisibleci,
            advertencia: advertenciacedula,
            espacio: espacioce,
          ),
          const SizedBox(height: 16),
          _buildInfoItem(Icons.access_time, 'Ultima Conexión', ultimaconecion),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.bottomRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      tamanofoto = 200;
                      ajustando = true;
                      isvisiblece = false;
                      isvisibleci = false;
                      isvisiblenom = false;
                      nombre.clear();
                      cedulausuario.clear();
                      carnetusuario.clear();
                      infoperfil = informacion();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: colorTextoPrincipal,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    verificacion();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorNaranja,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Guardar Cambios'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required Function(String) onChanged,
    required bool isVisible,
    required Text advertencia,
    required double espacio,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: colorNaranja),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorTextoSecundario,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 300,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: colorFondo,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colorPrimario, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ),
        Visibility(visible: isVisible, child: advertencia),
        SizedBox(height: espacio),
      ],
    );
  }

  Widget informacion() {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoItem(Icons.person_outline, 'Nombre', nombreu),
          const SizedBox(height: 16),
          _buildInfoItem(Icons.email_outlined, 'Correo Electrónico', correo),
          const SizedBox(height: 16),
          _buildInfoItem(
            Icons.credit_card_outlined,
            'Carnet del Usuario',
            carnet,
          ),
          const SizedBox(height: 16),
          _buildInfoItem(Icons.fingerprint, 'Cédula', cedula),
          const SizedBox(height: 16),
          _buildInfoItem(Icons.access_time, 'Ultima Conexión', ultimaconecion),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: colorNaranja),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorTextoSecundario,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 26),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: colorTextoPrincipal,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget perfil() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorPrimario, colorAcento],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorPrimario.withOpacity(0.3),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nombreu.isNotEmpty ? nombreu : "Usuario",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: colorTextoPrincipal,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorNaranja.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  grado,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorNaranja,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget linksdeinteres() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLinkButton(Icons.share, 'Redes Sociales'),
          const SizedBox(width: 40),
          _buildLinkButton(Icons.mail_outline, 'Contáctanos'),
          const SizedBox(width: 40),
          _buildLinkButton(Icons.link, 'Enlaces de Interés'),
        ],
      ),
    );
  }

  Widget _buildLinkButton(IconData icon, String text) {
    return TextButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 18, color: colorPrimario),
      label: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: colorPrimario,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: colorFondo,
        appBar: appbar(),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  width: 700,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Row(
                                  children: [
                                    perfil(),
                                    SizedBox(width: 20),
                                    Visibility(
                                      visible: ajustando,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: colorFondo,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.settings_outlined,
                                            size: 24,
                                            color: colorTextoSecundario,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              tamanofoto = 175;
                                              infoperfil =
                                                  configuraciondeinformacion();
                                              ajustando = false;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                infoperfil,
                                const SizedBox(height: 24),
                              ],
                            ),
                            const SizedBox(width: 24),
                            Column(
                              children: [
                                const SizedBox(height: 24),
                                proyectosrealizados(),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
