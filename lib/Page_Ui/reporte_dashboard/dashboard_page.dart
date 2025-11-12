import 'package:flutter/material.dart';
import 'models.dart';
import 'proyecto_repository.dart';
import 'widgets.dart';
import 'package:proyecto_final/Color/Color.dart';
import 'package:proyecto_final/Page_Ui/widgets/metro_app_bar.dart';

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
  // paginación
  static const int _pageSize = 5;
  int _upcomingPage = 0;
  int _projectsPage = 0;

  @override
  void initState() {
    super.initState();
    _future = _repo.fetch(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MetroAppBar(
        title: 'Dashboard de Proyectos',
        onBackPressed: () => Navigator.pushNamedAndRemoveUntil(
            context, '/principal', (route) => false),
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
          // Paginación de próximos
          final totalUpcoming = proximos.length;
          final totalUpcomingPages =
              (totalUpcoming + _pageSize - 1) ~/ _pageSize;
          if (_upcomingPage >= totalUpcomingPages && totalUpcomingPages > 0) {
            _upcomingPage = totalUpcomingPages - 1;
          }
          final int upStart =
              (_upcomingPage * _pageSize).clamp(0, totalUpcoming);
          final int upEnd = (upStart + _pageSize).clamp(0, totalUpcoming);
          final currentUpcoming = totalUpcoming == 0
              ? <Proyecto>[]
              : proximos.sublist(upStart, upEnd);

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
                    if (picked != null) {
                      setState(() {
                        _range = picked;
                        _upcomingPage = 0;
                        _projectsPage = 0;
                      });
                    }
                  },
                  onClearDateRange: _range == null
                      ? null
                      : () => setState(() {
                            _range = null;
                            _upcomingPage = 0;
                            _projectsPage = 0;
                          }),
                  estadoValue: _estado,
                  onChangeEstado: (v) => setState(() {
                    _estado = v;
                    _upcomingPage = 0;
                    _projectsPage = 0;
                  }),
                  onApply: () => setState(() {
                    final q = _searchCtrl.text.trim();
                    _appliedQuery = q.isEmpty ? null : q;
                    _upcomingPage = 0;
                    _projectsPage = 0;
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
                      title: 'En curso',
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
                  color: Colors.white,
                  child: Column(
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (_, i) {
                          final p = currentUpcoming[i];
                          final fecha =
                              p.fechaEntrega?.toString().split(' ').first ?? '';
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: (p.estado
                                  ? statusCompletedColor
                                  : statusActiveColor),
                              child: Text(
                                p.idProyecto.toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(p.nombreProyecto),
                            subtitle: Text(
                                'Equipo: ${p.nombreEquipo} • Entrega: $fecha'),
                            trailing: Icon(
                              p.estado ? Icons.check : Icons.hourglass_empty,
                              color: p.estado
                                  ? statusCompletedColor
                                  : statusActiveColor,
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemCount: currentUpcoming.length,
                      ),
                      if (totalUpcomingPages > 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  'Página ${totalUpcoming == 0 ? 0 : _upcomingPage + 1} de $totalUpcomingPages'),
                              Row(
                                children: [
                                  IconButton(
                                    tooltip: 'Anterior',
                                    onPressed: _upcomingPage > 0
                                        ? () => setState(() {
                                              _upcomingPage--;
                                            })
                                        : null,
                                    icon: const Icon(Icons.chevron_left),
                                  ),
                                  IconButton(
                                    tooltip: 'Siguiente',
                                    onPressed:
                                        (_upcomingPage + 1) < totalUpcomingPages
                                            ? () => setState(() {
                                                  _upcomingPage++;
                                                })
                                            : null,
                                    icon: const Icon(Icons.chevron_right),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('Proyectos',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Builder(builder: (_) {
                  final filtered = _repo.applyFilter(_cache, _currentFilter());
                  // Paginación proyectos
                  final totalProjects = filtered.length;
                  final totalProjectPages =
                      (totalProjects + _pageSize - 1) ~/ _pageSize;
                  if (_projectsPage >= totalProjectPages &&
                      totalProjectPages > 0) {
                    _projectsPage = totalProjectPages - 1;
                  }
                  final int prStart =
                      (_projectsPage * _pageSize).clamp(0, totalProjects);
                  final int prEnd =
                      (prStart + _pageSize).clamp(0, totalProjects);
                  final currentProjects = totalProjects == 0
                      ? <Proyecto>[]
                      : filtered.sublist(prStart, prEnd);

                  return Column(
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (_, i) {
                          final p = currentProjects[i];
                          final total = p.tareas.length;
                          final done = p.tareas.values.where((v) => v).length;
                          final pct = total == 0 ? 0.0 : done / total;
                          final fecha =
                              p.fechaCreacion?.toString().split(' ').first ??
                                  '';
                          return Card(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: (p.estado
                                            ? statusCompletedColor
                                            : statusActiveColor),
                                        child: Text(
                                          p.idProyecto.toString(),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
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
                                          label: Text(p.estado
                                              ? 'Completado'
                                              : 'En curso'),
                                          backgroundColor: (p.estado
                                              ? statusCompletedColor
                                              : statusActiveColor))
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: pct,
                                    backgroundColor: (p.estado
                                            ? statusCompletedColor
                                            : statusActiveColor)
                                        .withValues(alpha: 0.18),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      p.estado
                                          ? statusCompletedColor
                                          : statusActiveColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                      'Progreso: $done/$total (${(pct * 100).round()}%)'),
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemCount: currentProjects.length,
                      ),
                      if (totalProjectPages > 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  'Página ${totalProjects == 0 ? 0 : _projectsPage + 1} de $totalProjectPages'),
                              Row(
                                children: [
                                  IconButton(
                                    tooltip: 'Anterior',
                                    onPressed: _projectsPage > 0
                                        ? () => setState(() {
                                              _projectsPage--;
                                            })
                                        : null,
                                    icon: const Icon(Icons.chevron_left),
                                  ),
                                  IconButton(
                                    tooltip: 'Siguiente',
                                    onPressed:
                                        (_projectsPage + 1) < totalProjectPages
                                            ? () => setState(() {
                                                  _projectsPage++;
                                                })
                                            : null,
                                    icon: const Icon(Icons.chevron_right),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                    ],
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
