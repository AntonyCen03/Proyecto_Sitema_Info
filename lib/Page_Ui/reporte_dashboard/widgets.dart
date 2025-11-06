import 'package:flutter/material.dart';

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
  final String estadoValue; // 'todos' | 'activos' | 'completados'
  final ValueChanged<String> onChangeEstado;
  final VoidCallback onApply; // aplica filtro (botón o Enter)

  const FilterBar({
    super.key,
    required this.searchController,
    required this.dateRange,
    required this.onPickDateRange,
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
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
    );
  }
}
