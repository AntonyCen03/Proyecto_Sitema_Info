import 'package:flutter/material.dart';
import 'package:proyecto_final/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_final/Color/Color.dart';
import 'package:proyecto_final/services/firebase_services.dart' as api;

class SideDrawer extends StatelessWidget {
  const SideDrawer();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final bool isLoggedIn = user != null;

        return Drawer(
          child: SafeArea(
            child: Column(
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(user?.displayName ?? 'Usuario'),
                  accountEmail: Text(user?.email ?? ''),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: lightOrange,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  decoration: const BoxDecoration(color: primaryOrange),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      // Página principal siempre visible
                      ListTile(
                        leading: const Icon(Icons.home, color: primaryOrange),
                        title: const Text('Página Principal'),
                        onTap: () => Navigator.pop(context),
                      ),

                      // Si NO está autenticado: mostrar opción de iniciar sesión
                      if (!isLoggedIn) ...[
                        const Divider(),
                        ListTile(
                          leading: const Icon(
                            Icons.login,
                            color: primaryOrange,
                          ),
                          title: const Text('Iniciar sesión'),
                          onTap: () => Navigator.pushNamed(context, '/login'),
                        ),
                      ],

                      // Si está autenticado: mostrar secciones privadas
                      if (isLoggedIn) ...[
                        ListTile(
                          leading: const Icon(
                            Icons.folder,
                            color: primaryOrange,
                          ),
                          title: const Text('Proyectos'),
                          onTap: () => Navigator.pop(context),
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.calendar_today,
                            color: primaryOrange,
                          ),
                          title: const Text('Calendario'),
                          onTap: () => Navigator.pop(context),
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.dashboard,
                            color: primaryOrange,
                          ),
                          title: const Text('Dashboard'),
                          onTap: () =>
                              Navigator.pushNamed(context, '/dashboard'),
                        ),
                        // Reportes solo para administradores
                        FutureBuilder<bool>(
                          future: api.isCurrentUserAdmin(context),
                          builder: (context, snap) {
                            final isAdmin = snap.data == true;
                            if (!isAdmin) return const SizedBox.shrink();
                            return ListTile(
                              leading: const Icon(
                                Icons.insert_chart_outlined,
                                color: primaryOrange,
                              ),
                              title: const Text('Reportes'),
                              onTap: () =>
                                  Navigator.pushNamed(context, '/reportes'),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.settings,
                            color: primaryOrange,
                          ),
                          title: const Text('Ajustes de Usuario'),
                          onTap: () => Navigator.pushNamed(context, '/perfil'),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text(
                            'Cerrar sesión',
                            style: TextStyle(color: Colors.red),
                          ),
                          onTap: () async {
                            await AuthService().signOut();
                            // Cerrar el Drawer y regresar a la página principal
                            Navigator.pop(context);
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/principal',
                              (route) => false,
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
