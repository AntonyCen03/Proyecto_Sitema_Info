import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_final/Color/Color.dart';
import 'package:proyecto_final/services/firebase_services.dart' as api;
import 'package:pie_chart/pie_chart.dart';
import 'models.dart';
import 'package:proyecto_final/Page_Ui/widgets/paginacion.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(value,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: color, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final DateTimeRange? dateRange;
  final VoidCallback onPickDateRange;
  final VoidCallback? onClearDateRange; // limpiar rango
  final String estadoValue; // 'todos' | 'activos' | 'completados'
  final ValueChanged<String> onChangeEstado;
  final VoidCallback onApply; // aplica filtro (botón o Enter)

  const FilterBar({
    super.key,
    required this.searchController,
    required this.dateRange,
    required this.onPickDateRange,
    this.onClearDateRange,
    required this.estadoValue,
    required this.onChangeEstado,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 12,
      spacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 280,
          child: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              labelText: 'Buscar',
              hintText: 'ID, nombre, equipo o integrante',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onSubmitted: (_) => onApply(),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Estado:'),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: estadoValue,
              items: const [
                DropdownMenuItem(value: 'todos', child: Text('Todos')),
                DropdownMenuItem(value: 'activos', child: Text('Activos')),
                DropdownMenuItem(
                    value: 'completados', child: Text('Completados')),
              ],
              onChanged: (v) => onChangeEstado(v ?? 'todos'),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Rango de fechas:'),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.date_range),
              label: Text(dateRange == null
                  ? 'Seleccionar'
                  : '${dateRange!.start.toString().split(' ').first} → ${dateRange!.end.toString().split(' ').first}'),
              onPressed: onPickDateRange,
            ),
            if (dateRange != null) ...[
              const SizedBox(width: 6),
              TextButton.icon(
                icon: const Icon(Icons.clear),
                label: const Text('Limpiar'),
                onPressed: onClearDateRange,
              ),
            ],
          ],
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.search),
          label: const Text('Filtrar'),
          onPressed: onApply,
        ),
      ],
    );
  }
}

class ProyectoTable extends StatelessWidget {
  final List<Map<String, String>> rows;
  const ProyectoTable({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              columnSpacing: 24,
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Proyecto')),
                DataColumn(label: Text('Equipo')),
                DataColumn(label: Text('Tareas')),
                DataColumn(label: Text('Estado')),
                DataColumn(label: Text('Creación')),
                DataColumn(label: Text('Entrega')),
              ],
              rows: rows
                  .map((r) => DataRow(cells: [
                        DataCell(Text(r['id'] ?? '')),
                        DataCell(Text(r['nombre'] ?? '')),
                        DataCell(Text(r['equipo'] ?? '')),
                        DataCell(Text(r['tareas'] ?? '')),
                        DataCell(Text(r['estado'] ?? '')),
                        DataCell(Text(r['creacion'] ?? '')),
                        DataCell(Text(r['entrega'] ?? '')),
                      ]))
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}

/// Card de resumen financiero para el dashboard
class FinanceTotalsCard extends StatelessWidget {
  const FinanceTotalsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'es', symbol: '\$');
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.attach_money_outlined, color: primaryOrange),
                SizedBox(width: 8),
                Text('Resumen financiero',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            FutureBuilder<Map<String, double>>(
              future: api.getTotalesFinancierosUsuario(context),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator(minHeight: 2);
                }
                final data = snap.data ??
                    {
                      'totalSolicitado': 0.0,
                      'totalAprobado': 0.0,
                      'totalGasto': 0.0,
                      'saldoRestante': 0.0,
                    };
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _StatPill(
                      label: 'Total solicitado',
                      value: fmt.format(data['totalSolicitado'] ?? 0.0),
                      color: Colors.blueGrey.shade700,
                    ),
                    _StatPill(
                      label: 'Total aprobado',
                      value: fmt.format(data['totalAprobado'] ?? 0.0),
                      color: Colors.green.shade700,
                    ),
                    _StatPill(
                      label: 'Total gasto',
                      value: fmt.format(data['totalGasto'] ?? 0.0),
                      color: Colors.red.shade700,
                    ),
                    _StatPill(
                      label: 'Saldo restante',
                      value: fmt.format(data['saldoRestante'] ?? 0.0),
                      color: primaryBlue,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Card de resumen de proyectos (4 KPIs en una tarjeta)
class ProjectStatsCard extends StatelessWidget {
  final DashboardStats stats;
  const ProjectStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.dashboard_outlined, color: primaryBlue),
                SizedBox(width: 8),
                Text('Resumen de proyectos',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StatPill(
                  label: 'Total proyectos',
                  value: stats.totalProyectos.toString(),
                  color: primaryBlue,
                ),
                _StatPill(
                  label: 'En curso',
                  value: stats.proyectosActivos.toString(),
                  color: primaryOrange,
                ),
                _StatPill(
                  label: 'Completados',
                  value: stats.proyectosCompletados.toString(),
                  color: primaryGreen,
                ),
                _StatPill(
                  label: 'Tareas pendientes',
                  value: stats.tareasPendientes.toString(),
                  color: primaryRed,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatPill(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

/// Pie de estado de proyectos (Activos vs Completados)
class ProjectStatusPie extends StatelessWidget {
  final int activos;
  final int completados;
  const ProjectStatusPie(
      {super.key, required this.activos, required this.completados});

  @override
  Widget build(BuildContext context) {
    final total = activos + completados;
    final dataMap = <String, double>{
      'Activos': activos.toDouble(),
      'Completados': completados.toDouble(),
    };
    final colorList = [statusActiveColor, statusCompletedColor];
    return Card(
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.pie_chart_outline, color: primaryBlue),
                SizedBox(width: 8),
                Text('Estado de proyectos',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: total == 0
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade200,
                            ),
                            child: Center(
                              child: Text(
                                '0%',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Sin proyectos',
                              style: TextStyle(color: Colors.black45)),
                        ],
                      ),
                    )
                  : PieChart(
                      dataMap: dataMap
                          .map((k, v) => MapEntry(k, v == 0 ? 0.0001 : v)),
                      animationDuration: const Duration(milliseconds: 600),
                      chartType: ChartType.disc,
                      chartValuesOptions: const ChartValuesOptions(
                        showChartValuesInPercentage: true,
                        showChartValueBackground: false,
                      ),
                      legendOptions: const LegendOptions(
                        showLegends: true,
                        legendPosition: LegendPosition.right,
                      ),
                      colorList: colorList,
                      chartRadius: 150,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta con tendencia de tareas completadas los últimos N días
class TasksTrendCard extends StatelessWidget {
  final int dias;
  const TasksTrendCard({super.key, this.dias = 30});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.show_chart, color: primaryGreen),
                SizedBox(width: 8),
                Text('Tendencia tareas completadas (30 días)',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            FutureBuilder<Map<DateTime, int>>(
              future:
                  api.getTareasCompletadasPorDiaUltimos(context, dias: dias),
              builder: (context, snap) {
                final map = snap.data ?? const {};
                final days = List<DateTime>.from(map.keys)..sort();
                final values = days.map((d) => map[d] ?? 0).toList();
                final maxV = values.isEmpty
                    ? 1
                    : (values.reduce((a, b) => a > b ? a : b));
                return SizedBox(
                  height: 180,
                  child: _SimpleLineChart(
                    values: values.map((e) => e.toDouble()).toList(),
                    maxY: maxV.toDouble(),
                    strokeColor: primaryGreen,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SimpleLineChart extends StatelessWidget {
  final List<double> values;
  final double maxY;
  final Color strokeColor;
  const _SimpleLineChart(
      {required this.values, required this.maxY, required this.strokeColor});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineChartPainter(
          values: values, maxY: maxY, strokeColor: strokeColor),
      child: Container(),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final double maxY;
  final Color strokeColor;
  _LineChartPainter(
      {required this.values, required this.maxY, required this.strokeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = strokeColor;

    if (values.isEmpty) return;
    final path = Path();
    final n = values.length;
    final dx = n <= 1 ? size.width : size.width / (n - 1);
    final maxVal = maxY <= 0 ? 1.0 : maxY;

    double yFor(double v) => size.height - (v / maxVal) * (size.height - 4);

    for (int i = 0; i < n; i++) {
      final x = i * dx;
      final y = yFor(values[i]);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    // Eje base tenue
    final axisPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.black12;
    canvas.drawLine(Offset(0, size.height - 1),
        Offset(size.width, size.height - 1), axisPaint);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.maxY != maxY ||
        oldDelegate.strokeColor != strokeColor;
  }
}

/// Lista compacta de próximos vencimientos (top N)
class UpcomingDueCompactList extends StatelessWidget {
  final List<Proyecto> proyectosOrdenadosPorEntrega;
  final int maxItems;
  final int? currentPage;
  final int? totalPages;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  const UpcomingDueCompactList({
    super.key,
    required this.proyectosOrdenadosPorEntrega,
    this.maxItems = 5,
    this.currentPage,
    this.totalPages,
    this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final items = proyectosOrdenadosPorEntrega
        .where((p) => p.fechaEntrega != null)
        .take(maxItems)
        .toList();
    return Card(
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                // Use a generic event icon to avoid const color issues
                Icon(Icons.event_available, color: primaryOrange),
                SizedBox(width: 8),
                Text('Próximos vencimientos',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            ...items.map((p) {
              final fecha = p.fechaEntrega!.toString().split(' ').first;
              return ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                leading: Icon(
                    p.estado ? Icons.check_circle : Icons.hourglass_bottom,
                    color: p.estado ? statusCompletedColor : statusActiveColor),
                title: Text(p.nombreProyecto,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text('Entrega: $fecha • Equipo: ${p.nombreEquipo}',
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Sin entregas próximas'),
              ),
            if ((currentPage != null) && (totalPages != null)) ...[
              const SizedBox(height: 4),
              PaginationControls(
                currentPage: currentPage!,
                totalPages: totalPages!,
                onPrev: onPrev,
                onNext: onNext,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Card de velocidad del equipo (tareas completadas en la última semana)
class VelocityCard extends StatelessWidget {
  const VelocityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.speed, color: primaryBlue),
                SizedBox(width: 8),
                Text('Velocidad del equipo (última semana)',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            FutureBuilder<Map<DateTime, int>>(
              future: api.getTareasCompletadasPorDiaUltimos(context, dias: 7),
              builder: (context, snap) {
                final data = snap.data ?? const {};
                // número de días del periodo (fallback a 7)
                final days = 7;
                final total = data.values.fold<int>(0, (acc, v) => acc + v);
                final average = days > 0 ? total / days : 0.0;
                // Objetivo por día (configurable): 10 tareas/día -> objetivo semanal = days * 10
                const targetPerDay = 10;
                final progress =
                    (total / (days * targetPerDay)).clamp(0.0, 1.0);
                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: primaryBlue.withOpacity(0.1),
                            color: primaryBlue,
                          ),
                          const SizedBox(height: 6),
                          Text('Promedio: ${average.toStringAsFixed(1)} /día',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black54)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('$total tareas',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
