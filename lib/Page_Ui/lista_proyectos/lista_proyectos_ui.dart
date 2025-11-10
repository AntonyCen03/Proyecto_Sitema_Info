import 'package:flutter/material.dart';
import 'package:proyecto_final/Page_Ui/lista_proyectos/proyectos_de_la_lista.dart';
import 'package:proyecto_final/Page_Ui/pagina_principal/MenuNotificacion.dart';
import 'package:proyecto_final/Page_Ui/pagina_principal/sideDrawer.dart';
import 'package:proyecto_final/Color/Color.dart';
import 'package:proyecto_final/Page_Ui/pagina_principal/accountMenu.dart';

class ListaProyectos extends StatefulWidget{
  const ListaProyectos({super.key});

  @override
  State<ListaProyectos>  createState() => ListaProyectosUi();
  
}

class ListaProyectosUi extends State<ListaProyectos>{
  
  int numero = 0;
  bool administrador = true;
  List<Map<String, dynamic>> proyectos = [
    {
    'id': 0,
    'title': 'Proyecto A (Inicial)', 
    'percent': 50.0, 
    'view': 10
  },
  { 
    'id': 1,
    'title': 'Proyecto B (Inicial)', 
    'percent': 75, 
    'view': 30
  },
  {
    'id': 2,
    'title': 'Proyecto C (Inicial)', 
    'percent': 25, 
    'view': 15
  },
  {
    'id': 3,
    'title': 'Desarrollo App Móvil', 
    'percent': 75.5, 
    'view': 150
  },
  {
    'id': 4,
    'title': 'Diseño Web Corporativo', 
    'percent': 100.0, 
    'view': 420
  },
  {
    'id': 5,
    'title': 'Campaña de Marketing Q3', 
    'percent': 32.1, 
    'view': 85
  },
  {
    'id': 6,
    'title': 'Migración a la Nube', 
    'percent': 12.8, 
    'view': 25
  },
  {
    'id': 7,
    'title': 'Optimización de Base Datos', 
    'percent': 90.0, 
    'view': 110
  },
  {
    'id': 8,
    'title': 'Automatización de Facturas', 
    'percent': 65.0, 
    'view': 60
  },
  {
    'id': 9,
    'title': 'Reunión Estratégica Anual', 
    'percent': 8.2, 
    'view': 15
  },
  ];
  List<int> ids = [];
  List<Widget> listaproyectos = [];
  String filtro = "view";

  @override
  void initState() {
    administrador = false;
    arrreglarlista();
    reorganizarlista();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: colorFondo,
        extendBodyBehindAppBar: false,
        appBar: _buildAppBar(context),
        drawer: const SideDrawer(),
        body: Padding(
          padding: EdgeInsetsGeometry.all(35),
          child: cuerpo(), 
        )
       
    );
  }

  Widget cuerpo(){
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 1),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        children: [
          Align(
            alignment: AlignmentGeometry.topLeft,
            child:Row(
              children: [
                SizedBox(
                  width: 26,
                ),
                Text("Proyectos",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: primaryOrange,
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
              ],
            ),
            ),
          SizedBox(height: 16.0),
          Divider(),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                ElevatedButton.icon(
                  label: Text("Filtro"),
                  icon: Icon(Icons.filter_list),
                  onPressed: () {
                    // Acción al presionar el ícono
                  setState(() {
                  });
                  },
                ),
                SizedBox(width: 16,),
                SizedBox(
                  width: 300,
                  height: 37,
                  child: TextField(
                  decoration: InputDecoration(
                    hintText: Text('Buscar proyecto', style: TextStyle(fontSize: 11)).data,
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                  ),
                  onChanged: (value) {
                    // Acción al cambiar el texto
                  },
                ),),
                ],
              ),
              Visibility(
                visible: administrador,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Acción al presionar el botón
                  },
                  icon: Icon(Icons.add),
                  label: Text("Nuevo Proyecto"),
                ),
              )
            ]
          ),
          SizedBox(height: 16.0),
          proyectoslist(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: primaryOrange),
      title: const Text(
        'MetroBox',
        style: TextStyle(color: primaryOrange, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: const [NotificationsMenu(), AccountMenu(), SizedBox(width: 8)],
    );
  }

  Widget proyectoslist(){
    return ListView(
      shrinkWrap: true,
      primary: false,
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        listaproyectos[numero],
        listaproyectos[numero+1],
        listaproyectos[numero+2],
        listaproyectos[numero+3],
        listaproyectos[numero+4],
      ],
    );
  }

  Widget cambiosdepagina(){
    return Container(
      child: Text("Cambios de página"),
    );
  }

  void arreglarlistaproyectos(){
    listaproyectos.clear();
    for(int i = 0; i < proyectos.length; i++){
      listaproyectos.add(
        ProyectosDeLaLista(
          proyectos: proyectos[ids[i]],
          onTap: () {
          },
        ),
      );
    }
    
  }

  void arrreglarlista(){
    for(int i = 0; i < proyectos.length; i++){
      ids.add(proyectos[i]['id']);
    }
    arreglarlistaproyectos();
  }

  void reorganizarlista(){
    bool cambios = false;
    for(int i = 0; i < proyectos.length- 1; i++){
      int posicion = i;
      for(int j = i+1; j < proyectos.length; j++){
        if(proyectos[ids[posicion]][filtro] < proyectos[ids[j]][filtro]){
          posicion = j;
          }
     }
      if(posicion != i){
        cambios = true;
        int aux = ids[i];
        ids[i] = ids[posicion];
        ids[posicion] = aux;
      }
    }
    if (cambios){
      setState(() {
        arreglarlistaproyectos();
        });
    }
  }

  void buscador(){
    
  }

}


