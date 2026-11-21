import 'package:flutter/material.dart';

class AnimatedBrandLogo extends StatefulWidget {
  const AnimatedBrandLogo({super.key});

  @override
  State<AnimatedBrandLogo> createState() => _AnimatedBrandLogoState();
}

class _AnimatedBrandLogoState extends State<AnimatedBrandLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final String brand = 'GeoCobranza';
  final String slogan = 'Tu información, en el lugar correcto';

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // LOGOTIPO
        Image.asset(
          'assets/images/geocobranza_icono.png',
          width: 90,
          height: 90,
          fit: BoxFit.contain,
        ),

        const SizedBox(width: 8),

        // NOMBRE Y ESLOGAN
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ANIMACIÓN LETRA POR LETRA
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(brand.length, (index) {
                final double start = index * 0.055;
                final double end = (start + 0.35).clamp(0.0, 1.0);

                final animation = CurvedAnimation(
                  parent: _controller,
                  curve: Interval(start, end, curve: Curves.easeOutCubic),
                );

                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    final bool isBlue = index >= 3;

                    return Opacity(
                      opacity: animation.value,
                      child: Transform.translate(
                        offset: Offset(20 * (1 - animation.value), 0),
                        child: Text(
                          brand[index],
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w800,
                            color: isBlue
                                ? const Color(0xFF0876E8)
                                : const Color(0xFF102D56),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),

            // ANIMACIÓN DEL ESLOGAN
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _controller,
                curve: const Interval(0.70, 1.0, curve: Curves.easeIn),
              ),
              child: Text(
                slogan,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF19365C),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
