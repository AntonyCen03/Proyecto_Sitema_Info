import 'package:flutter/material.dart';
import 'package:proyecto_final/services/auth_service.dart';

const Color _primaryOrange = Color(0xFFF57C00);
const Color _lightOrange = Color(0xFFFF9800);

class PaginaPrincipal extends StatefulWidget {
  const PaginaPrincipal({super.key});

  @override
  State<PaginaPrincipal> createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Drawer para navegación lateral
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: const Text('Usuario'),
                accountEmail: Text(AuthService().currentUser?.email ?? ''),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: _lightOrange,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                decoration: const BoxDecoration(color: _primaryOrange),
              ),
              Expanded(
                // Lista de opciones del Drawer
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.home, color: _primaryOrange),
                      title: const Text('Página Principal'),
                      onTap: () {
                        // Navigator.push(...)
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.folder, color: _primaryOrange),
                      title: const Text('Proyectos'),
                      onTap: () {
                        // Navigator.push(...)
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.calendar_today,
                        color: _primaryOrange,
                      ),
                      title: const Text('Calendario'),
                      onTap: () {
                        // Navigator.push(...)
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.dashboard, color: _primaryOrange),
                      title: const Text('Dashboard y Reportes'),
                      onTap: () {
                        // Navigator.push(...)
                        Navigator.pop(context);
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(
                        Icons.settings,
                        color: _primaryOrange,
                      ),
                      title: const Text('Ajustes de Usuario'),
                      onTap: () {
                        // Navigator.push(...)
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text(
                        'Cerrar sesión',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () {
                        AuthService().signOut();
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/login');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const _Header(),
            const SizedBox(height: 60),
            const _HeroSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// HEADER
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              // Botón de menú
              IconButton(
                icon: const Icon(Icons.menu, color: _primaryOrange),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
              /*Image.asset(
                'assets/images/metrobox-image.jpg',
                width: 40,
                height: 40,
              ),*/
              const SizedBox(width: 16),
              /*Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextButton(
                  onPressed: () {
                    // TODO: Navegar a Página Principal
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => PaginaPrincipal()));
                  },
                  child: const Text(
                    'Página Principal',
                    style: TextStyle(
                      color: _primaryOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),*/
              /*TextButton(
                onPressed: () {
                  // TODO: Navegar a Proyectos
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => ProyectosPage()));
                },
                child: const Text(
                  'Proyectos',
                  style: TextStyle(color: _primaryOrange),
                ),
              ),*/
            ],
          ),
          Row(
            children: <Widget>[
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.notifications_none,
                  color: _primaryOrange,
                ),
                offset: const Offset(0, 50),
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    enabled: false,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Notificaciones',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _primaryOrange,
                        ),
                      ),
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'notif_1',
                    child: ListTile(
                      leading: Icon(Icons.info_outline, color: _primaryOrange),
                      title: Text('Nueva actualización disponible'),
                      subtitle: Text(
                        'Hace 5 minutos',
                        style: TextStyle(fontSize: 12),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'notif_2',
                    child: ListTile(
                      leading: Icon(
                        Icons.check_circle_outline,
                        color: Colors.green,
                      ),
                      title: Text('Proyecto completado'),
                      subtitle: Text(
                        'Hace 1 hora',
                        style: TextStyle(fontSize: 12),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'notif_3',
                    child: ListTile(
                      leading: Icon(
                        Icons.warning_amber_outlined,
                        color: Colors.orange,
                      ),
                      title: Text('Tarea pendiente'),
                      subtitle: Text(
                        'Hace 2 horas',
                        style: TextStyle(fontSize: 12),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'ver_todas',
                    child: Center(
                      child: Text(
                        'Ver todas las notificaciones',
                        style: TextStyle(
                          color: _primaryOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
                onSelected: (String value) {
                  // TODO: Manejar las notificaciones
                  if (value == 'ver_todas') {
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => NotificacionesPage()));
                  } else {
                    // Manejar click en notificación específica
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => DetalleNotificacionPage(id: value)));
                  }
                },
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.account_circle,
                  color: _primaryOrange,
                  size: 28,
                ),
                offset: const Offset(0, 50),
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'mis_proyectos',
                    child: ListTile(
                      leading: Icon(Icons.folder, color: _primaryOrange),
                      title: Text('Mis Proyectos'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'calendario',
                    child: ListTile(
                      leading: Icon(
                        Icons.calendar_today,
                        color: _primaryOrange,
                      ),
                      title: Text('Calendario'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'dashboard_reportes',
                    child: ListTile(
                      leading: Icon(Icons.dashboard, color: _primaryOrange),
                      title: Text('Dashboard y Reportes'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'ajustes',
                    child: ListTile(
                      leading: Icon(Icons.settings, color: _primaryOrange),
                      title: Text('Ajustes de Usuario'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'cerrar_sesion',
                    child: ListTile(
                      leading: Icon(Icons.logout, color: Colors.red),
                      title: Text(
                        'Cerrar Sesión',
                        style: TextStyle(color: Colors.red),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
                onSelected: (String value) {
                  switch (value) {
                    case 'mis_proyectos':
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => MisProyectosPage()));
                      break;
                    case 'calendario':
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => CalendarioPage()));
                      break;
                    case 'ajustes':
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => AjustesPage()));
                      break;
                    case 'dashboard_reportes':
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardReportesPage()));
                      break;
                    case 'cerrar_sesion':
                      AuthService().signOut(); // Cerrar sesión
                      Navigator.pushNamed(
                        context,
                        '/login',
                      ); // Volver a la página de login
                      break;
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// HERO SECTION
class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo con la imagen CAMPUS-2023_30.jpg OSCURA
        Container(
          height: 600,
          width: double.infinity,
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6), // Capa oscura sobre la imagen
              BlendMode.darken,
            ),
            child: Image.asset(
              'assets/images/CAMPUS-2023_30.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Contenido superpuesto
        Container(
          height: 600,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return const LinearGradient(
                                colors: [_primaryOrange, _lightOrange],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ).createShader(bounds);
                            },
                            child: const Text(
                              'La organización es la\nbase del sistema del\néxito',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Concéntrate en crear y nosotros nos\nencargamos de organizar',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // cuadro de mejores proyectos
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        colors: [_primaryOrange, _lightOrange],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _primaryOrange.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Los mejores proyectos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Ojo
// No estoy usando el footer por ahora
/*class Footer extends StatelessWidget {
  const Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const <Widget>[
          Text(
            'Redes Sociales',
            style: TextStyle(color: _primaryOrange, fontSize: 14),
          ),
          Text(
            'Contáctanos',
            style: TextStyle(color: _primaryOrange, fontSize: 14),
          ),
          Text(
            'Enlaces de Interés',
            style: TextStyle(color: _primaryOrange, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
*/
