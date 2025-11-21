import 'package:flutter/material.dart';
import 'package:proyecto_final/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_final/services/firebase_services.dart' as api;
import 'package:proyecto_final/Color/theme_notifier.dart';

// Paleta de colores consistente
const Color _primaryOrange = Color(0xFFF57C00);
//const Color _lightOrange = Color(0xFFFF9800);

class AccountMenu extends StatelessWidget {
  const AccountMenu();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final bool isLoggedIn = user != null;

        // Determinar si es admin (solo si hay sesión)
        final Future<bool> isAdminFut = isLoggedIn
            ? api.isCurrentUserAdmin(context)
            : Future<bool>.value(false);

        return FutureBuilder<bool>(
          future: isAdminFut,
          builder: (context, snap) {
            final bool isAdmin = snap.data == true;
            return PopupMenuButton<String>(
              icon: FutureBuilder<Map<String, dynamic>?>(
                future: (isLoggedIn && user.email != null)
                    ? api.getUserByEmail(user.email!)
                    : null,
                builder: (context, userSnap) {
                  String? photoUrl;
                  if (userSnap.hasData && userSnap.data != null) {
                    final u = userSnap.data!;
                    final p = (u['photo_url'] ?? '').toString().trim();
                    if (p.isNotEmpty) photoUrl = p;
                  }

                  if (photoUrl != null) {
                    return CircleAvatar(
                      radius: 14,
                      backgroundImage: NetworkImage(photoUrl),
                      backgroundColor: Colors.transparent,
                    );
                  }

                  return const Icon(
                    Icons.account_circle,
                    color: _primaryOrange,
                    size: 28,
                  );
                },
              ),
              offset: const Offset(0, 50),
              itemBuilder: (BuildContext context) {
                final List<PopupMenuEntry<String>> items = [];
                if (isLoggedIn) {
                  items.add(
                    PopupMenuItem<String>(
                      value: 'mis_proyectos',
                      child: ListTile(
                        leading:
                            const Icon(Icons.folder, color: _primaryOrange),
                        title: const Text('Mis Proyectos'),
                      ),
                    ),
                  );
                  items.add(
                    PopupMenuItem<String>(
                      value: 'calendario',
                      child: ListTile(
                        leading: const Icon(
                          Icons.calendar_today,
                          color: _primaryOrange,
                        ),
                        title: const Text('Calendario'),
                      ),
                    ),
                  );
                  items.add(
                    PopupMenuItem<String>(
                      value: 'dashboard',
                      child: ListTile(
                        leading:
                            const Icon(Icons.dashboard, color: _primaryOrange),
                        title: const Text('Dashboard'),
                      ),
                    ),
                  );
                  if (isAdmin) {
                    items.add(
                      PopupMenuItem(
                        value: 'reportes',
                        child: ListTile(
                          leading: const Icon(Icons.insert_chart,
                              color: _primaryOrange),
                          title: const Text('Reportes'),
                        ),
                      ),
                    );
                  }
                  items.add(
                    PopupMenuItem<String>(
                      value: 'ajustes',
                      child: ListTile(
                        leading:
                            const Icon(Icons.settings, color: _primaryOrange),
                        title: const Text('Ajustes de Usuario'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  );
                  items.add(const PopupMenuDivider());
                  items.add(
                    PopupMenuItem<String>(
                      value: 'cerrar_sesion',
                      child: ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text(
                          'Cerrar Sesión',
                          style: TextStyle(color: Colors.red),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  );
                } else {
                  items.add(
                    PopupMenuItem<String>(
                      value: 'iniciar_sesion',
                      child: ListTile(
                        leading: const Icon(Icons.login, color: _primaryOrange),
                        title: const Text('Iniciar Sesión'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  );
                }
                items.add(
                  PopupMenuItem<String>(
                    enabled: false, // No seleccionable, actúa como toggle
                    child: ValueListenableBuilder<ThemeMode>(
                      valueListenable: themeNotifier,
                      builder: (context, mode, _) {
                        final isDark = mode == ThemeMode.dark;
                        return SwitchListTile(
                          title: const Text('Modo Oscuro'),
                          value: isDark,
                          activeColor: _primaryOrange,
                          onChanged: (val) {
                            themeNotifier.toggleTheme();
                            Navigator.pop(context); // Cerrar menú al cambiar
                          },
                        );
                      },
                    ),
                  ),
                );
                return items;
              },
              onSelected: (String value) async {
                switch (value) {
                  case 'mis_proyectos':
                    Navigator.pushNamed(context, '/proyectos_lista');
                    break;
                  case 'calendario':
                    Navigator.pushNamed(context, '/calendario');
                    break;
                  case 'dashboard':
                    Navigator.pushNamed(context, '/dashboard');
                    break;
                  case 'reportes':
                    Navigator.pushNamed(context, '/reportes');
                    break;
                  case 'ajustes':
                    Navigator.pushNamed(context, '/perfil');
                    break;
                  case 'iniciar_sesion':
                    Navigator.pushNamed(context, '/login');
                    break;
                  case 'cerrar_sesion':
                    await AuthService().signOut();
                    // After sign out, return to principal (will rebuild reactively)
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/principal',
                      (route) => false,
                    );
                    break;
                }
              },
            );
          },
        );
      },
    );
  }
}
