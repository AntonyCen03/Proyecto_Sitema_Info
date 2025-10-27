import 'package:flutter/material.dart';
import 'package:proyecto_final/services/auth_service.dart';

// Paleta de colores consistente
const Color _primaryOrange = Color(0xFFF57C00);
const Color _lightOrange = Color(0xFFFF9800);

/// Página principal reestructurada con AppBar, Drawer y fondo de imagen
class PaginaPrincipal2 extends StatefulWidget {
  const PaginaPrincipal2({super.key});

  @override
  State<PaginaPrincipal2> createState() => _PaginaPrincipal2State();
}

class _PaginaPrincipal2State extends State<PaginaPrincipal2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: _buildAppBar(context),
      drawer: const _SideDrawer(),
      body: const _Background(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                _HeroSection(),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: Color.fromARGB(255, 245, 124, 0)),
      title: const Text(
        'MetroBox',
        style: TextStyle(
          color: Color.fromARGB(255, 245, 124, 0),
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: const [_NotificationsMenu(), _AccountMenu(), SizedBox(width: 8)],
    );
  }
}

// Fondo con imagen que cubre toda la página con un filtro para legibilidad
class _Background extends StatelessWidget {
  const _Background({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/CAMPUS-2023_30.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
        ),
      ),
      child: child,
    );
  }
}

class _NotificationsMenu extends StatelessWidget {
  const _NotificationsMenu();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.notifications_none,
        color: Color.fromARGB(255, 245, 124, 0),
      ),
      offset: const Offset(0, 50),
      itemBuilder: (BuildContext context) => const <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
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
        PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'notif_1',
          child: ListTile(
            leading: Icon(Icons.info_outline, color: _primaryOrange),
            title: Text('Nueva actualización disponible'),
            subtitle: Text('Hace 5 minutos', style: TextStyle(fontSize: 12)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}

class _AccountMenu extends StatelessWidget {
  const _AccountMenu();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.account_circle, color: _primaryOrange, size: 28),
      offset: const Offset(0, 50),
      itemBuilder: (BuildContext context) => const <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'mis_proyectos',
          child: ListTile(
            leading: Icon(Icons.folder, color: _primaryOrange),
            title: Text('Mis Proyectos'),
          ),
        ),
          PopupMenuItem<String>(
            value: 'calendario',
            child: ListTile(
              leading: Icon(Icons.calendar_today, color: _primaryOrange),
              title: Text('Calendario'),
            ),
          ),
        PopupMenuItem<String>(
          value: 'Dashboard_reportes',
          child: ListTile(
            leading: Icon(Icons.dashboard, color: _primaryOrange),
            title: Text('Dashboard y Reportes'),
          ),
        ),
        PopupMenuItem<String>(
          value: 'ajustes',
          child: ListTile(
            leading: Icon(Icons.settings, color: _primaryOrange),
            title: Text('Ajustes de Usuario'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'cerrar_sesion',
          child: ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
      onSelected: (String value) {
        switch (value) {
          case 'mis_proyectos':
            Navigator.pushNamed(context, '/mis_proyectos');
            break;
          case 'calendario':
            Navigator.pushNamed(context, '/calendario');
            break;
          case 'dashboard_reportes':
            Navigator.pushNamed(context, '/dashboard_reportes');
            break;
          case 'ajustes':
            Navigator.pushNamed(context, '/perfil');
            break;
          case 'cerrar_sesion':
            AuthService().signOut();
            Navigator.pushNamed(context, '/login');
            break;
        }
      },
    );
  }
}

class _SideDrawer extends StatelessWidget {
  const _SideDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.home, color: _primaryOrange),
                    title: const Text('Página Principal'),
                    onTap: () => Navigator.pop(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.folder, color: _primaryOrange),
                    title: const Text('Proyectos'),
                    onTap: () => Navigator.pop(context),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.calendar_today,
                      color: _primaryOrange,
                    ),
                    title: const Text('Calendario'),
                    onTap: () => Navigator.pop(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.dashboard, color: _primaryOrange),
                    title: const Text('Dashboard y Reportes'),
                    onTap: () => Navigator.pop(context),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.settings, color: _primaryOrange),
                    title: const Text('Ajustes de Usuario'),
                    onTap: () => Navigator.pushNamed(context, '/perfil'),
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
    );
  }
}

// Sección principal con título degradado y subtítulo
class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final double heroHeight = MediaQuery.of(context).size.height * 0.6;
    return SizedBox(
      height: heroHeight,
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
                        shaderCallback: (Rect bounds) => LinearGradient(
                          colors: [_primaryOrange, _lightOrange],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ).createShader(bounds),
                        child: Text(
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
    );
  }
}
