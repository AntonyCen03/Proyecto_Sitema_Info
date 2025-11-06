import 'package:flutter/material.dart';
import 'models.dart';
import 'proyecto_repository.dart';
import 'widgets.dart';
import 'package:proyecto_final/Color/Color.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _repo = const ProyectoRepository();
  late Future<List<Proyecto>> _future;
  // filtros
  final _searchCtrl = TextEditingController();
  DateTimeRange? _range;
  String _estado = 'todos';
  String? _appliedQuery; // query aplicada al presionar botón/enter
  List<Proyecto> _cache = const [];

  @override
  void initState() {
    super.initState();
    _future = _repo.fetch(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard de Proyectos'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Proyecto>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final proyectos = snap.data ?? [];
          _cache = proyectos;
          final stats = _repo.computeStats(proyectos);

          final proximos = [...proyectos]
            ..removeWhere((p) => p.fechaEntrega == null)
            ..sort((a, b) => a.fechaEntrega!.compareTo(b.fechaEntrega!));
          final top5 = proximos.take(5).toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // Filtros arriba
                FilterBar(
                  searchController: _searchCtrl,
                  dateRange: _range,
                  onPickDateRange: () async {
                    final now = DateTime.now();
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(now.year - 5),
                      lastDate: DateTime(now.year + 5),
                      initialDateRange: _range,
                    );
                    if (picked != null) setState(() => _range = picked);
                  },
                  estadoValue: _estado,
                  onChangeEstado: (v) => setState(() => _estado = v),
                  onApply: () => setState(() {
                    final q = _searchCtrl.text.trim();
                    _appliedQuery = q.isEmpty ? null : q;
                  }),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount:
                      MediaQuery.of(context).size.width > 900 ? 4 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    SummaryCard(
                      title: 'Total Proyectos',
                      value: stats.totalProyectos.toString(),
                      icon: Icons.all_inbox,
                      color: primaryBlue,
                    ),
                    SummaryCard(
                      title: 'Activos',
                      value: stats.proyectosActivos.toString(),
                      icon: Icons.play_circle,
                      color: primaryOrange,
                    ),
                    SummaryCard(
                      title: 'Completados',
                      value: stats.proyectosCompletados.toString(),
                      icon: Icons.check_circle,
                      color: primaryGreen,
                    ),
                    SummaryCard(
                      title: 'Tareas pendientes',
                      value: stats.tareasPendientes.toString(),
                      icon: Icons.list_alt,
                      color: primaryRed,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Próximos a entregar',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (_, i) {
                      final p = top5[i];
                      final fecha =
                          p.fechaEntrega?.toString().split(' ').first ?? '';
                      return ListTile(
                        leading:
                            CircleAvatar(child: Text(p.idProyecto.toString())),
                        title: Text(p.nombreProyecto),
                        subtitle:
                            Text('Equipo: ${p.nombreEquipo} • Entrega: $fecha'),
                        trailing: Icon(
                          p.estado ? Icons.check : Icons.play_arrow,
                          color: p.estado ? primaryGreen : primaryOrange,
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemCount: top5.length,
                  ),
                ),
                const SizedBox(height: 24),
                Text('Proyectos',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Builder(builder: (_) {
                  final filtered = _repo.applyFilter(_cache, _currentFilter());
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (_, i) {
                      final p = filtered[i];
                      final total = p.tareas.length;
                      final done = p.tareas.values.where((v) => v).length;
                      final pct = total == 0 ? 0.0 : done / total;
                      final fecha =
                          p.fechaCreacion?.toString().split(' ').first ?? '';
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                      child: Text(p.idProyecto.toString())),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(p.nombreProyecto,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium),
                                        Text(
                                            'Equipo: ${p.nombreEquipo} • Creación: $fecha',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall),
                                      ],
                                    ),
                                  ),
                                  Chip(
                                    label: Text(
                                        p.estado ? 'Completado' : 'Activo'),
                                    backgroundColor: (p.estado
                                            ? primaryGreen
                                            : primaryOrange)
                                        .withOpacity(0.15),
                                  )
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(value: pct),
                              const SizedBox(height: 4),
                              Text(
                                  'Progreso: $done/$total (${(pct * 100).round()}%)'),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemCount: filtered.length,
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  ProyectoFilter _currentFilter() => ProyectoFilter(
        query: _appliedQuery,
        dateRange: _range,
        estado: _estado == 'todos' ? null : _estado == 'completados',
      );
}
