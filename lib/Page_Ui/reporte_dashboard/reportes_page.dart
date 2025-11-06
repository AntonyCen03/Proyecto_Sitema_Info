import 'package:flutter/material.dart';
import 'models.dart';
import 'proyecto_repository.dart';
import 'widgets.dart';
import 'csv_saver.dart';

class ReportesPage extends StatefulWidget {
  const ReportesPage({super.key});

  @override
  State<ReportesPage> createState() => _ReportesPageState();
}

class _ReportesPageState extends State<ReportesPage> {
  final _repo = const ProyectoRepository();
  late Future<List<Proyecto>> _future;

  // filtros
  final _searchCtrl = TextEditingController();
  DateTimeRange? _range;
  String _estado = 'todos'; // todos | activos | completados
  String? _appliedQuery; // query aplicada al presionar botón/enter

  List<Proyecto> _cache = const [];

  @override
  void initState() {
    super.initState();
    _future = _repo.fetch(context);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  ProyectoFilter _currentFilter() {
    return ProyectoFilter(
      query: _appliedQuery,
      dateRange: _range,
      estado: _estado == 'todos' ? null : _estado == 'completados',
    );
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      initialDateRange: _range,
    );
    if (picked != null) {
      setState(() => _range = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes de Proyectos'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Exportar CSV',
            icon: const Icon(Icons.download),
            onPressed: _exportCsv,
          )
        ],
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

          _cache = snap.data ?? [];

          final filtered = _repo.applyFilter(_cache, _currentFilter());
          final rows = filtered.map((p) {
            final total = p.tareas.length;
            final done = p.tareas.values.where((v) => v).length;
            final pct = total == 0 ? 0 : ((done * 100) / total).round();
            return {
              'id': p.idProyecto.toString(),
              'nombre': p.nombreProyecto,
              'equipo': p.nombreEquipo,
              'tareas': '$done/$total (${pct}%)',
              'estado': p.estado ? 'Completado' : 'Activo',
              'creacion': p.fechaCreacion?.toString().split(' ').first ?? '',
              'entrega': p.fechaEntrega?.toString().split(' ').first ?? '',
            };
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FilterBar(
                  searchController: _searchCtrl,
                  dateRange: _range,
                  onPickDateRange: _pickRange,
                  estadoValue: _estado,
                  onChangeEstado: (v) => setState(() => _estado = v),
                  onApply: () => setState(() {
                    final q = _searchCtrl.text.trim();
                    _appliedQuery = q.isEmpty ? null : q;
                  }),
                ),
                const SizedBox(height: 16),
                Expanded(child: ProyectoTable(rows: rows)),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _exportCsv() async {
    // Genera CSV del listado filtrado actual
    final filtered = _repo.applyFilter(_cache, _currentFilter());
    final buffer = StringBuffer();
    buffer.writeln(
        'id_proyecto,nombre_proyecto, equipo, tareas_hechas, tareas_totales, estado, fecha_creacion, fecha_entrega');
    for (final p in filtered) {
      final total = p.tareas.length;
      final done = p.tareas.values.where((v) => v).length;
      final cre = p.fechaCreacion?.toString().split(' ').first ?? '';
      final ent = p.fechaEntrega?.toString().split(' ').first ?? '';
      final nombre = p.nombreProyecto.replaceAll(',', ' ');
      final equipo = p.nombreEquipo.replaceAll(',', ' ');
      buffer.writeln(
          '${p.idProyecto},${nombre},${equipo},${done},${total},${p.estado ? 'Completado' : 'Activo'},${cre},${ent}');
    }

    final csv = buffer.toString();
    final name = 'proyectos_${DateTime.now().millisecondsSinceEpoch}.csv';
    final saved = await saveCsv(context, name, csv);
    if (!mounted) return;
    if (saved != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exportado: $saved')),
      );
    }
  }
}
