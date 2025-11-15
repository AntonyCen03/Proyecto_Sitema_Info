import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

//Esta clase se encarga de crear el grafico de pizza que se usara para mostrar el porcentaje de completacion de cada proyecto en la lista de proyectos.
class GraficoPizza extends StatefulWidget {
  final Map<String, dynamic> proyectos;

  const GraficoPizza({
    super.key,
    required this.proyectos,
  });

  @override
  State<GraficoPizza> createState() => GPizza();
}

class GPizza extends State<GraficoPizza> {
  final co = <List<Color>>[
    [Colors.blue, Colors.red],
  ];
  bool _initialized = false;
  late double _size;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double percent = ((widget.proyectos['percent'] ?? 0) as num)
        .toDouble()
        .clamp(0.0, 100.0);
    final Map<String, double> valor = {'completado': percent};
    // Ajuste responsivo: reducir tamaño en pantallas estrechas
    // Determinar el tamaño SOLO una vez (primer build) para evitar cambios posteriores por reflow.
    if (!_initialized) {
      final double screenW = MediaQuery.of(context).size.width;
      _size = screenW < 360 ? 64 : (screenW < 420 ? 80 : 100);
      _initialized = true;
    }

    return RepaintBoundary(
      child: SizedBox(
        width: _size,
        height: _size,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: PieChart(
            dataMap: valor,
            chartRadius: _size,
            chartLegendSpacing: 0,
            chartType: ChartType.ring,
            baseChartColor: Colors.grey.shade300,
            ringStrokeWidth: 10,
            animationDuration: Duration.zero,
            gradientList: co,
            legendOptions: const LegendOptions(showLegends: false),
            chartValuesOptions: const ChartValuesOptions(
              showChartValues: false,
            ),
            centerText: '${percent.toStringAsFixed(0)}%',
            totalValue: 100,
          ),
        ),
      ),
    );
  }
}
