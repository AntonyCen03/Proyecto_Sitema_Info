import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class GraficoPizza extends StatefulWidget{
 final  Map<String, dynamic> proyectos; 
  
  const GraficoPizza({
    super.key,
    required this.proyectos, 
  });

  @override
  State<GraficoPizza> createState() => GPizza();

}

class GPizza extends State<GraficoPizza>{
  final co = <List<Color>>[[
    Colors.blue,
    Colors.red],
  ];  
  

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    Map<String, double> valor = {'': widget.proyectos['percent']};
    return SizedBox(
      width: 100,
      height: 100,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6),
        child: PieChart(
          dataMap: valor,
          chartLegendSpacing: 0,
          chartType: ChartType.ring,
          baseChartColor: Colors.transparent,
          gradientList: co,
          legendOptions: const LegendOptions(
            showLegends: false),
          chartValuesOptions: ChartValuesOptions(
            showChartValuesInPercentage: true,
          ),
          totalValue: 100,
        ),
      ),
    );
  }
}   