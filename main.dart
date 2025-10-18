import 'package:flutter/material.dart';

void main() => runApp(const MyApp());


const Color primaryOrange = Color(0xFFF57C00);
const Color lightOrange = Color(0xFFFF9800);
const Color textColor = Color(0xFF1E1E1E);

//WIDGET DE TEXTO CON DEGRADADO
class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.gradient = const LinearGradient(
      colors: [primaryOrange, lightOrange],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
  });

  final String text;
  final TextStyle? style;
  final Gradient gradient;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(bounds),
      child: Text(
        text,
        textAlign: textAlign,
        style: (style ?? const TextStyle()).copyWith(color: Colors.white),
      ),
    );
  }
}

//APP PRINCIPAL
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Metro Box Landing Page',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        primaryColor: primaryOrange,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const LandingPage(),
    );
  }
}

//PÁGINA PRINCIPAL
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Header(),
            SizedBox(height: 60),
            HeroSection(),
            SizedBox(height: 40),
            Footer(),
          ],
        ),
      ),
    );
  }
}

//HEADER
class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: GradientText(
                  'Pagina Principal',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              GradientText(
                'Proyectos',
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
            ],
          ),
          Row(
            children: const [
              Icon(Icons.notifications_none, color: textColor),
              SizedBox(width: 8),
              Icon(Icons.account_circle, color: textColor, size: 28),
            ],
          ),
        ],
      ),
    );
  }
}

//HERO SECTION
class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  final String heroGraphicPath = 'assets/images/hero_graphic.png';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                GradientText(
                  'La organización es la\nbase del sistema del\néxito',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 16),
                GradientText(
                  'Concentrate en crear y nosotros nos\nencargamos de organizar',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 32),
                Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      gradient: LinearGradient(
                        colors: [primaryOrange, lightOrange],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryOrange,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      child: Text(
                        'Los mejores proyectos',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//FOOTER
class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          GradientText('Redes Sociales', style: TextStyle(fontSize: 14)),
          GradientText('Contactanos', style: TextStyle(fontSize: 14)),
          GradientText('Enlaces de Interes', style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}


