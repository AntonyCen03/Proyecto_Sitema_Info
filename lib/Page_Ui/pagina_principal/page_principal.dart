import 'package:flutter/material.dart';
// Asumo que tienes estos archivos y que primaryOrange/lightOrange están definidos
import 'accountMenu.dart';
import 'sideDrawer.dart';
//import 'package:proyecto_final/Color/Color.dart';
import 'MenuNotificacion.dart';

// Definiciones de color dummy para que el archivo compile
const Color primaryOrange = Colors.orange;
const Color lightOrange = Colors.orangeAccent;

/// Página principal reestructurada con AppBar, Drawer y fondo de imagen
class PaginaPrincipal extends StatefulWidget {
  const PaginaPrincipal({super.key});

  @override
  State<PaginaPrincipal> createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: _buildAppBar(context), // NO SE TOCA
      drawer: const SideDrawer(), // NO SE TOCA

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // SECCIÓN 1: Hero principal (No se toca)
            _Background(
              child: SafeArea(
                bottom: false,
                child: _OriginalHeroSection(),
              ),
            ),

            // SECCIÓN 2: La sección modificada con el nuevo diseño
            _GestionaProyectosSection(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    // NO SE TOCA
    return AppBar(
      backgroundColor: Colors.transparent,
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
}

// Fondo con imagen (NO SE TOCA)
class _Background extends StatelessWidget {
  const _Background({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 500),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/CAMPUS-2023_30.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
        ),
      ),
      child: child,
    );
  }
}

// --- SECCIÓN 1 (SIN CAMBIOS) ---

/// SECCIÓN 1: Esta es tu sección original (NO SE TOCA)
class _OriginalHeroSection extends StatelessWidget {
  const _OriginalHeroSection();

  @override
  Widget build(BuildContext context) {
    final double heroHeight = MediaQuery.of(context).size.height * 0.6;
    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ShaderMask(
                        shaderCallback: (Rect bounds) => LinearGradient(
                          colors: [
                            primaryOrange,
                            lightOrange
                          ], // Asumo que existen
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ).createShader(bounds),
                        child: Text(
                          'La organización es la\nbase del sistema del\néxito',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Concéntrate en crear y nosotros nos\nencargamos de organizar',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- SECCIÓN 2 (REDISEÑADA Y AHORA ANIMADA) ---

/// SECCIÓN 2: Esta es la nueva sección con el diseño "Apple".
/// Ahora es un StatefulWidget para soportar animaciones.
class _GestionaProyectosSection extends StatefulWidget {
  const _GestionaProyectosSection({super.key});

  @override
  State<_GestionaProyectosSection> createState() =>
      _GestionaProyectosSectionState();
}

class _GestionaProyectosSectionState extends State<_GestionaProyectosSection>
    with TickerProviderStateMixin {
  // Controladores para las animaciones
  late final AnimationController _mockupController;
  late final Animation<double> _mockupFadeAnimation;
  late final Animation<Offset> _mockupSlideAnimation;

  late final AnimationController _textController;
  late final Animation<double> _textFadeAnimation;
  late final Animation<Offset> _textSlideAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Animación para los Mockups (dispositivos)
    _mockupController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _mockupFadeAnimation = CurvedAnimation(
      parent: _mockupController,
      curve: Curves.easeOut,
    );
    _mockupSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2), // Empieza 20% abajo
      end: Offset.zero,
    ).animate(_mockupFadeAnimation);

    // 2. Animación para el Texto
    _textController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _textFadeAnimation = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    );
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2), // Empieza 20% abajo
      end: Offset.zero,
    ).animate(_textFadeAnimation);

    // 3. Iniciar las animaciones (escalonadas)
    _mockupController.forward();
    // El texto empieza 200ms después que los mockups
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _textController.forward();
      }
    });
  }

  @override
  void dispose() {
    _mockupController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // 1. REFINADO: Fondo "blanco roto" (estilo Apple)
      color: const Color(0xFFF5F5F7),
      width: double.infinity,
      // 2. Padding generoso para dar "aire" (espacio en blanco)
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 100),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Wrapper de animación reutilizable
          Widget animatedMockups = FadeTransition(
            opacity: _mockupFadeAnimation,
            child: SlideTransition(
              position: _mockupSlideAnimation,
              child: _DeviceMockups(),
            ),
          );

          // Wrapper de animación reutilizable
          Widget animatedText(bool isDesktop) => FadeTransition(
                opacity: _textFadeAnimation,
                child: SlideTransition(
                  position: _textSlideAnimation,
                  child: _NewTextView(isDesktop: isDesktop),
                ),
              );

          // Si la pantalla es estrecha (móvil)
          if (constraints.maxWidth < 700) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              // 3. ALINEACIÓN: Mueve todo al inicio (izquierda) en móvil
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                animatedMockups,
                const SizedBox(height: 60), // Más espacio en móvil
                animatedText(false), // Texto centrado
              ],
            );
          }

          // Si la pantalla es ancha (tablet/web)
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Damos más espacio a los mockups
              Expanded(
                flex: 2,
                child: animatedMockups,
              ),
              const SizedBox(width: 40),
              // Y el texto se alinea a la izquierda
              Expanded(
                flex: 1,
                child: animatedText(true),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Widget para el texto "Gestiona tus proyectos..." (Estilo Apple)
class _NewTextView extends StatelessWidget {
  final bool isDesktop;
  const _NewTextView({this.isDesktop = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          'Gestiona tus proyectos donde sea.',
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF1D1D1F), // "Near black" de Apple
            fontSize: 42,
            fontWeight: FontWeight.w700,
            height: 1.1,
            letterSpacing: -0.5, // Un toque de "Apple"
          ),
        ),
        const SizedBox(height: 16),
        // Subtítulo, muy común en el diseño de Apple
        Text(
          'MetroBox te da el poder de organizar tus tareas, '
          'sincronizar tus equipos y alcanzar tus metas, '
          'todo desde la palma de tu mano.',
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
          style: TextStyle(
            color: Colors.grey[700], // Un gris suave para el subtítulo
            fontSize: 18,
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

/// Widget para el Stack de mockups (Corregido y Rediseñado)
class _DeviceMockups extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // CAPA 1: La Laptop (al fondo)
        _LaptopMockup(),

        // CAPA 2: El Teléfono (al frente y movido más a la izquierda)
        Positioned(
          right: 20, // AHORA: Movido a la izquierda para mejor visibilidad
          bottom: -80, // Se mantiene la posición vertical
          child: _PhoneMockup(),
        ),
      ],
    );
  }
}

/// Widget que crea el mockup del Teléfono (Tamaño corregido y logo blanco)
class _PhoneMockup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180, // TAMAÑO: Un poco más ancho
      height: 360, // TAMAÑO: Un poco más alto
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E), // "Space Black" de Apple
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.grey[850]!,
          width: 5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(5, 5),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          // 1. ARREGLO DE FONDO: Pantalla del teléfono en blanco
          color: Colors.white,
          alignment: Alignment.center,
          // 1. ARREGLO DE LOGO: Se quita ColorFiltered.
          // Ahora muestra 'logo.png' en su color original.
          child: Image.asset(
            'assets/images/logo.png', // Tu logo.png
            fit: BoxFit.contain,
            width: 80,
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }
}

/// Widget que crea el mockup de la Laptop (Tamaño ampliado y rediseñado)
class _LaptopMockup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Pantalla
        Container(
          width: 450, // TAMAÑO: Ampliado
          height: 280, // TAMAÑO: Ampliado
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E), // "Space Black"
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.grey[850]!,
              width: 8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 25,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            // 2. ARREGLO DE IMAGEN: Se usa DecorationImage para asegurar
            // que la imagen 'tablet.png' llene la pantalla.
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  // CAMBIO: Usando el nombre de archivo que mencionaste
                  image: AssetImage(
                      'assets/images/fondotablet.png'), // Tu fondolaptop.png
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        // 2. Base del "teclado"
        Container(
          width: 500, // TAMAÑO: Ampliado para la base
          height: 12,
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E), // Gris oscuro de Apple
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ],
    );
  }
}
