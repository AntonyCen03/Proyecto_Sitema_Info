import 'package:flutter/material.dart';

class ConfirmarCorreo extends StatefulWidget {
  const ConfirmarCorreo({ super.key});

  @override
  State<ConfirmarCorreo> createState() => ConfirmarCorreos();
}
class ConfirmarCorreos extends State<ConfirmarCorreo> {
  
  String codigooriginal = '123456';
  Text advertencia = const Text('Se ha ingresado un código incorrecto', style: TextStyle(fontSize: 24, color: Colors.red),);
  TextEditingController codigo = TextEditingController();
  bool isvisible = false;
  String correo = '';
  bool existeelcorrreo = false;

  void obtenercorreoycodigo(){
    //Cambiar el codigo
    setState(() {
      correo = 'Ejemplo@correo.unimet.edu.ve';
    });
    //Aqui va la logica para obtener el correo al que se le envio el codigo y el codigo original
  }

  void verificador(){
    setState(() {

      if (codigo.text.isEmpty) {
        isvisible = true;
        advertencia = const Text("No se ha ingresado ningun codigo.", style: TextStyle(fontSize: 24, color: Color.fromARGB(255, 255, 17, 0)),);
        return;
      } else if (codigo.text != codigooriginal) {
        isvisible = true;
        advertencia = const Text('Se ha ingresado un código incorrecto.', style: TextStyle(fontSize: 24, color: Color.fromARGB(255, 255, 17, 1)),);
        return;
      }
      existeelcorrreo = true;
      //Aqui va la logica para continuar a la ventana de cambiar contrrasena
    });
  }

  void verificacion(String text){
    final isNumeric = RegExp(r'^\d+$').hasMatch(text);
    setState(() {
      if (codigo.text.isEmpty) {
      isvisible = false;
      return;
    } else if(isNumeric){
        isvisible = false;
      } else{
        isvisible = true;
        advertencia = const Text("El codigo es solo de numeros.", style: TextStyle(fontSize: 24, color: Color.fromARGB(255, 255, 17, 0)),);
      }
    });
    existeelcorrreo = true;
    //Aqui va la logica para continuar a la ventana de cambiar contrrasena
    return;
  }


  void reenviarcodigo(){
    //Aqui va la logica para reenviar el codigo al correo
  }

  void regresar(){
    //Aqui va la logica para regresar a la pantalla anterior
  }

  @override
   Widget build(BuildContext context) {  
    obtenercorreoycodigo();
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
        appBar: AppBar(
        title: const Text(
          "MetroBox",
          style: TextStyle(
            color: Color.fromRGBO(240, 83, 43, 1),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('images/Logo.png', height: 200, width: 200),
        ),
      ),
        body: Column(
          children: <Widget>[
            const Divider(
              color: Color.fromRGBO(65, 64, 64, 95),
              height: 4,
              thickness: 10,
              indent: 0,
              endIndent: 0,
            ),
            const SizedBox(height: 100),
            Container(
              width: 900.0,
              margin: const EdgeInsets.all(30),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(208, 215, 255, 1),
                border: Border.all(
                  color: const Color.fromRGBO(65, 64, 64, 0.95),
                  width: 4,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                    'Introduce el código de verificación',
                    style: TextStyle(
                      fontSize: 50,
                      color: Color.fromRGBO(240, 83, 43, 1),
                      fontWeight: FontWeight.bold,
                      ), 
                    ), 
                  ),
                  const Divider(
                    color: Color.fromRGBO(65, 64, 64, 95),
                    height: 4,
                    thickness: 4,
                    indent: 0,
                    endIndent: 0,
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                    'Enviamos un codigo a tu correo, para verificar que existe.',
                    style: TextStyle(
                      fontSize: 30,
                      color: Color.fromRGBO(248, 131, 49, 1)
                      ), 
                    ),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        child: Container(
                        margin: const EdgeInsets.all(20),
                        width: 300,
                        height: 50, 
                        child: Align(
                        alignment: Alignment.topLeft,
                        child: TextField(
                        onChanged: verificacion,
                        maxLength: 6,
                        controller: codigo,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                          labelText: 'Código de verificación',
                          ),
                        ),
                        ) 
                        )  
                      ),
                      Column(
                        children: [
                          const Text(
                          'Hemos enviado el código a:',
                          style: TextStyle(
                            fontSize: 24,
                            color: Color.fromRGBO(248, 131, 49, 1)
                            ), 
                          ), 
                          Text(correo ,style: const TextStyle(fontSize: 24, color: Color.fromRGBO(240, 83, 43, 1),),)
                        ],
                      )
                    ],
                  ),
                  Visibility(visible: isvisible,child: advertencia),
                  const SizedBox(height: 20),
                  const Divider(
                    color: Color.fromRGBO(65, 64, 64, 95),
                    height: 4,
                    thickness: 4,
                    indent: 0,
                    endIndent: 0,
                  ),
                  const SizedBox(height: 20),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                            style: TextButton.styleFrom(
                            foregroundColor:const Color.fromRGBO(240, 83, 43, 50)),
                          onPressed:  (){
                              reenviarcodigo();
                            }, 
                        child: const Text('Reenviar código', style: const TextStyle(fontSize: 24),),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                          onPressed: (){
                            regresar();
                            },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(248, 131, 49, 1),
                            foregroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            )
                          ),
                          child: const Text('Regresar')      
                        ),
                          const SizedBox(width: 20),
                            ElevatedButton(
                              onPressed: (){
                                verificador();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromRGBO(248, 131, 49, 1),
                                foregroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                )
                              ),
                              child: const Text('Continuar')      
                            )
                        ],
                      )
                    ],
                  )
                ],    
              ) 
            )
          ],
        ),
      ),
    );
  }

}  