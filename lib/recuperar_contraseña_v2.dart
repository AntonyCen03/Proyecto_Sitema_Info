import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
                        child:const Text(
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
                        child:const Text(
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
                            child: const Align(
                            alignment: Alignment.topLeft,
                            child: const TextField(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(),
                              hintText: 'Código de verificación',
                              ),
                            ),
                            ) 
                            )  
                          ),
                          const Column(
                            children: [
                              Text(
                              'Hemos enviado el código a:',
                              style: TextStyle(
                                fontSize: 24,
                                color: Color.fromRGBO(248, 131, 49, 1)
                                ), 
                              ), 
                              Text('Aqui va el correo',
                              style: TextStyle(
                                fontSize: 24,
                                color: Color.fromRGBO(248, 131, 49, 1)
                                ), 
                              )
                            ],
                          )
                        ],
                      ),
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
                              }, 
                          child: const Text('Reenviar código'),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                            onPressed: (){
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