import 'package:flutter/material.dart';

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
  TextEditingController  nombre = TextEditingController();
  String usuario ="";
  String correo = "";
  String cedula = "";
  String nombreu = "";
  String apellidou = "";
  String categoria = "";
  String carnet = "";
  String grado = "";

  void obtenerinfousuario(){
    //Antoni aqui lo cambiass
    usuario = "Antoni ejemplo";
    correo = 'nombre@correo.unimet.edu.ve';
    cedula = "cedulausuario";
    nombreu = "Antoni";
    apellidou = "cein";
    carnet = "carnet antoni";
    grado = "estudiante";
    
  }

  PreferredSizeWidget appbar() {
    return AppBar(
        title:const Text(
          "MetroBox",
          style: TextStyle(
            color: Color.fromRGBO(240, 83, 43, 1),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
           Align(
            alignment: Alignment.topLeft,
            child:GestureDetector(
              onTap: (){},
              child: Image.asset('assets/images/logo.png', height: 100),
              ), 
          ),
        ),
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
            child: const Icon(
              Icons.person,
              size: 30,
              color: Color(0xFF9C9CFF),
            ),
          ),
        ],
      );
  }

  Widget proyectosrealizados(){
    return Container(
      width: 200,
      height: 250,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color.fromRGBO(208, 215, 255, 1),
        borderRadius: BorderRadius.circular(16.0),
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
                    padding: const EdgeInsets.only(
                      bottom: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        Text(
                          'Proyecto 1',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorNaranja,
                          ),
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
                    padding: const EdgeInsets.only(
                      bottom: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        Text(
                          'Proyecto 2',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorNaranja,
                          ),
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
                    padding: const EdgeInsets.only(
                      bottom: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        Text(
                          'Proyecto 3',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorNaranja,
                          ),
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
                    padding: const EdgeInsets.only(
                      bottom: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        Text(
                          'Proyecto 4',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorNaranja,
                          ),
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
                    padding: const EdgeInsets.only(
                      bottom: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        Text(
                          'Proyecto 5',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorNaranja,
                          ),
                        ),
                        Text(
                          'Porcentaje',
                          style: TextStyle(
                            fontSize: 14,
                            color:Color.fromRGBO(248, 131, 49, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Proyecto 6
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        Text(
                          'Proyecto 6',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorNaranja,
                          ),
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
                    padding: const EdgeInsets.only(
                      bottom: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        Text(
                          'Proyecto 7',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorNaranja,
                          ),
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

  Widget informacion(){
    return Container(
      width: 350,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Color.fromRGBO(208, 215, 255, 1),
        borderRadius: BorderRadius.circular(16.0),
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
                'Apellido',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(240, 83, 43, 1),
                ),
              ),
          const SizedBox(height: 4),
          Text(
                apellidou,
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
            'Horario',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(240, 83, 43, 1),
            ),
          ),
          const SizedBox(height: 4),
          Text(
                'Horario de la ubicacion del usuario',
                style: TextStyle(
                  fontSize: 14,
                  color: Color.fromRGBO(248, 131, 49, 1),
                ),
              ),
        ],
      ),
    );
  }

  Widget perfil(){
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
            child: const Icon(
              Icons.person,
              size: 50,
              color: Color(0xFF9C9CFF),
            ),
          ),
          const SizedBox(width: 16),
          // Nombre del usuario
          Column(children: [
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
        )
           
        ],
    );
  }

  Widget linksdeinteres(){
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
    obtenerinfousuario();
    return MaterialApp(
      home: Scaffold(
      backgroundColor: colorFondo,
      appBar: appbar(),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
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
                            perfil(),
                            const SizedBox(height: 24),
                            informacion(),
                            const SizedBox(height: 24),
                            Container(
                            width: 350,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16.0),
                              child: Image.asset(
                                'assets/images/graduacion.jpg',
                                fit: BoxFit.cover,
                                ),
                              ),
                            ),
                        const SizedBox(height: 24),
                        ]
                        ,),
                        
                        const SizedBox(width: 24),
                        // imagen saman supongo(ya verems)
                        Column(
                          children: [
                            // Imagen del edificio
                            const SizedBox(height: 24),
                            Container(
                              width: 200,
                              height: 390,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16.0),
                                child: Image.asset(
                                  'assets/images/edificio.jpg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Cudro de proyectos realizados
                            proyectosrealizados(),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Botones con informacion de interes
                    linksdeinteres(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Logo en la esquina superior izquierda
            // Menú de navegación arriba
          ],
        ),
      ),
      ),
    );
  }
}
