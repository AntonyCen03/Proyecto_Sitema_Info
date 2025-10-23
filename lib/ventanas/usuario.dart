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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
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
                        Container(
                          width: 350,
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Fila con foto de perfil, nuemoro y nombre
                              Row(
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
                                  const Text(
                                    'lider antony cen',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: colorTextoPrincipal,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              // Correo Electrónico
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Correo Electrónico',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: colorNaranja,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'nombre@correo.unimet.edu.ve',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorTextoSecundario,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Carnet del Usuario
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Carnet del Usuario',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: colorNaranja,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'carnet del usuario',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorTextoSecundario,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Numero
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Numero',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: colorNaranja,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Numero del usuario',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorTextoSecundario,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Pais
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pais',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: colorNaranja,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Ubicacion de la Ciudad',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorTextoSecundario,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Horario
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Horario',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: colorNaranja,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Horario de la ubicacion del usuario',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorTextoSecundario,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        // imagen saman supongo(ya verems)
                        Column(
                          children: [
                            // Imagen del edificio
                            Container(
                              width: 200,
                              height: 350,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
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
                            Container(
                              width: 200,
                              height: 250,
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Proyectos Realizados',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: colorNaranja,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
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
                                                    color: colorTextoSecundario,
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
                                                    color: colorTextoSecundario,
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
                                                    color: colorTextoSecundario,
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
                                                    color: colorTextoSecundario,
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
                                                    color: colorTextoSecundario,
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
                                                    color: colorTextoSecundario,
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
                                                    color: colorTextoSecundario,
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
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Imagen anajo de estudiantes lo quesea
                    Container(
                      width: 350,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
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
                    // Botones
                    Row(
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
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Logo en la esquina superior izquierda
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Image.asset('assets/images/logo.png', height: 80),
              ),
            ),
            // Menú de navegación arriba
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Pagina Principal',
                        style: TextStyle(
                          fontSize: 16,
                          color: colorNaranja,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Proyectos',
                        style: TextStyle(
                          fontSize: 16,
                          color: colorTextoPrincipal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Iconos
            Positioned(
              top: 16,
              right: 16,
              child: Row(
                children: [
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
