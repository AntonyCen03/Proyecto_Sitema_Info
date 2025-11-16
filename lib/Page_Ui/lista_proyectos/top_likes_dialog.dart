import 'package:flutter/material.dart';
import 'package:proyecto_final/services/firebase_services.dart' as api;
import 'package:proyecto_final/Color/Color.dart';

/// Dialogo que muestra el Top 10 de proyectos por Likes.
class TopLikesDialog extends StatelessWidget {
  const TopLikesDialog({super.key});

  double _calcPercent(Map<String, dynamic>? tareasRaw) {
    if (tareasRaw == null || tareasRaw.isEmpty) return 0.0;
    int total = 0;
    int done = 0;
    tareasRaw.forEach((_, v) {
      total += 1;
      if (v is Map) {
        if (v['done'] == true) done += 1;
      } else if (v == true) {
        done += 1;
      }
    });
    if (total == 0) return 0.0;
    return (done * 100.0) / total;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: primaryOrange),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Top 10 Proyectos (Likes)',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cerrar',
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: api.streamProyecto(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final data = snapshot.data ?? [];
                  // Ordenar por likes desc
                  final sorted = List<Map<String, dynamic>>.from(data);
                  sorted.sort((a, b) {
                    final la = (a['like'] is int) ? a['like'] as int : 0;
                    final lb = (b['like'] is int) ? b['like'] as int : 0;
                    return lb.compareTo(la);
                  });
                  final top10 = sorted.take(10).toList();
                  if (top10.isEmpty) {
                    return const Center(
                      child: Text('No hay proyectos con likes aún.'),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: top10.length,
                    separatorBuilder: (_, __) => const Divider(height: 12),
                    itemBuilder: (context, index) {
                      final p = top10[index];
                      final titulo = (p['nombre_proyecto'] ?? '').toString();
                      final like = (p['like'] is int) ? p['like'] as int : 0;
                      final tareas =
                          (p['tareas'] as Map?)?.cast<String, dynamic>();
                      final percent = _calcPercent(tareas);
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: primaryOrange.withOpacity(0.15),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: primaryOrange,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    titulo.isEmpty
                                        ? 'Proyecto sin título'
                                        : titulo,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.thumb_up,
                                          size: 16, color: Colors.blueAccent),
                                      const SizedBox(width: 4),
                                      Text('$like likes'),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: percent / 100.0,
                                      minHeight: 6,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor: AlwaysStoppedAnimation(
                                        percent >= 80
                                            ? Colors.green
                                            : (percent >= 50
                                                ? Colors.orange
                                                : Colors.redAccent),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Avance: ${percent.toStringAsFixed(0)}%',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Sin navegación: ícono de premio estático
                            const Icon(Icons.emoji_events,
                                size: 18, color: primaryOrange),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
