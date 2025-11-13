import 'package:flutter/material.dart';
import 'package:proyecto_final/Page_Ui/lista_proyectos/proyectos_de_la_lista.dart';
import 'package:proyecto_final/Page_Ui/pagina_principal/MenuNotificacion.dart';
import 'package:proyecto_final/Page_Ui/pagina_principal/sideDrawer.dart';
import 'package:proyecto_final/Color/Color.dart';
import 'package:proyecto_final/Page_Ui/pagina_principal/accountMenu.dart';
import 'dart:math';
import 'package:number_pagination/number_pagination.dart';

//Esta clase se encaraa de crear la lista de proyectos en la interfaz de usuario.
class ListaProyectos extends StatefulWidget{
  const ListaProyectos({super.key});

  @override
  State<ListaProyectos>  createState() => ListaProyectosUi();
  
}

enum Filtro { views, percentaje, creation, finish, misproyectos }
class ListaProyectosUi extends State<ListaProyectos>{
  int paginaActual = 1;
  int numero = 0;
  bool administrador = true;
  List<Map<String, dynamic>> proyectos = [
    {
        'id': 0,
        'title': 'Proyecto A (Inicial)', 
        'percent': 50.0, 
        'view': 10,
        'fecha_inicio': '2025-10-01',
        'fecha_entrega': '2025-12-31',
        'participantes': ['Ana García', 'Carlos Ruiz'],
    },
    { 
        'id': 1,
        'title': 'Proyecto B (Inicial)', 
        'percent': 75, 
        'view': 30,
        'fecha_inicio': '2025-09-15',
        'fecha_entrega': '2025-11-20',
        'participantes': ['Elena Flores', 'Javier López'],
    },
    {
        'id': 2,
        'title': 'Proyecto C (Inicial)', 
        'percent': 25, 
        'view': 15,
        'fecha_inicio': '2026-01-05',
        'fecha_entrega': '2026-03-15',
        'participantes': ['Miguel Sanz', 'Laura Torres'],
    },
    {
        'id': 3,
        'title': 'Desarrollo App Móvil', 
        'percent': 75.5, 
        'view': 150,
        'fecha_inicio': '2025-11-01',
        'fecha_entrega': '2026-04-30',
        'participantes': ['Carlos Ruiz', 'Sofía Gil', 'Pedro Mena'],
    },
    {
        'id': 4,
        'title': 'Diseño Web Corporativo', 
        'percent': 100.0, 
        'view': 420,
        'fecha_inicio': '2025-08-01',
        'fecha_entrega': '2025-10-15',
        'participantes': ['Ana García', 'David Herrera'],
    },
    {
        'id': 5,
        'title': 'Campaña de Marketing Q3', 
        'percent': 32.1, 
        'view': 85,
        'fecha_inicio': '2026-02-10',
        'fecha_entrega': '2026-05-25',
        'participantes': ['Elena Flores', 'Javier López', 'Marta Soto'],
    },
    {
        'id': 6,
        'title': 'Migración a la Nube', 
        'percent': 12.8, 
        'view': 25,
        'fecha_inicio': '2025-12-01',
        'fecha_entrega': '2026-06-30',
        'participantes': ['Miguel Sanz', 'David Herrera'],
    },
    {
        'id': 7,
        'title': 'Optimización de Base Datos', 
        'percent': 90.0, 
        'view': 110,
        'fecha_inicio': '2025-09-01',
        'fecha_entrega': '2025-11-01',
        'participantes': ['Laura Torres', 'Pedro Mena'],
    },
    {
        'id': 8,
        'title': 'Automatización de Facturas', 
        'percent': 65.0, 
        'view': 60,
        'fecha_inicio': '2026-01-15',
        'fecha_entrega': '2026-04-15',
        'participantes': ['Sofía Gil', 'Marta Soto', 'Ana García'],
    },
    {
        'id': 9,
        'title': 'Reunión Estratégica Anual', 
        'percent': 8.2, 
        'view': 15,
        'fecha_inicio': '2025-10-20',
        'fecha_entrega': '2025-11-10',
        'participantes': ['Carlos Ruiz', 'Elena Flores'],
    },
  ];
  List<int> ids = [];
  List<Widget> listaproyectos = [];
  String filtro = "view";
  Widget listadeproyectos = Container();
  String usuarioActual = "Ana García"; 

  @override
  void initState() {
    administrador = false;
    arrreglarlista();
    arreglarlistaproyectos();
    listadeproyectos = proyectoslist();
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
    //Este metodo crea el cuerpo de la UI de la lista de proyectos
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
          SizedBox(height: 10.0),
          Divider(),
          SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                filtros(),
                SizedBox(width: 10,),
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
                    buscador(value);
                  },
                ),),
                ],
              ),
              Visibility(
                visible: administrador,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Aqui hacer para unir lo de crear nuevo proyecto
                  },
                  icon: Icon(Icons.add),
                  label: Text("Nuevo Proyecto"),
                ),
              )
            ]
          ),
          SizedBox(height: 5.0),
          listadeproyectos,
          cambiosdepagina(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    //Este metodo crea la barra de navegacion superior
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
    //Este metodo crea la lista de proyectos que se mostrara en la UI
    final int inicio = numero;
    final int fin = min(numero + 5, listaproyectos.length);
    return ListView(
      shrinkWrap: true,
      primary: false,
      padding: const EdgeInsets.all(16),
      children: listaproyectos.sublist(inicio, fin)
    );
  }
  
  Widget cambiosdepagina(){
    //Este metodo crea la paginacion de la lista de proyectos
    return NumberPagination(
      totalPages: (listaproyectos.length / 5).ceil(),
      currentPage: paginaActual,
      fontSize: 16.0,
      buttonRadius: 50.0,
      onPageChanged: (int page) {
        setState(() {
          numero = (page - 1) * 5;
          paginaActual = page;
          listadeproyectos = proyectoslist();
        });
      },
    );
  }

  Widget filtros(){
    //Este metodo crea el menu de filtros para la lista de proyectos
    return PopupMenuButton<Filtro>(
      onSelected: (Filtro result){
        switch (result) {
          case Filtro.views:
            filtro = "view";
            reorganizarlista();
            break;
          case Filtro.percentaje:
            filtro = "percent";
            reorganizarlista();
            break;
          case Filtro.creation:
            filtro = "creation";
            reorganizarlista();
            break;
          case Filtro.finish:
            filtro = "finish";
            reorganizarlista();
            break;
          case Filtro.misproyectos:
            filtro = "misproyectos";
            reorganizarlista();
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<Filtro>>[
        const PopupMenuItem<Filtro>(
          value: Filtro.views,
          child: Text('Más Vistos'),
        ),
        const PopupMenuItem<Filtro>(
          value: Filtro.percentaje,
          child: Text('Proyectos Finalizados'),
      ),
        const PopupMenuItem<Filtro>(
          value: Filtro.creation,
          child: Text('Más Recientes')),
        const PopupMenuItem<Filtro>(
          value: Filtro.finish,
          child: Text('Fecha de Entrega')),
        const PopupMenuItem<Filtro>(
          value: Filtro.misproyectos,
          child: Text('Mis Proyectos')),
      ],
    icon:  Icon(Icons.filter_list),
    tooltip: "Filtrar Proyectos",
    );
  }

  void arreglarlistaproyectos(){
    //Aqui se crea la lista con la clase de proyectos_de_la_lista que se usara para mostrar los proyectos en el widget proyectoslist
    listaproyectos.clear();
    for(int i = 0; i < ids.length; i++){
      listaproyectos.add(
        ProyectosDeLaLista(
          proyectos: proyectos[ids[i]],
          onTap: () {
            //Aqui antony debes de dar para que el usuario de click y se muestre la ventana con los datos del proyecto
          },
        ),
      );
    }
  }

  void arrreglarlista(){
    //Aqui se crea la lista de ids de los proyectos
    for(int i = 0; i < proyectos.length; i++){
      ids.add(proyectos[i]['id']);
    }
  }

  void reorganizarlista(){
    //Aqui se reorganiza la lista de proyectos segun el filtro seleccionado
    ids.clear();
    arrreglarlista();
    if (filtro == 'view'){
      
      for(int i = 0; i < proyectos.length- 1; i++){
        int posicion = i;
        for(int j = i+1; j < proyectos.length; j++){
    
          if(proyectos[ids[posicion]][filtro] < proyectos[ids[j]][filtro]){
            posicion = j;
            }
        }
        if(posicion != i){
          int aux = ids[i];
          ids[i] = ids[posicion];
          ids[posicion] = aux;
        }
      }
      
    } else if (filtro == 'percent'){
      ids.clear();
      for(int i = 0; i < proyectos.length; i++){
        if(proyectos[i]['percent'] == 100.0){
          ids.add(proyectos[i]['id']);
        }
      }
    } else if(filtro == 'creation'){
      for(int i = 0; i < proyectos.length- 1; i++){
        int posicion = i;
        for(int j = i+1; j < proyectos.length; j++){
          DateTime fechaPosicion = DateTime.parse(proyectos[ids[posicion]]['fecha_inicio']);
          DateTime fechaJ = DateTime.parse(proyectos[ids[j]]['fecha_inicio']);
          if(fechaPosicion.isBefore(fechaJ)){
            posicion = j;
            }
        }
        if(posicion != i){
          int aux = ids[i];
          ids[i] = ids[posicion];
          ids[posicion] = aux;
        }
      }
    } else if(filtro == 'finish'){
      for(int i = 0; i < proyectos.length- 1; i++){
        int posicion = i;
        for(int j = i+1; j < proyectos.length; j++){
          DateTime fechaPosicion = DateTime.parse(proyectos[ids[posicion]]['fecha_entrega']);
          DateTime fechaJ = DateTime.parse(proyectos[ids[j]]['fecha_entrega']);
          if(fechaPosicion.isAfter(fechaJ)){
            posicion = j;
            }
        }
        if(posicion != i){
          int aux = ids[i];
          ids[i] = ids[posicion];
          ids[posicion] = aux;
        }
      }
    } else if(filtro == 'misproyectos'){
      ids.clear();
      for(int i = 0; i < proyectos.length; i++){
        if(proyectos[i]['participantes'].contains(usuarioActual)){
          ids.add(proyectos[i]['id']);
        }
      }

    }


    setState(() {
        arreglarlistaproyectos();
        listadeproyectos = proyectoslist();
      });
  }

  void buscador(String value){
    //Aqui se busca en la lista de proyectos el texto introducido en el buscador
    ids.clear();
    for(int i = 0; i < proyectos.length; i++){
      if(proyectos[i]['title'].toLowerCase().contains(value.toLowerCase())){
        ids.add(proyectos[i]['id']);
      }
    }
    setState(() {
      arreglarlistaproyectos();
      listadeproyectos = proyectoslist();
    });
    
  }


}