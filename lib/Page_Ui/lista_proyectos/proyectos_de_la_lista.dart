import 'package:flutter/material.dart';
import 'package:proyecto_final/Page_Ui/lista_proyectos/Grafico_pizza.dart';

class ProyectosDeLaLista extends StatefulWidget{
 final Map<String, dynamic> proyectos; 
 final VoidCallback onTap;
  
  const ProyectosDeLaLista({
    super.key,
    required this.proyectos, 
    required this.onTap,
  });

  @override
  State<ProyectosDeLaLista> createState() => PLista();

}

class PLista extends State<ProyectosDeLaLista>{
  bool _isHovering = false;

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
    return InkWell(
      onTap: widget.onTap,
      onHover: (isHovering) {
        setState(() {
          _isHovering = isHovering;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10.0),
        decoration: BoxDecoration(
          color: _isHovering 
              ? Colors.grey[200] // Color cuando el cursor está encima
              : Colors.transparent, // Color normal
          borderRadius: BorderRadius.circular(8.0),
        ), 
        child:Row( 
      children: [
        GraficoPizza(proyectos: widget.proyectos),
        SizedBox(width: 16),
        Column(
          children: [
            Text(widget.proyectos['title'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            SizedBox(height: 8),
            Text('Vistas: ${widget.proyectos['view']}', style: TextStyle(fontSize: 16),),
          ],
        ),
      ],
      ),
      ),
    );
  }
}