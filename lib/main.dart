/*
 *                        _oo0oo_
 *                       o8888888o
 *                       88" . "88
 *                       (| -_- |)
 *                       0\  =  /0
 *                     ___/`---'\___
 *                   .' \\|     |// '.
 *                  / \\|||  :  |||// \
 *                 / _||||| -:- |||||- \
 *                |   | \\\  - /// |   |
 *                | \_|  ''\---/''  |_/ |
 *                \  .-\__  '-'  ___/-. /
 *              ___'. .'  /--.--\  `. .'___
 *           ."" '<  `.___\_<|>_/___.' >' "".
 *          | | :  `- \`.;`\ _ /`;.`/ - ` : | |
 *          \  \ `_.   \_ __\ /__ _/   .-` /  /
 *      =====`-.____`.___ \_____/___.-`___.-'=====
 *                        `=---='
 * 
 * 
 *      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * 
 *            佛祖保佑     永不宕机     永无BUG
 *                  Un 20 porfa jajajaja
 */

import 'package:flutter/material.dart';
import 'package:proyecto_final/Page_Ui/lista_proyectos/lista_proyectos_ui.dart';
import 'package:proyecto_final/Page_Ui/pagina_login/login.dart';
import 'package:proyecto_final/Page_Ui/pagina_login/pagina_crear_cuenta/registrar_usuario.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:proyecto_final/Page_Ui/pagina_login/reset_password/olvidecontrasena.dart';
import 'package:proyecto_final/Page_Ui/perfil_usuario/perfil_usuario_new.dart';
import 'package:proyecto_final/Page_Ui/recursos/recursos_page.dart';
import 'firebase_options.dart';
import 'package:proyecto_final/Page_Ui/pagina_principal/page_principal.dart';
import 'package:proyecto_final/Page_Ui/pagina_login/nueva_contrasena.dart';
import 'package:proyecto_final/Page_Ui/reporte_dashboard/dashboard_page.dart';
import 'package:proyecto_final/Page_Ui/reporte_dashboard/reportes_page.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:proyecto_final/Page_Ui/pagina_calendario/calendario.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:proyecto_final/Page_Ui/crear_proyecto/page_create_project.dart';
import 'package:proyecto_final/Page_Ui/pagina_foro/foro.dart';
import 'package:proyecto_final/Page_Ui/pagina_finanzas/finanzas_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('es_ES', null);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MetroBox',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(250, 250, 250, 250),
      ),
      locale: const Locale('es', 'ES'),
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/principal',
      routes: {
        '/login': (context) => const PageLogin(),
        '/registrar': (context) => const PageSignUp(),
        '/reset_password': (context) => const Olvidecontrasena(),
        '/perfil': (context) => const PerfilUsuarioNew(),
        '/principal': (context) => const PaginaPrincipal(),
        '/cambiar_contrasena': (context) => const NuevaContrasenaScreen(),
        '/dashboard': (context) => const DashboardPage(),
        '/reportes': (context) => const ReportesPage(),
        '/calendario': (context) => const CalendarScreen(),
        '/crear_proyecto': (context) => const PageCreateProject(),
        '/foro_page': (context) => const ForoPage(),
        '/proyectos_lista': (context) => const ListaProyectos(),
        '/finanzas_proyecto': (context) => const FinanzasProyectoPage(),
        '/recursos': (context) => const RecursosPage(),
      },
    );
  }
}
