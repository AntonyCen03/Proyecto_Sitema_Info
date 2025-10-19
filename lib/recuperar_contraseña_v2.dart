import 'package:flutter/material.dart';

class RecuperarContrasena_v2 extends StatefulWidget {
  const RecuperarContrasena_v2({ super.key});

  @override
  State<RecuperarContrasena_v2> createState() => recuperarcontrasenav2State();
}
class recuperarcontrasenav2State extends State<RecuperarContrasena_v2> {
  
  String codigooriginal = '123456';
  Text advertencia = const Text('Se ha ingresado un código incorrecto', style: TextStyle(fontSize: 24, color: Colors.red),);
  TextEditingController codigo = TextEditingController();
  bool isvisible = false;
  String correo = '';

  void obtenercorreo(){
    //Aqui va la logica para obtener el correo al que se le envio el codigo
  }

  void verificador(){
    if (codigo.text != codigooriginal){
      setState(() {
        isvisible = true;
      });
      
      return;
    }
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

    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
        appBar: AppBar(
          toolbarHeight: 145,
          backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
          leading: Image.asset(
              'images/Logo.png',
              width: 164,
              height: 231
              ,),
              leadingWidth: 300,
          title:
           const Text(
            'MetroBox',
            style: TextStyle(
              fontSize: 64,
              color: Color.fromRGBO(240, 83, 43, 1),
              fontWeight: FontWeight.bold,
              ),
            ),
          centerTitle: true,
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
                width: 1000.0,
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
                        'Revisa tu corrreo electrónico un mensaje con tu código de verificación ha sido enviado.',
                        style: TextStyle(
                          fontSize: 40,
                          color: Color.fromRGBO(248, 131, 49, 1)
                          ), 
                        ),
                      ),
                      Row(
                        children: [
                          SizedBox(
                            child: Container(
                            margin: const EdgeInsets.all(20),
                            width: 500,
                            height: 75, 
                            child: Align(
                            alignment: Alignment.topLeft,
                            child: TextField(
                            controller: codigo,
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
                                Text(correo ,style: const TextStyle(fontSize: 24, color: Color.fromRGBO(248, 131, 49, 1)),)
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
                          child: const Text('Reenviar código'),
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