import 'package:flutter/material.dart';
import 'package:proyecto_final/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
        final bool isLoggedIn = snapshot.data != null;

        return PopupMenuButton<String>(
          icon: const Icon(
            Icons.account_circle,
            color: _primaryOrange,
            size: 28,
          ),
          offset: const Offset(0, 50),
          itemBuilder: (BuildContext context) {
            final List<PopupMenuEntry<String>> items = [];
            if (isLoggedIn) {
              items.add(
                PopupMenuItem<String>(
                  value: 'mis_proyectos',
                  child: ListTile(
                    leading: const Icon(Icons.folder, color: _primaryOrange),
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
                  value: 'dashboard_reportes',
                  child: ListTile(
                    leading: const Icon(Icons.dashboard, color: _primaryOrange),
                    title: const Text('Dashboard y Reportes'),
                  ),
                ),
              );
              items.add(
                PopupMenuItem<String>(
                  value: 'ajustes',
                  child: ListTile(
                    leading: const Icon(Icons.settings, color: _primaryOrange),
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
            return items;
          },
          onSelected: (String value) async {
            switch (value) {
              case 'mis_proyectos':
                //Navigator.pushNamed(context, '/mis_proyectos');
                break;
              case 'calendario':
                //Navigator.pushNamed(context, '/calendario');
                break;
              case 'dashboard_reportes':
                //Navigator.pushNamed(context, '/dashboard_reportes');
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
  }
}
