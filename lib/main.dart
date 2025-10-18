import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

const Color _primaryOrange = Color(0xFFF57C00);
const Color _lightOrange = Color(0xFFFF9800);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Metro Box Landing Page',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        primaryColor: _primaryOrange,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const LandingPage(),
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _Header(),
            const SizedBox(height: 60),
            _HeroSection(),
            const SizedBox(height: 40),
            _Footer(),
          ],
        ),
      ),
    );
  }
}

// HEADER
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Image.asset(
                'assets/images/metrobox-image.jpg',
                width: 40,
                height: 40,
              ),
              const SizedBox(width: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Página Principal',
                  style: TextStyle(color: _primaryOrange),
                ),
              ),
              Text('Proyectos', style: TextStyle(color: _primaryOrange)),
            ],
          ),
          Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.notifications_none, color: _primaryOrange),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.account_circle, color: _primaryOrange, size: 28),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// HERO SECTION 
class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
            
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return const LinearGradient(
                          colors: [_primaryOrange, _lightOrange],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ).createShader(bounds);
                      },
                      child: const Text(
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
                      'Concentrate en crear y nosotros nos\nencargamos de organizar',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: _primaryOrange,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 24),

            //metrobox grande
              Expanded(
                flex: 4,
                child: Image.asset(
                  'assets/images/metrobox-image.jpg',
                  fit: BoxFit.contain,
                  height: 300,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

        //cuadro de mejores proyectos
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [_primaryOrange, _lightOrange],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _primaryOrange.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Text(
                'Los mejores proyectos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          //imagen campus grande
          Image.asset(
            'assets/images/CAMPUS-2023_30.jpg',
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }
}

// FOOTER 
class _Footer extends StatelessWidget {
  const _Footer();

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
        children: <Widget>[
          Text('Redes Sociales', style: TextStyle(color: _primaryOrange, fontSize: 14)),
          Text('Contáctanos', style: TextStyle(color: _primaryOrange, fontSize: 14)),
          Text('Enlaces de Interés', style: TextStyle(color: _primaryOrange, fontSize: 14)),
        ],
      ),
    );
  }
}