import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_final/Color/Color.dart';
import 'package:proyecto_final/services/firebase_services.dart';

class NotificationsMenu extends StatefulWidget {
  const NotificationsMenu({super.key});

  @override
  State<NotificationsMenu> createState() => _NotificationsMenuState();
}

class _NotificationsMenuState extends State<NotificationsMenu> {
  final List<Map<String, dynamic>> _notificaciones = [];
  final Set<String> _mostradas = {}; // para no duplicar (docId+tipo)
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _cargarNotificaciones();
    // Revisa periódicamente (cada 1 min) para simular "tiempo real"
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      _cargarNotificaciones();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _cargarNotificaciones() async {
    try {
      final nuevas = await generarNotificacionesEntrega(context);
      bool huboCambio = false;
      for (final n in nuevas) {
        final key = '${n['docId']}_${n['tipo']}';
        if (!_mostradas.contains(key)) {
          _mostradas.add(key);
          _notificaciones.insert(0, n);
          huboCambio = true;
        }
      }
      if (huboCambio && mounted) setState(() {});
    } catch (e) {
      // Silencioso o muestra snack según necesidad
    }
  }

  void _limpiarNotificaciones() {
    setState(() {
      _notificaciones.clear();
      _mostradas.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final count = _notificaciones.length;
    return PopupMenuButton<String>(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_none, color: primaryOrange),
          if (count > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: primaryRed,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Center(
                  child: Text(
                    count > 9 ? '9+' : '$count',
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ),
            ),
        ],
      ),
      offset: const Offset(0, 50),
      itemBuilder: (BuildContext context) {
        final items = <PopupMenuEntry<String>>[];
        items.add(const PopupMenuItem<String>(
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
        ));
        items.add(const PopupMenuDivider());

        if (_notificaciones.isEmpty) {
          items.add(const PopupMenuItem<String>(
            enabled: false,
            child: Text('Sin notificaciones'),
          ));
        } else {
          for (final n in _notificaciones) {
            final entrega = (n['dateEntrega'] as DateTime?);
            final subt = entrega != null
                ? 'Entrega: ' + DateFormat('dd/MM/yyyy HH:mm').format(entrega)
                : '';
            items.add(PopupMenuItem<String>(
              value: (n['docId']?.toString() ?? '') + '_' + (n['tipo'] ?? ''),
              child: ListTile(
                leading: Icon(
                  n['tipo'] == '1h' ? Icons.access_time : Icons.event,
                  color: n['tipo'] == '1h' ? primaryRed : primaryOrange,
                ),
                title: Text(n['mensaje'] ?? ''),
                subtitle: Text(subt, style: const TextStyle(fontSize: 12)),
                contentPadding: EdgeInsets.zero,
              ),
            ));
          }
          items.add(const PopupMenuDivider());
          items.add(PopupMenuItem<String>(
            value: 'clear',
            child: Row(
              children: const [
                Icon(Icons.clear_all, color: primaryOrange),
                SizedBox(width: 8),
                Text('Limpiar notificaciones'),
              ],
            ),
          ));
        }
        return items;
      },
      onSelected: (value) {
        if (value == 'clear') {
          _limpiarNotificaciones();
        }
      },
    );
  }
}
