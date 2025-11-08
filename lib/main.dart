import 'package:flutter/material.dart';
import 'package:proyecto_final/Page_Ui/pagina_login/pagina_crear_cuenta/registrar_usuario.dart';
import 'package:proyecto_final/Page_Ui/pagina_login/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:proyecto_final/Page_Ui/pagina_login/reset_password/olvidecontrasena.dart';
import 'package:proyecto_final/Page_Ui/perfil_usuario/perfil_usuario_new.dart';
//import 'package:proyecto_final/Page_Ui/perfil_usuario/usuario.dart';
import 'firebase_options.dart';
import 'package:proyecto_final/Page_Ui/pagina_principal/page_principal.dart';
import 'package:proyecto_final/Page_Ui/pagina_login/nueva_contrasena.dart';
import 'package:proyecto_final/Page_Ui/reporte_dashboard/dashboard_page.dart';
import 'package:proyecto_final/Page_Ui/reporte_dashboard/reportes_page.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:proyecto_final/Page_Ui/pagina_calendario/calendario.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
      },
    );
  }
}
