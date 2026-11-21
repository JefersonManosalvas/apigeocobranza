import 'package:flutter/material.dart';
import 'login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GeoCobranza',
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _mapAnimation;
  late Animation<double> _pointerAnimation;
  late Animation<double> _sloganAnimation;

  final String slogan = 'Cobra de forma segura';

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    );

    // 1. MAPA SUBE DESDE ABAJO
    _mapAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.30, curve: Curves.easeOutBack),
    );

    // 2. PUNTERO BAJA DESDE ARRIBA
    _pointerAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.22, 0.48, curve: Curves.bounceOut),
    );

    // 3. ESLOGAN
    _sloganAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.70, 0.98, curve: Curves.easeOut),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await _controller.forward();

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  // ANIMACIÓN DE CADA LETRA
  Widget animatedWord(String word, Color color, double fontSize, int delay) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(word.length, (index) {
        final double start = 0.38 + ((delay + index) * 0.035);

        final double end = start + 0.22;

        final animation = CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        );

        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Opacity(
              opacity: animation.value,
              child: Transform.translate(
                offset: Offset(25 * (1 - animation.value), 0),
                child: Text(
                  word[index],
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w800,
                    color: color,
                    height: 1.05,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // ESLOGAN
  Widget animatedSlogan() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final int visibleLetters = (_sloganAnimation.value * slogan.length)
            .floor()
            .clamp(0, slogan.length);

        return SizedBox(
          height: 19,
          child: Text(
            slogan.substring(0, visibleLetters),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF19365C),
              letterSpacing: 0.3,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // FONDO
          Positioned.fill(
            child: Image.asset('assets/images/fondo.jpeg', fit: BoxFit.cover),
          ),

          // LOGOTIPO COMPLETO
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // MAPA Y PUNTERO
                SizedBox(
                  width: 130,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // BASE DEL MAPA
                      AnimatedBuilder(
                        animation: _mapAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _mapAnimation.value.clamp(0.0, 1.0),
                            child: Transform.translate(
                              offset: Offset(
                                0,
                                110 * (1 - _mapAnimation.value),
                              ),
                              child: child,
                            ),
                          );
                        },
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Image.asset(
                            'assets/images/mapa_base.png',
                            width: 130,
                            height: 85,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      // PUNTERO DE UBICACIÓN
                      AnimatedBuilder(
                        animation: _pointerAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _pointerAnimation.value.clamp(0.0, 1.0),
                            child: Transform.translate(
                              offset: Offset(
                                0,
                                -90 * (1 - _pointerAnimation.value),
                              ),
                              child: child,
                            ),
                          );
                        },
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Image.asset(
                            'assets/images/puntero.png',
                            width: 65,
                            height: 80,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // TEXTO GEOCOBRANZA
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // GEO
                    animatedWord('Geo', const Color(0xFF102D56), 29, 0),

                    // COBRANZA
                    animatedWord('Cobranza', const Color(0xFF0876E8), 29, 3),

                    const SizedBox(height: 5),

                    // ESLOGAN
                    animatedSlogan(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
