import 'package:flutter/material.dart';

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
  String usuario = "";
  String correo = "";
  String cedula = "";
  String nombreu = "";
  String apellidou = "";
  String categoria = "";
  String carnet = "";
  String grado = "";

  void obtenerinfousuario() {
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
      backgroundColor: Colors.white,
      elevation: 1,
      title: const Text(
        "MetroBox",
        style: TextStyle(
          color: colorNaranja,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Align(
          alignment: Alignment.topLeft,
          child: GestureDetector(
            onTap: () {},
            child: Image.asset('assets/images/logo.png', height: 100),
          ),
        ),
      ),
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
      width: 200,
      height: 250,
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
          _buildInfoItem(Icons.badge_outlined, 'Apellido', apellidou),
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
          _buildInfoItem(
            Icons.access_time,
            'Horario',
            'Horario de la ubicación del usuario',
          ),
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
                usuario,
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
    obtenerinfousuario();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                                  borderRadius: BorderRadius.circular(12.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: Image.asset(
                                    'assets/images/graduacion.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                          const SizedBox(width: 24),
                          Column(
                            children: [
                              const SizedBox(height: 24),
                              Container(
                                width: 200,
                                height: 390,
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
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: Image.asset(
                                    'assets/images/edificio.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              proyectosrealizados(),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      linksdeinteres(),
                      const SizedBox(height: 24),
                    ],
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
