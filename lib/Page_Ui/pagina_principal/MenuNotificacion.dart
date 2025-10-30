import 'package:flutter/material.dart';
import 'package:proyecto_final/Color/Color.dart';

class NotificationsMenu extends StatelessWidget {
  const NotificationsMenu();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.notifications_none,
        color: primaryOrange,
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
                color: primaryOrange,
              ),
            ),
          ),
        ),
        PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'notif_1',
          child: ListTile(
            leading: Icon(Icons.info_outline, color: primaryOrange),
            title: Text('Nueva actualización disponible'),
            subtitle: Text('Hace 5 minutos', style: TextStyle(fontSize: 12)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}