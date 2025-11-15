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

  void _dismissNotification(Map<String, dynamic> n) {
    final key = '${n['docId']}_${n['tipo']}';
    setState(() {
      _notificaciones.removeWhere((x) => '${x['docId']}_${x['tipo']}' == key);
      // No borrar de _mostradas para evitar que reaparezcan en la próxima carga
    });
  }

  Future<void> _persistNotificationRead(Map<String, dynamic> n) async {
    try {
      final tipo = (n['tipo'] ?? '').toString();
      final docId = (n['docId'] ?? '').toString();
      if (tipo == 'foro' && docId.isNotEmpty) {
        await setForoNotificar(docId, false);
      } else if (docId.isNotEmpty &&
          (tipo == '24h' || tipo == '1h' || tipo == 'vencido')) {
        await setProyectoNotificacion(docId, tipo, false);
      }
    } catch (_) {
      // Ignorar errores de persistencia para no bloquear la UX
    }
  }

  Future<void> _cargarNotificaciones() async {
    try {
      final nuevas = await generarNotificacionesEntrega(context);
      final menciones = await getForoMentions(context);
      bool huboCambio = false;
      for (final n in [...nuevas, ...menciones]) {
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
            String subt = '';
            if (n['tipo'] == 'foro') {
              subt = entrega != null
                  ? 'Foro: ' + DateFormat('dd/MM/yyyy HH:mm').format(entrega)
                  : 'Foro';
            } else if (entrega != null) {
              subt =
                  'Entrega: ' + DateFormat('dd/MM/yyyy HH:mm').format(entrega);
            }
            items.add(PopupMenuItem<String>(
              value: (n['docId']?.toString() ?? '') + '_' + (n['tipo'] ?? ''),
              child: ListTile(
                leading: Icon(
                  n['tipo'] == 'foro'
                      ? Icons.forum
                      : (n['tipo'] == '1h' ? Icons.access_time : Icons.event),
                  color: n['tipo'] == 'foro'
                      ? primaryBlue
                      : (n['tipo'] == '1h' ? primaryRed : primaryOrange),
                ),
                title: Text(n['mensaje'] ?? ''),
                subtitle: Text(subt, style: const TextStyle(fontSize: 12)),
                contentPadding: EdgeInsets.zero,
                onTap: () async {
                  final persist = _persistNotificationRead(n);
                  _dismissNotification(n);
                  Navigator.pop(context);
                  await persist; // intentar persistir antes de navegar
                  // Navegar al foro si es una notificación de foro y hay id_proyecto
                  if (n['tipo'] == 'foro' && n['id_proyecto'] != null) {
                    final args = {
                      'id_proyecto': n['id_proyecto'],
                      'title': (n['proyecto'] ?? n['nombre_proyecto'] ?? '')
                          .toString(),
                    };
                    if (mounted) {
                      Navigator.pushNamed(
                        this.context,
                        '/foro_page',
                        arguments: args,
                      );
                    }
                  }
                },
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
      onSelected: (value) async {
        if (value == 'clear') {
          // Persistir todas en segundo plano y limpiar UI
          final items = List<Map<String, dynamic>>.from(_notificaciones);
          _limpiarNotificaciones();
          // Ejecutar persistencias sin bloquear
          unawaited(Future.wait(items.map(_persistNotificationRead)));
        }
      },
    );
  }
}
