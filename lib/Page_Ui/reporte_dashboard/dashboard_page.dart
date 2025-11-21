import 'package:flutter/material.dart';
import 'models.dart';
import 'proyecto_repository.dart';
import 'widgets.dart';
import 'package:proyecto_final/Color/Color.dart';
import 'package:proyecto_final/Page_Ui/widgets/metro_app_bar.dart';
import 'package:proyecto_final/Page_Ui/widgets/paginacion.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_final/services/firebase_services.dart' as api;

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _repo = const ProyectoRepository();
  final _searchCtrl = TextEditingController();
  DateTimeRange? _range;
  String _estado = 'todos';
  String? _appliedQuery; // query aplicada al presionar botón/enter
  List<Proyecto> _cache = const [];
  static const int _pageSize = 5;
  int _proyectosPage = 0;
  int _proximosPage = 0;
  bool _isAdmin = false;
  String? _currentEmail;

  @override
  void initState() {
    super.initState();
    _initPermissions();
  }

  Future<void> _initPermissions() async {
    final user = FirebaseAuth.instance.currentUser;
    _currentEmail = user?.email?.trim().toLowerCase();
    try {
      final adm = await api.isCurrentUserAdmin(context);
      if (!mounted) return;
      setState(() => _isAdmin = adm);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isAdmin = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MetroAppBar(
        title: 'Dashboard de Proyectos',
        onBackPressed: () => Navigator.pushNamedAndRemoveUntil(
            context, '/principal', (route) => false),
      ),
      body: StreamBuilder<List<Proyecto>>(
        stream: _repo.streamFilteredByEmail(_isAdmin ? null : _currentEmail),
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
          final pagedProx = paginateList<Proyecto>(
            proximos,
            page: _proximosPage,
            pageSize: _pageSize,
          );
          if (_proximosPage != pagedProx.currentPage) {
            _proximosPage = pagedProx.currentPage;
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
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
                        _proyectosPage = 0;
                        _proximosPage = 0;
                      });
                    }
                  },
                  onClearDateRange: _range == null
                      ? null
                      : () => setState(() {
                            _range = null;
                            _proyectosPage = 0;
                            _proximosPage = 0;
                          }),
                  estadoValue: _estado,
                  onChangeEstado: (v) => setState(() {
                    _estado = v;
                    _proyectosPage = 0;
                    _proximosPage = 0;
                  }),
                  onApply: () => setState(() {
                    final q = _searchCtrl.text.trim();
                    _appliedQuery = q.isEmpty ? null : q;
                    _proyectosPage = 0;
                    _proximosPage = 0;
                  }),
                ),
                const SizedBox(height: 16),
                // KPIs agrupados en dos tarjetas (4 items cada una)
                LayoutBuilder(builder: (context, constraints) {
                  final wide = constraints.maxWidth > 900;
                  if (_isAdmin && wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: ProjectStatsCard(stats: stats)),
                        const SizedBox(width: 12),
                        const Expanded(child: FinanceTotalsCard()),
                      ],
                    );
                  }
                  // Column layout (admin shows both stacked, normal solo proyectos)
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ProjectStatsCard(stats: stats),
                      if (_isAdmin) ...[
                        const SizedBox(height: 12),
                        const FinanceTotalsCard(),
                      ],
                    ],
                  );
                }),
                const SizedBox(height: 24),
                // Resumen visual: Pie de estado y tendencia de tareas
                LayoutBuilder(builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 900;
                  final children = [
                    Expanded(
                      child: ProjectStatusPie(
                        activos: stats.proyectosActivos,
                        completados: stats.proyectosCompletados,
                      ),
                    ),
                    const SizedBox(width: 16, height: 16),
                    const Expanded(
                      child: TasksTrendCard(dias: 30),
                    ),
                  ];
                  return isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: children)
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: children);
                }),
                const SizedBox(height: 16),
                const VelocityCard(),
                const SizedBox(height: 24),
                UpcomingDueCompactList(
                  proyectosOrdenadosPorEntrega: pagedProx.items,
                  maxItems: 5,
                  currentPage: _proximosPage,
                  totalPages: pagedProx.totalPages,
                  onPrev: _proximosPage > 0
                      ? () => setState(() => _proximosPage--)
                      : null,
                  onNext: (_proximosPage < pagedProx.totalPages - 1)
                      ? () => setState(() => _proximosPage++)
                      : null,
                ),
                const SizedBox(height: 24),
                const SizedBox(height: 24),

                Text('Proyectos',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Card(
                  color: Theme.of(context).cardColor,
                  child: Builder(builder: (_) {
                    final filtered =
                        _repo.applyFilter(_cache, _currentFilter());
                    final paged = paginateList<Proyecto>(
                      filtered,
                      page: _proyectosPage,
                      pageSize: _pageSize,
                    );
                    if (_proyectosPage != paged.currentPage) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted)
                          setState(() => _proyectosPage = paged.currentPage);
                      });
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (_, i) {
                        final p = paged.items[i];
                        final total = p.tareas.length;
                        final done = p.tareas.values.where((v) => v).length;
                        final pct = total == 0 ? 0.0 : done / total;
                        final fecha =
                            p.fechaCreacion?.toString().split(' ').first ?? '';
                        return Card(
                          color: Theme.of(context).cardColor,
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
                                      label: Text(
                                          p.estado ? 'Completado' : 'En curso'),
                                      backgroundColor: (p.estado
                                          ? statusCompletedColor
                                          : statusActiveColor),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: pct,
                                  backgroundColor: (p.estado
                                          ? statusCompletedColor
                                          : statusActiveColor)
                                      .withOpacity(0.18),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      p.estado
                                          ? statusCompletedColor
                                          : statusActiveColor),
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
                      itemCount: paged.items.length,
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Builder(builder: (_) {
                  final filtered = _repo.applyFilter(_cache, _currentFilter());
                  final paged = paginateList<Proyecto>(
                    filtered,
                    page: _proyectosPage,
                    pageSize: _pageSize,
                  );
                  return PaginationControls(
                    currentPage: _proyectosPage,
                    totalPages: paged.totalPages,
                    onPrev: _proyectosPage > 0
                        ? () => setState(() => _proyectosPage--)
                        : null,
                    onNext: (_proyectosPage < paged.totalPages - 1)
                        ? () => setState(() => _proyectosPage++)
                        : null,
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
