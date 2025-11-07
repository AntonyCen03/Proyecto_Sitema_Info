import 'package:flutter/material.dart';

class ProyectoList extends StatelessWidget {
  final List<Map<String, dynamic>> proyectos;

  const ProyectoList({Key? key, required this.proyectos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Ajusta altura en función del ancho disponible para ser responsivo
        final maxW = constraints.maxWidth;
        double height;
        if (maxW >= 1000) {
          height = 420;
        } else if (maxW >= 700) {
          height = 340;
        } else if (maxW >= 450) {
          height = 300;
        } else {
          height = 220;
        }

        final titleColor = const Color(0xFF075985);
        final accent = const Color(0xFF06B6D4);

        return SizedBox(
          height: height,
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Proyectos Realizados',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.separated(
                    itemCount: proyectos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final p = proyectos[index];
                      final title =
                          p['title']?.toString() ?? 'Proyecto ${index + 1}';
                      final percent = (p['percent'] is num)
                          ? (p['percent'] as num).toDouble()
                          : 0.0;
                      return Card(
                        elevation: 0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 12.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      title,
                                      style: TextStyle(
                                        color: titleColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${(percent * 100).toStringAsFixed(0)}%',
                                    style: TextStyle(color: accent),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: percent.clamp(0.0, 1.0),
                                  minHeight: 8,
                                  backgroundColor: const Color(0xFFF1F5F9),
                                  valueColor: AlwaysStoppedAnimation(accent),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
