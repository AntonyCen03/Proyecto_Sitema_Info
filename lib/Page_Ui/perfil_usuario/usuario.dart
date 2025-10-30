import 'package:flutter/material.dart';
import 'package:proyecto_final/services/auth_service.dart';
import 'package:proyecto_final/services/firebase_services.dart';

const Color colorPrimario = Color(0xFF6200EE);
const Color colorFondo = Color(0xFFF5F5F5);
const Color colorTextoPrincipal = Colors.black;
const Color colorTextoSecundario = Colors.grey;
const Color colorNaranja = Color.fromARGB(255, 238, 143, 0);

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
  String usuario = "";
  String correo = "";
  String cedula = "";
  String nombreu = "";
  String categoria = "";
  String carnet = "";
  String grado = "";
  String ultimaconecion = "";
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
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final users = await getUser(context);
      if (!mounted) return;
      // Try to find the user that matches the currently authenticated email.
      final currentEmail = AuthService().currentUser?.email?.toString().trim();
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
      setState(() {
        correo = user?['email']?.toString().trim() ?? '';
        cedula = user?['cedula']?.toString() ?? "";
        nombreu = user?['name']?.toString() ?? "";
        carnet = user?['id_carnet']?.toString() ?? "";
        // Populate controllers so the edit form shows current values
        nombre.text = nombreu;
        carnetusuario.text = carnet;
        cedulausuario.text = cedula;
        if (user?['isadmin'] == true) {
          grado = "Administrador";
        } else {
          grado = "Usuario";
        }
        ultimaconecion = user?['date_login']?.toString() ?? '';
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
    } catch (e) {
      if (!mounted) return;
      setState(() {
        correo = AuthService().currentUser?.email ?? '';
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
    // Make this async-ish to safely fetch users and update.
    getUser(context)
        .then((users) async {
          try {
            final currentEmail = AuthService().currentUser?.email
                ?.toString()
                .trim();
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
        })
        .catchError((e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al obtener usuarios: $e')),
          );
        });
  }

  PreferredSizeWidget appbar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: Color.fromARGB(255, 254, 143, 33),
        ),
        onPressed: () => Navigator.pushNamed(context, '/principal'),
        tooltip: 'Volver',
      ),
      title: const Text(
        "MetroBox",
        style: TextStyle(
          color: Color.fromRGBO(240, 83, 43, 1),
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      /*flexibleSpace: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
           Align(
            alignment: Alignment.topLeft,
            child:GestureDetector(
              onTap: (){},
              child: Image.asset('assets/images/logo.png', height: 100),
              ), 
          ),
        ),*/
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications, size: 30),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFE8E8FF),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, size: 30, color: Color(0xFF9C9CFF)),
        ),
      ],
    );
  }

  Widget proyectosrealizados() {
    return Container(
      width: 250,
      height: 250,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color.fromRGBO(208, 215, 255, 1),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Color.fromARGB(255, 0, 0, 55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Proyectos Realizados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(240, 83, 43, 1),
            ),
          ),
          const SizedBox(height: 16),
          //CAMBIAR TODO ESTO
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Proyecto 1
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Proyecto 1',
                          style: TextStyle(fontSize: 14, color: colorNaranja),
                        ),
                        Text(
                          'Porcentaje',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color.fromRGBO(248, 131, 49, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Proyecto 2
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Proyecto 2',
                          style: TextStyle(fontSize: 14, color: colorNaranja),
                        ),
                        Text(
                          'Porcentaje',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color.fromRGBO(248, 131, 49, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Proyecto 3
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Proyecto 3',
                          style: TextStyle(fontSize: 14, color: colorNaranja),
                        ),
                        Text(
                          'Porcentaje',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color.fromRGBO(248, 131, 49, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Proyecto 4
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Proyecto 4',
                          style: TextStyle(fontSize: 14, color: colorNaranja),
                        ),
                        Text(
                          'Porcentaje',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color.fromRGBO(248, 131, 49, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Proyecto 5
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Proyecto 5',
                          style: TextStyle(fontSize: 14, color: colorNaranja),
                        ),
                        Text(
                          'Porcentaje',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color.fromRGBO(248, 131, 49, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Proyecto 6
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Proyecto 6',
                          style: TextStyle(fontSize: 14, color: colorNaranja),
                        ),
                        Text(
                          'Porcentaje',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color.fromRGBO(248, 131, 49, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Proyecto 7
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Proyecto 7',
                          style: TextStyle(fontSize: 14, color: colorNaranja),
                        ),
                        Text(
                          'Porcentaje',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color.fromRGBO(248, 131, 49, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
        color: Color.fromRGBO(208, 215, 255, 1),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Color.fromARGB(255, 0, 0, 55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            "Nombre",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(240, 83, 43, 1),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 300,
            height: 30,
            child: TextField(
              controller: nombre,
              keyboardType: TextInputType.text,
              onChanged: verificacionnombre,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
                labelText: 'Nombre',
              ),
            ),
          ),
          Visibility(visible: isvisiblenom, child: advertencianombre),
          SizedBox(height: espacionomb),
          Text(
            'Correo Electrónico',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(240, 83, 43, 1),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            correo,
            style: TextStyle(
              fontSize: 14,
              color: Color.fromRGBO(248, 131, 49, 1),
            ),
          ),
          const SizedBox(height: 6),
          // Carnet del Usuario
          Text(
            'Carnet del Usuario',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(240, 83, 43, 1),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 300,
            height: 30,
            child: TextField(
              controller: carnetusuario,
              keyboardType: TextInputType.number,
              onChanged: verificacioncarnet,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
                labelText: 'Carnet',
              ),
            ),
          ),
          Visibility(visible: isvisiblece, child: advertenciacarnet),
          SizedBox(height: espaciocar),
          Text(
            'Cedula',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(240, 83, 43, 1),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 300,
            height: 30,
            child: TextField(
              controller: cedulausuario,
              keyboardType: TextInputType.number,
              onChanged: verificacioncedula,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
                labelText: 'Cedula',
              ),
            ),
          ),
          Visibility(visible: isvisibleci, child: advertenciacedula),
          SizedBox(height: espacioce),
          Text(
            'Ultima Coneción',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(240, 83, 43, 1),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            ultimaconecion,
            style: TextStyle(
              fontSize: 14,
              color: Color.fromRGBO(248, 131, 49, 1),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.bottomRight,
            child: Row(
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
                    backgroundColor: const Color.fromRGBO(248, 131, 49, 1),
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    verificacion();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(248, 131, 49, 1),
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  child: const Text('Continuar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget informacion() {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Color.fromRGBO(208, 215, 255, 1),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Color.fromARGB(255, 0, 0, 55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nombre',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(240, 83, 43, 1),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            nombreu,
            style: TextStyle(
              fontSize: 14,
              color: Color.fromRGBO(248, 131, 49, 1),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Correo Electrónico',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(240, 83, 43, 1),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            correo,
            style: TextStyle(
              fontSize: 14,
              color: Color.fromRGBO(248, 131, 49, 1),
            ),
          ),
          const SizedBox(height: 16),
          // Carnet del Usuario
          Text(
            'Carnet del Usuario',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(240, 83, 43, 1),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            carnet,
            style: TextStyle(
              fontSize: 14,
              color: Color.fromRGBO(248, 131, 49, 1),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Cedula',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(240, 83, 43, 1),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            cedula,
            style: TextStyle(
              fontSize: 14,
              color: Color.fromRGBO(248, 131, 49, 1),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Ultima Coneción',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(240, 83, 43, 1),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            ultimaconecion,
            style: TextStyle(
              fontSize: 14,
              color: Color.fromRGBO(248, 131, 49, 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget perfil() {
    return Row(
      children: [
        // Foto de perfil
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFE8E8FF),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, size: 50, color: Color(0xFF9C9CFF)),
        ),
        const SizedBox(width: 16),
        // Nombre del usuario
        Column(
          children: [
            Text(
              usuario,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorTextoPrincipal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              grado,
              style: TextStyle(
                fontSize: 14,
                color: Color.fromRGBO(248, 131, 49, 1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget linksdeinteres() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {},
          child: const Text(
            'Redes Sociales',
            style: TextStyle(
              fontSize: 14,
              color: colorNaranja,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 40),
        TextButton(
          onPressed: () {},
          child: const Text(
            'Contactanos',
            style: TextStyle(
              fontSize: 14,
              color: colorNaranja,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 40),
        TextButton(
          onPressed: () {},
          child: const Text(
            'Enlaces de Interes',
            style: TextStyle(
              fontSize: 14,
              color: colorNaranja,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
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
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Container(
                      width: 700,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(255, 255, 255, 1),
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: Color.fromARGB(255, 0, 0, 55),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 80),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // usuario
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      perfil(),
                                      SizedBox(width: 20),
                                      Visibility(
                                        visible: ajustando,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.settings_outlined,
                                            size: 30,
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
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  infoperfil,
                                  const SizedBox(height: 24),
                                  Container(
                                    width: 350,
                                    height: tamanofoto,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16.0),
                                      child: Image.asset(
                                        "images/foto1.jpg",
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(width: 24),
                              Column(
                                children: [
                                  // Imagen del edificio
                                  const SizedBox(height: 24),
                                  Container(
                                    width: 250,
                                    height: 390,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16.0),
                                      child: Image.asset(
                                        'images/foto2.jpg',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  // Cudro de proyectos realizados
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
            ],
          ),
        ),
      ),
    );
  }
}
