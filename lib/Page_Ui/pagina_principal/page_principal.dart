import 'package:flutter/material.dart';
import 'accountMenu.dart';
import 'sideDrawer.dart';
import 'package:proyecto_final/Color/Color.dart';
import 'MenuNotificacion.dart';

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
      appBar: _buildAppBar(context),
      drawer: const SideDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Background(
              child: SafeArea(
                bottom: false,
                child: _OriginalHeroSection(),
              ),
            ),
            _GestionaProyectosSection(),
            _FeaturesSection(),
            _TestimonialsSection(),
            _CtaSection(),
            _FooterSection(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
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

class _Background extends StatelessWidget {
  const _Background({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 500),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorFondoOscuro,
            colorFondoMasOscuro,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }
}

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
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ShaderMask(
                  shaderCallback: (Rect bounds) => LinearGradient(
                    colors: [primaryOrange, lightOrange],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ).createShader(bounds),
                  child: Text(
                    'La organización es la\nbase del sistema del\néxito',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorTextoOscuro,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Concéntrate en crear y nosotros nos\nencargamos de organizar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: colorTextoOscuro,
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

class _GestionaProyectosSection extends StatefulWidget {
  const _GestionaProyectosSection({super.key});

  @override
  State<_GestionaProyectosSection> createState() =>
      _GestionaProyectosSectionState();
}

class _GestionaProyectosSectionState extends State<_GestionaProyectosSection>
    with TickerProviderStateMixin {
  late final AnimationController _mockupController;
  late final Animation<double> _mockupFadeAnimation;
  late final Animation<Offset> _mockupSlideAnimation;

  late final AnimationController _textController;
  late final Animation<double> _textFadeAnimation;
  late final Animation<Offset> _textSlideAnimation;

  @override
  void initState() {
    super.initState();

    _mockupController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _mockupFadeAnimation = CurvedAnimation(
      parent: _mockupController,
      curve: Curves.easeOut,
    );
    _mockupSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(_mockupFadeAnimation);

    _textController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _textFadeAnimation = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    );
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(_textFadeAnimation);

    _mockupController.forward();
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
      color: grisClaro,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 100),
      child: LayoutBuilder(
        builder: (context, constraints) {
          Widget animatedMockups = FadeTransition(
            opacity: _mockupFadeAnimation,
            child: SlideTransition(
              position: _mockupSlideAnimation,
              child: _DeviceMockups(),
            ),
          );

          Widget animatedText(bool isDesktop) => FadeTransition(
                opacity: _textFadeAnimation,
                child: SlideTransition(
                  position: _textSlideAnimation,
                  child: _NewTextView(isDesktop: isDesktop),
                ),
              );

          if (constraints.maxWidth < 700) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                animatedMockups,
                const SizedBox(height: 60),
                animatedText(false),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: animatedMockups,
              ),
              const SizedBox(width: 40),
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
            color: colorFondoMasOscuro,
            fontSize: 42,
            fontWeight: FontWeight.w700,
            height: 1.1,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'MetroBox te da el poder de organizar tus tareas, '
          'sincronizar tus equipos y alcanzar tus metas, '
          'todo desde la palma de tu mano.',
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
          style: TextStyle(
            color: colorTextoSecundario,
            fontSize: 18,
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _DeviceMockups extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        _LaptopMockup(),
        Positioned(
          right: 20,
          bottom: -80,
          child: _PhoneMockup(),
        ),
      ],
    );
  }
}

class _PhoneMockup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 360,
      decoration: BoxDecoration(
        color: colorMarcoMockup,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: colorBordeMockup,
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
          color: Colors.white,
          alignment: Alignment.center,
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.contain,
            width: 80,
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }
}

class _LaptopMockup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 450,
          height: 280,
          decoration: BoxDecoration(
            color: colorMarcoMockup,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colorBordeMockup,
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
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  color: colorFondoMasOscuro,
                ),
                Image.asset(
                  'assets/images/dash.png',
                  fit: BoxFit.cover,
                  width: 450,
                  height: 280,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.red.withOpacity(0.5),
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Error: No se pudo cargar la imagen.\nAsegúrate de que "assets/images/fondolaptop.png" existe y está en pubspec.yaml.\n\nLuego, REINICIA la app (Hot Restart).',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        Container(
          width: 500,
          height: 12,
          decoration: BoxDecoration(
            color: colorFondoOscuro,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ],
    );
  }
}

class Feature {
  final IconData icon;
  final String title;
  final String description;

  Feature({required this.icon, required this.title, required this.description});
}

class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection();

  static final List<Feature> _features = [
    Feature(
      icon: Icons.dashboard_outlined,
      title: 'Tableros Visuales',
      description:
          'Organiza todo con tarjetas, listas y tableros estilo Kanban. Mueve tareas de \'Pendiente\' a \'Hecho\' con solo arrastrar.',
    ),
    Feature(
      icon: Icons.group_work_outlined,
      title: 'Colaboración en Equipo',
      description:
          'Asigna tareas, deja comentarios y comparte archivos. Mantén a todo tu equipo sincronizado en un solo lugar, sin esfuerzo.',
    ),
    Feature(
      icon: Icons.bar_chart_outlined,
      title: 'Reportes de Progreso',
      description:
          'Genera reportes instantáneos para ver el rendimiento de tu equipo y asegurarte de que todo avanza según lo planeado.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 100),
      child: Column(
        children: [
          Text(
            'Control total. Diseño simple.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorFondoMasOscuro,
              fontSize: 38,
              fontWeight: FontWeight.w700,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 60),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 40,
            runSpacing: 40,
            children: _features
                .map((feature) => _FeatureItem(feature: feature))
                .toList(),
          ),
          const SizedBox(height: 60),
          OutlinedButton(
            onPressed: () {
              /*showDialog(
                context: context,
                builder: (context) => const TopLikesDialog(),
              );*/
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryOrange,
              side: BorderSide(color: primaryOrange, width: 2),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Ver los mejores proyectos'),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final Feature feature;
  const _FeatureItem({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            feature.icon,
            color: primaryOrange,
            size: 36,
          ),
          const SizedBox(height: 20),
          Text(
            feature.title,
            style: TextStyle(
              color: colorFondoMasOscuro,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            feature.description,
            style: TextStyle(
              color: colorTextoSecundario,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class Testimonial {
  final String quote;
  final String author;
  final String title;

  Testimonial({required this.quote, required this.author, required this.title});
}

class _TestimonialsSection extends StatelessWidget {
  const _TestimonialsSection();

  static final List<Testimonial> _testimonials = [
    Testimonial(
      quote:
          '"MetroBox transformó nuestro flujo de trabajo. Pasamos del caos a la claridad en menos de una semana. No podríamos vivir sin él."',
      author: 'Ana Pérez',
      title: 'Estudiante de Ing electrica, Equipo alfa buena onda dinamita',
    ),
    Testimonial(
      quote:
          '"La mejor parte es la simplicidad. Es lo suficientemente potente para nuestros ingenieros y lo suficientemente simple para nuestro equipo de marketing."',
      author: 'Carlos González',
      title: 'Estudiante de Psicologia, Equipo Los 7 Sigmas',
    ),
    Testimonial(
      quote:
          '"Finalmente, una herramienta que no se siente como trabajo. Nuestros reportes de progreso son ahora automáticos y precisos."',
      author: 'Sofía Martínez',
      title: 'Estudiante de ing quimica, Equipo One Direction',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 100),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorFondoOscuro,
            colorFondoMasOscuro,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Text(
            'En quién confían los mejores equipos.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorTextoOscuro,
              fontSize: 38,
              fontWeight: FontWeight.w700,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 60),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 40,
            runSpacing: 40,
            children: _testimonials
                .map(
                    (testimonial) => _TestimonialItem(testimonial: testimonial))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _TestimonialItem extends StatelessWidget {
  final Testimonial testimonial;
  const _TestimonialItem({required this.testimonial});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.format_quote,
            color: primaryOrange,
            size: 36,
          ),
          const SizedBox(height: 20),
          Text(
            testimonial.quote,
            style: TextStyle(
              color: colorTextoOscuro.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.w400,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            testimonial.author,
            style: TextStyle(
              color: colorTextoOscuro,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            testimonial.title,
            style: TextStyle(
              color: colorTextoOscuro.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _CtaSection extends StatelessWidget {
  const _CtaSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 100),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorFondoMasOscuro,
            colorFondoCtaFinal,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Empieza a organizar tu éxito hoy.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorTextoOscuro,
              fontSize: 38,
              fontWeight: FontWeight.w700,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Regístrate gratis. No se requiere tarjeta de crédito.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorTextoOscuro.withOpacity(0.7),
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              foregroundColor: colorTextoOscuro,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            child: const Text('Comenzar Ahora'),
          ),
        ],
      ),
    );
  }
}

class _FooterSection extends StatelessWidget {
  const _FooterSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
      color: colorFondoCtaFinal,
      child: Text(
        '© 2024 MetroBox. Todos los derechos reservados.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: colorTextoOscuro.withOpacity(0.5),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
